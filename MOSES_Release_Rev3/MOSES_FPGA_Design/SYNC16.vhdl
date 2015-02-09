----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:06:29 08/22/2014 
-- Design Name: 
-- Module Name:    SYNC - Behavioral 
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

entity SYNC16 is
    Port ( clk : in  std_logic;
           rst_n : in  std_logic;
           data_in : in  std_logic_vector(15 downto 0);
           data_out : out  std_logic_vector(15 downto 0));
end SYNC16;

architecture Behavioral of SYNC16 is

	component REG16
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC_VECTOR (15 downto 0);
			  Q : out  STD_LOGIC_VECTOR (15 downto 0));
	end component;

	signal	data_out_signal	:std_logic_vector(15 downto 0);

begin

	REG0	:	REG16
		port map(clk,rst_n,data_in,data_out_signal);
	
	REG1	:	REG16
		port map(clk,rst_n,data_out_signal,data_out);
	
end Behavioral;

