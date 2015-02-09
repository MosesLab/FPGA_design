----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:46:58 08/22/2014 
-- Design Name: 
-- Module Name:    SHIFT_REG32 - Behavioral 
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

entity SHIFT_REG32 is
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (15 downto 0);
           Q : out  STD_LOGIC_VECTOR (31 downto 0);
           en : in  STD_LOGIC);
end SHIFT_REG32;

architecture Structural of SHIFT_REG32 is
	
	component REG16_EN
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC_VECTOR (15 downto 0);
			  Q : out  STD_LOGIC_VECTOR (15 downto 0);
			  en : in  STD_LOGIC);
	end component;
	
	signal	shift_data0	:std_logic_vector(15 downto 0) := (others => '0');
	signal	shift_data1	:std_logic_vector(15 downto 0) := (others => '0');

begin

	REG0	:	REG16_EN
		port map(clk,rst_n,D,shift_data1,en);
		
	REG1	:	REG16_EN
		port map(clk,rst_n,shift_data1,shift_data0,en);
	
	Q(15 downto 0) <= shift_data0;
	Q(31 downto 16) <= shift_data1;

end Structural;
