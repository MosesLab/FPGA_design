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

entity reg32_ReadWrite is
	 port ( 
		clk 				: in  std_logic;	-- System clock signal
		rst_n				: in  std_logic;	-- Active-low reset signal
		wren	 			: in 	std_logic;	-- Register bank select signal
		lb_lben			: in	std_logic_vector(3 downto 0);
		user_D	 		: in  std_logic_vector(31 downto 0);	-- This is the register bank input signals that can be mapped to logic in the user design
		user_Q	 		: out std_logic_vector(31 downto 0)	-- This is the register bank output signals that can be mapped to logic in the user design
		
	);
end reg32_ReadWrite;

architecture rtl of reg32_ReadWrite is

begin
	p_reg : process(clk, rst_n)
		begin
		if (rst_n = '0') then
				user_Q <= (others => '0');	-- IN SOUNDING ROCKET APPLICATION THIS MAY NEED TO BE DIFFERENT IF NOT ALL OUTPUTS SHOULD BE ZERO...
		elsif (clk'event) and (clk = '1') then 
			
			if (wren = '1') then	
				if (lb_lben(3) = '0') then
					user_Q(31 downto 24) <= user_D(31 downto 24);
				end if;

				if (lb_lben(2) = '0') then
					user_Q(23 downto 16) <= user_D(23 downto 16);
				end if;

				if (lb_lben(1) = '0') then
					user_Q(15 downto 8) <= user_D(15 downto 8);
				end if;

				if (lb_lben(0) = '0') then
					user_Q(7 downto 0) <= user_D(7 downto 0);
				end if;
				
			end if;						
		end if;
	end process;
			
end rtl;

