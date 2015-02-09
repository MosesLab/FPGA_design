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

entity interrupt_logic is
	port(
		clk				:in	std_logic;
		rst_n				:in	std_logic;
		set				:in	std_logic_vector(31 downto 0);
		clear				:in	std_logic_vector(31 downto 0);
		interrupt		:out	std_logic_vector(31 downto 0)
	);
end interrupt_logic;

architecture Behavioral of interrupt_logic is

begin

	gen_int	:	for i in 0 to 31 generate

	INTPROC	:	process(clk,rst_n) is
		begin
			if (rst_n = '0') then
				interrupt(i) <= '0';
			elsif (clk'event and clk = '1') then
				if (set(i) = '1' and clear(i) = '0') then
					interrupt(i) <= '1';	
				elsif (set(i) = '0' and clear(i) = '1') then
					interrupt(i) <= '0';
				end if;
			end if;
		end process;
		
	end generate;
end Behavioral;

