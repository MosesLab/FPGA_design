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
-- Module:		emacICMP.vhd
-- Parent:		N/A
-- Description: 
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-03-08	MF		Created
-- 2008-03-08	MF		Initial synthesis
-- 2008-03-19	MF		Simulation corrections
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ctiUtil.all;

library unisim;
use unisim.vcomponents.all;

----------------------------------------------------------------------------------
entity emacICMP is
----------------------------------------------------------------------------------
port
(       
	ll_clk_i : in std_logic;
	ll_reset_i : in std_logic;  -- should by synchronous.
	
	rx_ll_data : in  std_logic_vector(7 downto 0);
	rx_ll_sof_n : in  std_logic;
	rx_ll_eof_n : in  std_logic; 
	rx_ll_src_rdy_n: in  std_logic;
	rx_ll_dst_rdy_n : out std_logic;
	
	tx_ll_data : out std_logic_vector(7 downto 0);
	tx_ll_sof_n : out std_logic;
	tx_ll_eof_n : out std_logic; 
	tx_ll_src_rdy_n : out std_logic;
	tx_ll_dst_rdy_n : in  std_logic
);
end entity emacICMP;

----------------------------------------------------------------------------------
architecture rtl of emacICMP is

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	component kcpsm3 
	Port (      
		address : out std_logic_vector(9 downto 0);
		instruction : in std_logic_vector(17 downto 0);
		port_id : out std_logic_vector(7 downto 0);
		write_strobe : out std_logic;
		out_port : out std_logic_vector(7 downto 0);
		read_strobe : out std_logic;
		in_port : in std_logic_vector(7 downto 0);
		interrupt : in std_logic;
		interrupt_ack : out std_logic;
		reset : in std_logic;
		clk : in std_logic);
	end component kcpsm3;

	component ICMPProg
	Port (      
		address : in std_logic_vector(9 downto 0);
		instruction : out std_logic_vector(17 downto 0);
		clk : in std_logic);
	end component ICMPProg;
	
	constant c_dpAddrWidth : natural := 8;
	
component dp_a256x8_b256x8
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(7 downto 0);
	addra: IN std_logic_VECTOR(c_dpAddrWidth-1 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(7 downto 0);
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(c_dpAddrWidth-1 downto 0);
	addrb: IN std_logic_VECTOR(7 downto 0);
	web: IN std_logic_VECTOR(0 downto 0);
	doutb: OUT std_logic_VECTOR(7 downto 0));
end component dp_a256x8_b256x8;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- signal Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
	alias rst			is  ll_reset_i;
	alias clk			is  ll_clk_i;
	
	-- Signals used to connect KCPSM3 to program ROM and I/O logic
	signal  address         : std_logic_vector(9 downto 0);
	signal  instruction     : std_logic_vector(17 downto 0);
	signal  port_id         : std_logic_vector(7 downto 0);
	signal  out_port        : std_logic_vector(7 downto 0);
	signal  in_port         : std_logic_vector(7 downto 0);
	--signal  in_portq         : std_logic_vector(7 downto 0);
	signal  write_strobe    : std_logic;
	signal  read_strobe     : std_logic;
	signal  interrupt       : std_logic;
	signal  interrupt_ack   : std_logic;
	 
	 
	-- 
	signal tx_ll_eof_n_x : std_logic;
	signal tx_ll_sof_n_x : std_logic;
	signal rx_ll_dst_rdy_n_x : std_logic;
	signal tx_ll_src_rdy_n_x : std_logic;
	
	signal fifoStatus : std_logic_vector(7 downto 0);

	signal ramAddrA:  std_logic_VECTOR(c_dpAddrWidth-1 downto 0);
	signal ovflw : std_logic;
	signal tx_last : std_logic;
	signal ramWrA:  std_logic;
	
	signal ramDinB: std_logic_VECTOR(7 downto 0);
	signal ramAddrB:  std_logic_VECTOR(c_dpAddrWidth-1 downto 0);
	signal ramWrB:  std_logic;
	signal ramDoutB:  std_logic_VECTOR(7 downto 0);
	
	signal ramAddrAIncRx : std_logic;
	signal ramAddrAIncTx : std_logic;
	signal ramAddrAInc : std_logic;
	signal ramAddrARst : std_logic;
	
	
	signal txfrStatus : std_logic_VECTOR(7 downto 0);
	signal txfrCtrl : std_logic_VECTOR(7 downto 0);
	signal txfrSzEn : std_logic;
	signal txfrSz : std_logic_vector(c_dpAddrWidth-1 downto 0);
	
	type txfrState is (
						IDLE,
						RD_TRANSFER,
						RD_EOF,
						RD_ERROR_WAIT,
						RD_DRAIN,
						WR_WAIT,
						WR_TRANSFER,
						WR_EOF
						);
						
	signal state : txfrState;
	signal nextState : txfrState;
						
	constant c_idle : natural := 0;
	constant c_rdTransfer : natural := 1;
	constant c_rdEof : natural := 2;
	constant c_rdError : natural := 3;
	constant c_wrWait : natural := 4;
	constant c_wrTransfer : natural := 5;
	constant c_wrEof : natural := 6;
	constant c_dpAccess : natural := 7;
	
	constant c_dpSize :  std_logic_VECTOR(c_dpAddrWidth-1 downto 0) := (others => '1');
	constant c_icmpData :  std_logic_VECTOR(c_dpAddrWidth-1 downto 0) := x"28"; -- ICMP data0 field
	
	constant c_txfrCtrlStart : natural := 0;
	constant c_txfrCtrlSkip : natural := 1;
	constant c_txfrCtrlDone : natural := 2;
	
begin

	-- Assign intermidiate outputs to outputs
	rx_ll_dst_rdy_n <= rx_ll_dst_rdy_n_x;
	tx_ll_eof_n <= tx_ll_eof_n_x;
	tx_ll_sof_n <= tx_ll_sof_n_x;
	tx_ll_src_rdy_n <= tx_ll_src_rdy_n_x;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Memory buffer
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	u_dp : dp_a256x8_b256x8
		port map (
			clka => clk,
			dina => rx_ll_data ,
			addra => ramAddrA,
			wea(0) => ramWrA,
			douta => tx_ll_data,
			
			clkb => clk,
			dinb => ramDinB,
			addrb => ramAddrB,
			web(0) => ramWrB,
			doutb => ramDoutB
		);	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Fifo ctrl statemachine
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	-- State register
	p_stateReg : process(clk)
	begin
		if rising_edge(clk) then
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
							txfrCtrl,
							state,
							ramAddrA,
							--txfrSz,
							tx_ll_dst_rdy_n,
							tx_last
						)
	begin
		case state is
			-----------------------------
			-- wait for the SOF
			when IDLE =>
				if (rx_ll_sof_n = '0' and rx_ll_src_rdy_n = '0') then
					nextState <= RD_TRANSFER;
				else
					nextState <= IDLE;
				end if;
				
			-----------------------------			
			-- store data until EOF
			when RD_TRANSFER =>
				if (rx_ll_src_rdy_n = '0') then
					if ( rx_ll_eof_n = '0' ) then
						nextState <= RD_EOF;
					else
						if (ramAddrA >= c_dpSize) then
							nextState <= RD_DRAIN;
						else
							nextState <= RD_TRANSFER;						
						end if;
					end if;
				else
						nextState <= RD_TRANSFER;
				end if;			
				
			-----------------------------			
			-- wait state, may not be necessary
			when RD_EOF =>
					nextState <= WR_WAIT;
					
			-----------------------------	
			-- drain the fifo
			when RD_DRAIN =>
				if  ( rx_ll_eof_n = '0' ) then
					nextState <= RD_ERROR_WAIT;
				else
					nextState <= RD_DRAIN;
				end if;
				
			-----------------------------	
			-- if in read error (overflow), wait until ack'd by processor
			when RD_ERROR_WAIT =>
				if (txfrCtrl(c_txfrCtrlSkip) = '1') then
					nextState <= WR_EOF;
				else
					nextState <= RD_ERROR_WAIT;
				end if;
					
			-----------------------------
			-- wait until controller says to start write
			when WR_WAIT =>
				if (txfrCtrl(c_txfrCtrlStart) = '1') then
					nextState <= WR_TRANSFER;
				elsif (txfrCtrl(c_txfrCtrlSkip) = '1') then
					nextState <= WR_EOF;
				else
					nextState <= WR_WAIT;
				end if;		
				
			-----------------------------			
			-- transfer until address
			when WR_TRANSFER =>
				-- note that ramAddrA is preincremented to account for ram latency
				-- therefore data(ramAddrA) appears at next clock
				if (tx_last='1' and tx_ll_dst_rdy_n = '0') then
					nextState <= WR_EOF;
				else
					nextState <= WR_TRANSFER;				
				end if;
				
			-----------------------------			
			when WR_EOF =>
				if (txfrCtrl(c_txfrCtrlDone) = '1') then
					nextState <= IDLE;
				else
					nextState <=WR_EOF;
				end if;
				
			-----------------------------			
			when others =>
				nextState <= IDLE;
		end case;
	end process p_nextState;
	
	-- State machine outputs
	
	-- State status
	txfrStatus(c_idle) <= '1' when state = IDLE else '0';
	txfrStatus(c_rdTransfer) <= '1' when state = RD_TRANSFER else '0';
	txfrStatus(c_rdEof) <= '1' when state = RD_EOF else '0';
	txfrStatus(c_rdError) <= '1' when state = RD_ERROR_WAIT else '0';
	txfrStatus(c_wrWait) <= '1' when state = WR_WAIT else '0';
	txfrStatus(c_wrTransfer) <= '1' when state = WR_TRANSFER else '0';
	txfrStatus(c_wrEof) <= '1' when state = WR_EOF else '0';
	
	-- Receive
	rx_ll_dst_rdy_n_x <= '0' when state = IDLE or state = RD_TRANSFER or state = RD_DRAIN else '1';
									-- need read error so that we can empty out fifo
	
	ramAddrAIncRx <= '1' when (state = IDLE and rx_ll_sof_n = '0' and rx_ll_src_rdy_n = '0') or
							(state = RD_TRANSFER and rx_ll_src_rdy_n = '0' and rx_ll_eof_n = '1') else '0';
	
	ramWrA <= '1' when (state = IDLE and rx_ll_sof_n = '0' and rx_ll_src_rdy_n = '0') or
							(state = RD_TRANSFER and rx_ll_src_rdy_n = '0') else '0';
	
	txfrSzEn <= '1' when	(state = RD_EOF) else '0';
	
	-- Transmit
	ramAddrAIncTx <= '1' when (state = WR_TRANSFER and tx_ll_dst_rdy_n = '0') or 
								(state = WR_WAIT and tx_ll_dst_rdy_n = '0' and txfrCtrl(c_txfrCtrlStart) = '1') else '0';
	
	tx_ll_src_rdy_n_x <= '0' when (state = WR_TRANSFER) else '1';
	tx_ll_sof_n_x <= '0' when (state = WR_TRANSFER and tx_ll_dst_rdy_n = '0' and ramAddrA = x"01") else '1';
																					-- note that this used to be addr x00
																					-- however, addr is preincemneted in last wait state
	tx_ll_eof_n_x <= '0' when (state = WR_TRANSFER and tx_ll_dst_rdy_n = '0' and tx_last='1') else '1';
	
	
	tx_last <= '1' when (ramAddrA > txfrSz) or (ovflw = '1' and txfrSz = c_dpSize) else '0';
	
	-- Common
	ramAddrAInc <= ramAddrAIncRx or ramAddrAIncTx;
	ramAddrARst <= '1' when (state = RD_EOF or state = WR_EOF or rst = '1') else '0';
				
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Counters and status regs
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	-- addrA counter
	p_addrIn : process(clk)
		variable v_cnt : unsigned(c_dpAddrWidth downto 0);
						-- one more bit than address width
	begin
		if rising_edge(clk) then
			if ramAddrARst = '1' then
				v_cnt := (others => '0');
			elsif ramAddrAInc = '1' then
				v_cnt := v_cnt + 1;
			end if;
		end if;
		
		ramAddrA <= std_logic_vector( v_cnt(c_dpAddrWidth-1 downto 0) );
		ovflw <= std_logic( v_cnt(c_dpAddrWidth) );
	end process p_addrIn;
	
	-- latch the ICMP frame size
	p_addrSzReg : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				txfrSz <= (others => '0');
			elsif txfrSzEn = '1' then
				txfrSz <= ramAddrA;
			end if;
		end if;
	end process p_addrSzReg;
	
	-- dual port address latch
	p_dpAccess : process(clk)
	begin
		if rising_edge(clk) then
			if state = IDLE then
				txfrStatus(c_dpAccess) <= '0';
			elsif ramAddrA >= c_icmpData then
				txfrStatus(c_dpAccess) <= '1'; 
			end if;
		end if;
	end process p_dpAccess;
	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- KCPSM3 and the program memory 
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	interrupt <= '0';
	
	processor: kcpsm3
	port map(      
		address			=> address,
		instruction		=> instruction,
		port_id			=> port_id,
		write_strobe	=> write_strobe,
		out_port		=> out_port,
		read_strobe		=> read_strobe,
		in_port			=> in_port,
		interrupt		=> interrupt,
		interrupt_ack 	=> interrupt_ack,
		reset			=> rst,
		clk				=> clk
	);
	
	program_rom: ICMPProg
	port map(      
		address		=> address,
		instruction	=> instruction,
		clk			=> clk
	);

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- input ports 
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	fifoStatus(0) <= rx_ll_sof_n;
	fifoStatus(1) <= rx_ll_eof_n;
	fifoStatus(2) <= rx_ll_src_rdy_n;
	fifoStatus(3) <= rx_ll_dst_rdy_n_x;
	fifoStatus(4) <= tx_ll_sof_n_x;
	fifoStatus(5) <= tx_ll_eof_n_x;
	fifoStatus(6) <= tx_ll_src_rdy_n_x;
	fifoStatus(7) <= tx_ll_dst_rdy_n;
	
	-- The inputs connect via a pipelined multiplexer
	p_input_ports: process(clk)
	begin
		if rising_edge(clk) then

			--if port_id(2) = '0' then
				case port_id(1 downto 0) is
					when "00" =>	in_port <= fifoStatus;
					when "01" =>	in_port <= txfrStatus;
					when "10" =>	in_port <= ramDoutB;
					when "11" =>	in_port <= txfrSz;	
					--when "100" =>	in_port <= "000000" & txfrSz(8);	
					--when "101" => 	in_port <= ;		
					-- when "110" =>	in_port <= ;  
					-- when "111" =>	in_port <= ;  					
					when others =>	in_port <= (others => '0');  
				end case;	
		end if;
	end process p_input_ports;

    -- For memory FIFO  (was registered inside process above )
	-- Note: if fifos are implemented as memory (ie. from coregen)
	-- then data is only available AFTER read strobe.
	-- therefore, the FIFO output can't be registered through the mux.

	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- output ports (these are output registers)
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	p_output_ports: process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then				
				txfrCtrl <= (others => '0');
				ramAddrB <= (others => '0');
			elsif write_strobe='1' then
				if port_id(0) = '1' then
					txfrCtrl <= out_port;
				end if;
				
				if port_id(1) = '1' then
					ramAddrB <= out_port;
				end if;
			end if;
		end if; 
	end process p_output_ports;

	ramWrB <= '1' when (write_strobe='1' and port_id(2)='1') else '0';
	ramDinB <= out_port;
	
end architecture rtl;

