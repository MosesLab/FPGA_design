----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:35:05 08/25/2014 
-- Design Name: 
-- Module Name:    ADDRESS_GENERATOR - Behavioral 
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

entity ADDRESS_GENERATOR is
    Port ( clk 		: 	in  	std_logic;
           rst_n 		:	in  	std_logic;
           addr_rst 	:	in  	std_logic;
			  addr_inc	:	in		std_logic;
           addr 		: 	out  	std_logic_vector (30 downto 0));
end ADDRESS_GENERATOR;

architecture Behavioral of ADDRESS_GENERATOR is
	signal 	addr_signal	:unsigned(30 downto 0) := (others => '0');
begin

	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			addr_signal <= (others =>'0');
		elsif (clk'event and clk = '1') then
			if (addr_rst = '1') then
				addr_signal <= (others => '0');
			elsif (addr_inc = '1') then
				addr_signal <= addr_signal + 1;
			end if;
		end if;
	end process;
	
	addr <= std_logic_vector(addr_signal);

end Behavioral;

