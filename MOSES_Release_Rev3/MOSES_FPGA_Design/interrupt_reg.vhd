----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:52:28 07/21/2014 
-- Design Name: 
-- Module Name:    interrupt_logic - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity interrupt_reg is
	port(
		clk				:in	std_logic;
		rst_n				:in	std_logic;
		set				:in	std_logic;
		clear				:in	std_logic;
		interrupt		:out	std_logic
	);
end interrupt_reg;

architecture Behavioral of interrupt_reg is

begin

	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			interrupt <= '0';
		elsif (clk'event and clk = '1') then
			if (set = '1' and clear = '0') then
				interrupt <= '1';	
			elsif (set = '0' and clear = '1') then
				interrupt <= '0';
			else
				interrupt <= '0';
			end if;
		end if;
	end process;


end Behavioral;

