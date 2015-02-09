----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:23:39 07/02/2014 
-- Design Name: 
-- Module Name:    Reg32_JAH - Behavioral 
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

entity Reg32_JAH is
	port(
			clk		:in	std_logic;	--Input clock
			rst_n		:in	std_logic;	--Active-low reset signal			
			D32		:in	std_logic_vector(31 downto 0);	--32-bit input data vector
			Q32		:out	std_logic_vector(31 downto 0);	--32-bit output data vector
			WE_N		:in	std_logic	--Active-low write enable
		);
		
end Reg32_JAH;

architecture Behavioral of Reg32_JAH is
begin

	REG0	:	process(clk,rst_n) is
	begin
		if (clk'event) and (clk = '1') then
			if (rst_n = '0') then
				Q32 <= (others => '0');
			else
				if (WE_N = '1') then
					Q32 <= D32;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

