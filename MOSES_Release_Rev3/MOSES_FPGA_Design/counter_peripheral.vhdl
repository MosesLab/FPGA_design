----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:57:12 07/22/2014 
-- Design Name: 
-- Module Name:    counter_peripheral - Behavioral 
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

entity counter_peripheral is
	port(
		clk	: in	std_logic;
		rst_n	: in	std_logic;
		count_overflow	:out	std_logic
	);
end counter_peripheral;

architecture Behavioral of counter_peripheral is
	signal	count		:integer range 0 to (2**26) - 1 := 0;
begin
	
	process(clk,rst_n) is
	begin

		if (rst_n = '0') then
			count <= 0;
			count_overflow <= '0';
		elsif rising_edge(clk) then			
			if (count = 50000000) then
				count <= 0;
				count_overflow <= '1';
			else
				count <= count + 1;
				count_overflow <= '0';
			end if;
		end if;
	end process;

end Behavioral;

