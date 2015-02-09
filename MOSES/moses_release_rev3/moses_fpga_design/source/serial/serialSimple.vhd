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
-- Project: 	FreeForm/PCI-104
-- Module:		serialSimple
-- Parent:		N/A
-- Description: Register interface to simple UARTs with 16 byte fifo.
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-04-18	MF		Created
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.ctiUtil.all;

library UNISIM;
use UNISIM.Vcomponents.all;

----------------------------------------------------------------------------------
entity serialSimple is
----------------------------------------------------------------------------------
Port ( 
	rstn 		: in  std_logic; -- assume reset is asynch
	clk 		: in  std_logic;
	rx 			: in  std_logic;
	tx 			: out std_logic;
	renn		: out std_logic;
	ten 		: out std_logic;
	baudSet   	: in std_logic_vector(7 downto 0);
	tx_data		: in std_logic_vector(7 downto 0);
	rx_data		: out std_logic_vector(7 downto 0);
	ctrl		: in std_logic_vector(7 downto 0);
	status		: out std_logic_vector(7 downto 0)
);
end entity serialSimple;

----------------------------------------------------------------------------------
architecture rtl of serialSimple is
----------------------------------------------------------------------------------
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Component declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- declaration of UART transmitter with integral 16 byte FIFO buffer
	-- Note this is a modified version of the standard 'uart_tx' in which
	-- the 'data_present' signal has also been brought out to better support 
	-- the XON/XOFF flow control.
	--  
	component uart_tx_plus
	Port (              
		data_in : in std_logic_vector(7 downto 0);
		write_buffer : in std_logic;
		reset_buffer : in std_logic;
		en_16_x_baud : in std_logic;
		serial_out : out std_logic;
		buffer_data_present : out std_logic;
		buffer_full : out std_logic;
		buffer_half_full : out std_logic;
		clk : in std_logic
	);
	end component uart_tx_plus;
	
	--
	-- declaration of UART Receiver with integral 16 byte FIFO buffer
	--
	component uart_rx
	Port (            
		serial_in : in std_logic;
		data_out : out std_logic_vector(7 downto 0);
		read_buffer : in std_logic;
		reset_buffer : in std_logic;
		en_16_x_baud : in std_logic;
		buffer_data_present : out std_logic;
		buffer_full : out std_logic;
		buffer_half_full : out std_logic;
		clk : in std_logic
	);
	end component;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Signal / Constant declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	signal en_16_x_baud : std_logic;
	
	signal tx_wr : std_logic;
	signal tx_data_present : std_logic;
	signal tx_full : std_logic;
	signal tx_half_full : std_logic;
	
	signal rx_rd : std_logic;
	signal rx_data_present : std_logic;
	signal rx_full : std_logic;
	signal rx_half_full : std_logic;	
	
	signal rst : std_logic;
	signal baudCntMax   : std_logic_vector(7 downto 0);
	signal ctrlPrev   : std_logic_vector(7 downto 0);

----------------------------------------------------------------------------------
begin -- architecture
----------------------------------------------------------------------------------

	rst <= not rstn;

	-- enable both transmit and recv
	renn	<= '0';
	ten <= '1';

	-- status
	status(0) <= tx_data_present;
	status(1) <= tx_full;
	status(2) <= tx_half_full;
	status(3) <= '0';
	status(4) <= rx_data_present;
	status(5) <= rx_full;
	status(6) <= rx_half_full;
	status(7) <= '0';
	
	-- ctrl
	p_ctrlPrev : process(clk)
	begin
		if rising_edge(clk) then
			ctrlPrev <= ctrl;
		end if;
	end process;
	
	tx_wr <= ctrl(0) and not ctrlPrev(0);
	rx_rd <= ctrl(1) and not ctrlPrev(1);
	
	-- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
	-- Each contains an embedded 16-byte FIFO buffer.

	u_tx_uart : uart_tx_plus 
	port map (              
		data_in => tx_data, 
		write_buffer => tx_wr,
		reset_buffer => rst, --'0',
		en_16_x_baud => en_16_x_baud,
		serial_out => tx,
		buffer_data_present => tx_data_present,
		buffer_full => tx_full,
		buffer_half_full => tx_half_full,
		clk => clk 
	);
	
	u_rx_uart : uart_rx
	port map (            
		serial_in => rx,
		data_out => rx_data,
		read_buffer => rx_rd,
		reset_buffer => rst, --'0',
		en_16_x_baud => en_16_x_baud,
		buffer_data_present => rx_data_present,
		buffer_full => rx_full,
		buffer_half_full => rx_half_full,
		clk => clk );  
  
	-- Set baud rate to 115200 for the UART communications
	-- Requires en_16_x_baud to be 1843200Hz which is a single cycle pulse every 27 cycles at 50MHz 
	-- 27 = 0x1B
	-- For 1 Mbit, en_16_x_baud = 16 Mhz?
	
	baudCntMax <= x"1B" when baudSet = x"00" else baudSet; 
	
	p_baud : process(clk)
		variable baud_count : unsigned(7 downto 0) := x"00";
	begin
		if rising_edge(clk) then
			if baud_count=unsigned(baudCntMax) then
				baud_count := x"00";
				en_16_x_baud <= '1';
			else
				baud_count := baud_count + 1;
				en_16_x_baud <= '0';
			end if;
		end if;
	end process p_baud;	

end architecture rtl;

