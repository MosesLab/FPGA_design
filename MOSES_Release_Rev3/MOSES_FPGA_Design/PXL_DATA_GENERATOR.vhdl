----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:58:41 08/27/2014 
-- Design Name: 
-- Module Name:    PXL_DATA_GENERATOR - Behavioral 
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

entity PXL_DATA_GENERATOR is
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           re : in  STD_LOGIC;
			  fe	:	in	std_logic;
           data : out  STD_LOGIC_VECTOR (15 downto 0);
			  clock	:	out	std_logic);
end PXL_DATA_GENERATOR;

architecture Behavioral of PXL_DATA_GENERATOR is
	
	signal address_bits	:unsigned(1 downto 0) := "00";
	signal data_bits		:unsigned(13 downto 0);

begin

	-- FRAME ADDRESS BITS COUNTER
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			address_bits <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (re = '1') then
				address_bits <= address_bits + 1;
				if (address_bits = 3) then
					address_bits <= (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	-- DATA BITS PROCESS
	process(clk,rst_n) is
	begin 
		if (rst_n = '0') then
			data_bits <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (re = '1') then
				if (address_bits = 3) then
					data_bits <= data_bits + 1;
					if (data_bits = 2047) then
						data_bits <= (others => '0');
					end if;
				end if;
			end if;			
		end if;
	end process;
	
	-- CLOCK PROCESS
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			clock <= '1';
		elsif (clk'event and clk = '1') then
			if (re = '1') then
				clock <= '1';
			elsif (fe = '1') then
				clock <= '0';
			end if;
		end if;
	end process;
	
	data <= std_logic_vector(address_bits) & std_logic_vector(data_bits);

	

end Behavioral;

