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
-- Module:		emacTx.vhd
-- Parent:		N/A
-- Description: 
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-08-17	MF		Created
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ctiUtil.all;

library unisim;
use unisim.vcomponents.all;

----------------------------------------------------------------------------------
entity emacTx is
----------------------------------------------------------------------------------
generic 
(
	c_dpAddrBWidth : natural := 5 -- dpRam is 2^c_dpAddrBWidth = 32
);
port
(       
	ll_clk_i : in std_logic;
	ll_reset_i : in std_logic;  -- should by synchronous.
	
	--lb_clk : in std_logic;
	--lb_rst : in std_logic;	
	lb_di : in std_logic_vector(31 downto 0);
	lb_do : out std_logic_vector(31 downto 0);	
	lb_a : in std_logic_vector(2 downto 0);
	lb_en : in std_logic;	
	lb_wr : in std_logic_vector(3 downto 0);
	
	pktSend : in std_logic;
	pktSz : in std_logic_vector(c_dpAddrBWidth downto 0);  --> 1 based
	pktDone : out std_logic;
	
	tx_ll_data : out std_logic_vector(7 downto 0);
	tx_ll_sof_n : out std_logic;
	tx_ll_eof_n : out std_logic; 
	tx_ll_src_rdy_n : out std_logic;
	tx_ll_dst_rdy_n : in  std_logic
);
end entity emacTx;

----------------------------------------------------------------------------------
architecture rtl of emacTx is

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
		
	signal rst	: std_logic;


	signal tx_ll_eof_n_x : std_logic;
	signal tx_ll_sof_n_x : std_logic;
	signal tx_ll_src_rdy_n_x : std_logic;
	

	constant c_dpSize :  std_logic_VECTOR(c_dpAddrBWidth-1 downto 0) := (others => '1');
	
	signal ovflw : std_logic;
	signal tx_last : std_logic;
	
	signal ramTxAddr:  std_logic_VECTOR(c_dpAddrBWidth-1 downto 0);
	signal ramTxAddrInc : std_logic;
	signal ramTxAddrRst : std_logic;
	
		
	type txfrState is (
						IDLE,
						WR_WAIT,
						WR_TRANSFER,
						WR_EOF
						);
		
	signal state : txfrState;
	signal nextState : txfrState;
	
--	signal pktSend_r :  std_logic;
--	signal pktSend_r2 :  std_logic;
--	
--	signal pktSz_r :  std_logic_vector(c_dpAddrBWidth downto 0);  	
--	signal pktSz_r2 :  std_logic_vector(c_dpAddrBWidth downto 0);  
	
	signal pktSzAdj :  std_logic_vector(c_dpAddrBWidth downto 0);  

--	signal done :  std_logic;
--	signal done_r :  std_logic;
--	alias done_r2 is pktDone;	
--						
--	signal lb_rst_r : std_logic;
--	signal lb_rst_r2 : std_logic;
	
begin

	rst <= ll_reset_i;

	-- Assign intermidiate outputs to outputs

	tx_ll_eof_n <= tx_ll_eof_n_x;
	tx_ll_sof_n <= tx_ll_sof_n_x;
	tx_ll_src_rdy_n <= tx_ll_src_rdy_n_x;

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
			 dinb => x"00",
			 addrb => ramTxAddr,
			 web(0) => '0',
			 doutb => tx_ll_data
		 );	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Clock domain crossing
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

-- ll and lb are same clock domain

--	p_lbtoll : process(ll_clk_i)
--	begin
--		if rising_edge(ll_clk_i) then
--			-- Note pktSz may or may not be settled by the time pktSend is set
--			-- fifo would be best approach
--			-- however, there is an extra state, WR_WAIT, so it should be fine
--			pktSend_r <= pktSend;
--			pktSend_r2 <= pktSend_r;				
--			
--			pktSz_r <= pktSz;
--			pktSz_r2 <= pktSz_r;	
--			
--			lb_rst_r <= lb_rst;
--			lb_rst_r2 <= lb_rst_r;				
--		end if;
--	end process;
	
	pktSzAdj <= pktSz - 1;
	
--	p_lltolb : process(lb_clk)
--	begin
--		if rising_edge(lb_clk) then
--			done_r <= done;
--			done_r2 <= done_r;			
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
							state,
							pktSend,
							tx_ll_dst_rdy_n,
							tx_last
						)
	begin
		case state is
			-----------------------------
			-- wait for the SOF
			when IDLE =>
				if (pktSend = '1') then
					nextState <= WR_WAIT;
				else
					nextState <= IDLE;
				end if;
				
			-----------------------------			
			when WR_WAIT =>
					nextState <= WR_TRANSFER;
	
				
			-----------------------------			
			-- transfer until address
			when WR_TRANSFER =>
				-- note that ramTxAddr is preincremented to account for ram latency
				-- therefore data(ramTxAddr) appears at next clock
				if (tx_last='1' and tx_ll_dst_rdy_n = '0') then
					nextState <= WR_EOF;
				else
					nextState <= WR_TRANSFER;				
				end if;
				
			-----------------------------			
			when WR_EOF =>
				if (pktSend = '0') then
					nextState <= IDLE;
				else
					nextState <=WR_EOF;
				end if;
				
			-----------------------------			
			when others =>
				nextState <= IDLE;
		end case;
	end process p_nextState;
	
	
	-- Transmit
	ramTxAddrInc <= '1' when (state = WR_TRANSFER and tx_ll_dst_rdy_n = '0') or 
								(state = WR_WAIT and tx_ll_dst_rdy_n = '0') else '0';
	
	tx_ll_src_rdy_n_x <= '0' when (state = WR_TRANSFER) else '1';
	tx_ll_sof_n_x <= '0' when (state = WR_TRANSFER and tx_ll_dst_rdy_n = '0' and ramTxAddr = x"01") else '1';
																					-- note that this used to be addr x00
																					-- however, addr is preincemneted in last wait state
	tx_ll_eof_n_x <= '0' when (state = WR_TRANSFER and tx_ll_dst_rdy_n = '0' and tx_last='1') else '1';
	
	tx_last <= '1' when (('0' & ramTxAddr) > pktSzAdj ) or
					 ((ovflw = '1') and (pktSzAdj = ('0' & c_dpSize))) else '0';
	
	pktDone <= '1' when (state = WR_EOF) else '0';
	
	-- Common

	ramTxAddrRst <= '1' when (state = WR_EOF or rst = '1') else '0';
				
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Counters and status regs
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	-- addrA counter
	p_addrIn : process(ll_clk_i)
		variable v_cnt : unsigned(c_dpAddrBWidth downto 0);
						-- one more bit than address width
	begin
		if rising_edge(ll_clk_i) then
			if ramTxAddrRst = '1' then
				v_cnt := (others => '0');
			elsif ramTxAddrInc = '1' then
				v_cnt := v_cnt + 1;
			end if;
		end if;
		
		ramTxAddr <= std_logic_vector( v_cnt(c_dpAddrBWidth-1 downto 0) );
		ovflw <= std_logic( v_cnt(c_dpAddrBWidth) );
	end process p_addrIn;
	
	
end architecture rtl;

