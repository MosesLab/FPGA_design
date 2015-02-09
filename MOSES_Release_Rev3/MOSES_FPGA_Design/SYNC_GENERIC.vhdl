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

entity SYNC_GENERIC is
	 Generic (WIDTH	:integer := 8);
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
           data_out : out  STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0));
end SYNC_GENERIC;

architecture Behavioral of SYNC_GENERIC is

	component REG_GENERIC
		 Generic (WIDTH	:integer := 8);
		 Port ( clk : in  STD_LOGIC;
				  rst_n : in  STD_LOGIC;
				  D : in  STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
				  Q : out  STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0));
	end component;

	signal	data_out_signal	:std_logic_vector(WIDTH - 1 downto 0);

begin

	REG0	:	REG_GENERIC
		generic map (WIDTH => WIDTH)
		port map(clk,rst_n,data_in,data_out_signal);
	
	REG1	:	REG_GENERIC
		generic map (WIDTH => WIDTH)
		port map(clk,rst_n,data_out_signal,data_out);
	
end Behavioral;

