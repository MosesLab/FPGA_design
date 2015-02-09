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

entity reg32_ReadOnly is
	 port ( 
		clk 				: in  std_logic;	-- System clock signal
		rst_n				: in  std_logic;	-- Active-low reset signal
		user_D	 		: in  std_logic_vector(31 downto 0);	-- This is the register bank input signals that can be mapped to logic in the user design
		user_Q	 		: out std_logic_vector(31 downto 0);	-- This is the register bank output signals that can be mapped to logic in the user design
		interrupt		: out	std_logic_vector(31 downto 0)
	);
end reg32_ReadOnly;

architecture rtl of reg32_ReadOnly is

	signal user_Q_signal :	std_logic_vector(31 downto 0);

begin
	
		
		process(clk, rst_n) is
		begin
			if (rst_n = '0') then
					user_Q_signal <= (others => '0');
			elsif (clk'event) and (clk = '1') then 
					user_Q_signal <= user_D;				
			end if;
		end process;
		
		process(clk,rst_n) is
		begin
			if (rst_n = '0') then
				interrupt <= (others => '0');
			elsif (clk'event) and (clk = '1') then
				interrupt <= (not user_Q_signal) and user_D; -- Interrupt only on transition from '0' to '1'
			end if;
		end process;
		
		user_Q <= user_Q_signal;
	
end rtl;

