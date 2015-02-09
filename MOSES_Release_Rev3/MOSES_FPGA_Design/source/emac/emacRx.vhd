--********************************************************************************
-- Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary Information of Connect Tech, Inc
-- and should be treated as Confidential.
--********************************************************************************
-- Project:		FreeForm/PCI-104
-- Module:		emacRx.vhd
-- Parent:		N/A
-- Description: Receives data from local link fifo, issues interrupt when EOF is
--				is received
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-07-23	MF		Created
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ctiUtil.all;

library unisim;
use unisim.vcomponents.all;

----------------------------------------------------------------------------------
entity emacRx is
----------------------------------------------------------------------------------
generic 
(
	c_dpAddrBWidth : natural := 5 -- dpRam is 2^c_dpAddrBWidth = 32
);
port
(       
	ll_clk_i : in std_logic;
	ll_reset_i : in std_logic;  -- should by synchronous.
	
--	lb_clk : in std_logic;
--	lb_rst : in std_logic;	
	lb_di : in std_logic_vector(31 downto 0);
	lb_do : out std_logic_vector(31 downto 0);	
	lb_a : in std_logic_vector(2 downto 0);
	lb_en : in std_logic;
	lb_wr : in std_logic_vector(3 downto 0);
	
	pktProcd : in std_logic;
	pktSz : out std_logic_vector(c_dpAddrBWidth downto 0);  --> 1 based
	pktDone : out std_logic;	
	
	rx_ll_data : in  std_logic_vector(7 downto 0);
	rx_ll_sof_n : in  std_logic;
	rx_ll_eof_n : in  std_logic; 
	rx_ll_src_rdy_n: in  std_logic;
	rx_ll_dst_rdy_n : out std_logic
);
end entity emacRx;

----------------------------------------------------------------------------------
architecture rtl of emacRx is

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	component dp_a32x8_b8x32 IS
		port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(31 downto 0);
		addra: IN std_logic_VECTOR(2 downto 0);
		ena: IN std_logic;
		wea: IN std_logic_VECTOR(3 downto 0);
		douta: OUT std_logic_VECTOR(31 downto 0);
		clkb: IN std_logic;
		dinb: IN std_logic_VECTOR(7 downto 0);
		addrb: IN std_logic_VECTOR(4 downto 0);
		web: IN std_logic_VECTOR(0 downto 0);
		doutb: OUT std_logic_VECTOR(7 downto 0));
	END component dp_a32x8_b8x32;	

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- signal Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	constant c_dpSize :  std_logic_VECTOR(c_dpAddrBWidth-1 downto 0) := (others => '1');	
		
	signal rst	: std_logic;
	
	signal rx_ll_dst_rdy_n_x : std_logic;

--	signal ovflw : std_logic;

	signal ramRxWr:  std_logic;
	signal ramRxDo	: std_logic_vector(7 downto 0);
	signal ramRxAddr:  std_logic_VECTOR(c_dpAddrBWidth-1 downto 0);	
	signal ramRxAddrInc : std_logic;
	signal ramRxAddrRst : std_logic;

	signal txfrSzEn : std_logic;

	type txfrState is (
						IDLE,
						RD_START,
						RD_TRANSFER,
						RD_EOF,
						RD_DRAIN
						);
						
	signal state : txfrState;
	signal nextState : txfrState;
						
--	signal done : std_logic;
--	signal done_r : std_logic;
--	alias done_r2 is pktDone;
--	
--	signal txfrSz : std_logic_vector(c_dpAddrBWidth downto 0);	
--	signal txfrSz_r : std_logic_vector(c_dpAddrBWidth downto 0);	
--	alias txfrSz_r2 is pktSz; --std_logic_vector(c_dpAddrBWidth-1 downto 0);	
--
--	signal pktProcd_r : std_logic;	
--	signal pktProcd_r2 : std_logic;
--
--	signal lb_rst_r : std_logic;
--	signal lb_rst_r2 : std_logic;
begin

	rst <= ll_reset_i;

	-- Assign intermidiate outputs to outputs
	rx_ll_dst_rdy_n <= rx_ll_dst_rdy_n_x;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Memory buffer
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	u_dp : dp_a32x8_b8x32
	port map (
		 clka => ll_clk_i,
		 dina => lb_di ,
		 addra => lb_a,
		 ena => lb_en,
		 wea => lb_wr,
		 douta => lb_do,
		
		 clkb => ll_clk_i,
		 dinb => rx_ll_data,
		 addrb => ramRxAddr,
		 web(0) => ramRxWr,
		 doutb => ramRxDo
	 );	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Clock domain crossing
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

-- not req'd all in lb and ll domain are same!
	
--	p_lbtoll : process(ll_clk_i)
--	begin
--		if rising_edge(ll_clk_i) then
--			pktProcd_r <= pktProcd;
--			pktProcd_r2 <= pktProcd_r;			
--
--			lb_rst_r <= lb_rst;
--			lb_rst_r2 <= lb_rst_r;				
--		end if;
--	end process;
--	
--	p_lltolb : process(lb_clk)
--	begin
--		if rising_edge(lb_clk) then
--			done_r <= done;
--			done_r2 <= done_r;		
--
--			txfrSz_r <= txfrSz;
--			txfrSz_r2 <= txfrSz_r;				
--		end if;
--	end process;
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Fifo ctrl statemachine
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	-- State register
	p_stateReg : process(ll_clk_i)
	begin
		if rising_edge(ll_clk_i) then
			if rst = '1' then
				state <= IDLE;
			else
				state <= nextState;
			end if;
		end if;
	end process;
	
	-- Next state logic
	p_nextState : process(	
	                  rx_ll_sof_n,
							rx_ll_src_rdy_n,
							rx_ll_eof_n,
							state,
							ramRxAddr,
							pktProcd
						)
	begin
		case state is
			-----------------------------
			-- wait for processed flag to be clear
			when IDLE =>
				if (pktProcd = '0') then
					nextState <= RD_START;
				else
					nextState <= IDLE;
				end if;	
				
			-----------------------------
			-- wait for the SOF
			when RD_START =>
				if (rx_ll_sof_n = '0' and rx_ll_src_rdy_n = '0') then
					nextState <= RD_TRANSFER;
				else
					nextState <= RD_START;
				end if;
				
			-----------------------------			
			-- store data until EOF
			when RD_TRANSFER =>
				if (rx_ll_src_rdy_n = '0') then
					if ( rx_ll_eof_n = '0' ) then
						nextState <= RD_EOF;
					else
						if (ramRxAddr >= c_dpSize) then
							nextState <= RD_DRAIN;
						else
							nextState <= RD_TRANSFER;						
						end if;
					end if;
				else
						nextState <= RD_TRANSFER;
				end if;			

			-----------------------------	
			-- drain the fifo
			when RD_DRAIN =>
				if  ( rx_ll_eof_n = '0' ) then
					nextState <= RD_EOF;
				else
					nextState <= RD_DRAIN;
				end if;				
				
			-----------------------------			
			-- wait for processed flag to be set
			when RD_EOF =>
				if (pktProcd = '1') then
					nextState <= IDLE;
				else
					nextState <= RD_EOF;
				end if;					
					
			-----------------------------			
			when others =>
				nextState <= IDLE;
		end case;
	end process p_nextState;
	
	-- State machine outputs

	
	-- Receive
	rx_ll_dst_rdy_n_x <= '0' when state = RD_START or state = RD_TRANSFER or state = RD_DRAIN else '1';
									-- need read error so that we can empty out fifo
	
	ramRxAddrInc <= '1' when (state = RD_START and rx_ll_sof_n = '0' and rx_ll_src_rdy_n = '0') or
							(state = RD_TRANSFER and rx_ll_src_rdy_n = '0' and rx_ll_eof_n = '1' and (ramRxAddr < c_dpSize)) else '0';
	
	ramRxWr <= '1' when (state = RD_START and rx_ll_sof_n = '0' and rx_ll_src_rdy_n = '0') or
							(state = RD_TRANSFER and rx_ll_src_rdy_n = '0') else '0';
	
	txfrSzEn <= '1' when	(state = RD_EOF) else '0';

	ramRxAddrRst <= '1' when (state = IDLE) else '0';
	
	pktDone <= '1' when (state = RD_EOF) else '0';
				
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Counters and status regs
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	-- addr counter
	p_addrIn : process(ll_clk_i)
		variable v_cnt : unsigned(c_dpAddrBWidth downto 0);
						-- one more bit than address width
	begin
		if rising_edge(ll_clk_i) then
			if ramRxAddrRst = '1' then
				v_cnt := (others => '0');
			elsif ramRxAddrInc = '1' then
				v_cnt := v_cnt + 1;
			end if;
		end if;
		
		ramRxAddr <= std_logic_vector( v_cnt(c_dpAddrBWidth-1 downto 0) );
--		ovflw <= std_logic( v_cnt(c_dpAddrBWidth) );
	end process p_addrIn;
	
	-- latch the frame size, add one so that actual number bytes reported
	p_addrSzReg : process(ll_clk_i)
	begin
		if rising_edge(ll_clk_i) then
			if rst = '1' then
				pktSz <= (others => '0');
			elsif txfrSzEn = '1' then
				pktSz <= ('0' & ramRxAddr) + 1;
			end if;
		end if;
	end process p_addrSzReg;
	
end architecture rtl;

