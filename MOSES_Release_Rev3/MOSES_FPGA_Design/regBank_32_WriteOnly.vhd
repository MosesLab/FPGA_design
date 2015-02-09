--********************************************************************************
-- Copyright © 2008 Connect Tech inc. All Rights Reserved. 
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH inC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary information of Connect Tech, inc
-- and should be treated as Confidential.
--
--********************************************************************************
-- Project: 	FreeForm/PCI-104
-- Module:		regBank_32
-- Parent:		(any)
-- Description: Configurable 32 bit register bank
--
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-03-05	MF		If the register bank is not enabled; output 0xDDDDDDDD
--********************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regBank_32_WriteOnly is
	generic	(
		selWidth 		: natural := 5
	);
	 port ( 
		clk 				: in  std_logic;	-- System clock signal
		rst_n				: in  std_logic;	-- Active-low reset signal
		enable 			: in 	std_logic;	-- Register bank select signal
		reg_addr			: in  std_logic_vector((selWidth-1) downto 0);	-- This is the register address that specified by the Local Bus
		user_D	 		: in  std_logic_vector(31 downto 0);	-- This is the register bank input signals that can be mapped to logic in the user design
		user_Q	 		: out std_logic_matrix_32 (((2**selWidth)-1) downto 0)	-- This is the register bank output signals that can be mapped to logic in the user design
	);
end regBank_32_WriteOnly;

architecture rtl of regBank_32_WriteOnly is

	component XTo1Mux_32
		generic (	selWidth : natural := 3 );
		port (
			sel : in std_logic_vector(selWidth-1 downto 0);
			din : in std_logic_matrix_32((2**selwidth)-1 downto 0);
			dout : out std_logic_vector(31 downto 0)
		);
	end component;

	constant	numReg 			: natural := (2**selWidth);
	signal	lb_ld_signal	: std_logic_vector(31 downto 0);
	signal	write_enable	: std_logic_vector((2**selWidth - 1) downto 0);

begin

	g_regs : for i in 0 to (numReg-1) generate
			
			write_enable(i) <= '1' when (reg_addr = std_logic_vector(to_unsigned(i,selWidth)) and enable = '1') else '0';
		
			p_reg : process(clk, rst_n)
				begin
				if (rst_n = '0') then
				   	user_Q(i) <= (others => '0');	-- IN SOUNDING ROCKET APPLICATION THIS MAY NEED TO BE DIFFERENT IF NOT ALL OUTPUTS SHOULD BE ZERO...
				elsif (clk'event) and (clk = '1') then 
					if (write_enable(i) = '1') then					
						user_Q(i) <= user_D;
					end if;						
				end if;
			end process;
			
	end generate;
	
end rtl;

