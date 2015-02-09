----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:07:38 08/22/2014 
-- Design Name: 
-- Module Name:    COUNTER - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity COUNTER is
	Generic(TERMINAL_COUNT	:integer := 4);
   Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           en : in  STD_LOGIC;
           flag : out  STD_LOGIC);
end COUNTER;

architecture Behavioral of COUNTER is
	signal count	:unsigned(7 downto 0) := (others => '0');
begin
	
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			count  <= (others => '0');
			flag <= '0';
		elsif (clk'event and clk = '1') then
			flag <= '0';
			if (en = '1') then
					count <= count + 1;
				if (count = (TERMINAL_COUNT - 1)) then
					count <= (others => '0');
					flag <= '1';
				end if;
			end if;
		end if;
	end process;


end Behavioral;

