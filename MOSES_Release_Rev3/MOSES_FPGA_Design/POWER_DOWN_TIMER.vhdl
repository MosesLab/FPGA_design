----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:46:30 09/10/2014 
-- Design Name: 
-- Module Name:    POWER_DOWN_TIMER - Behavioral 
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

entity POWER_DOWN_TIMER is
	port(
		clk		:in	std_logic;
		rst_n		:in	std_logic;
		initiate_destruct_sequence		:in	std_logic;
		self_destruct	:out	std_logic
	);
end POWER_DOWN_TIMER;

architecture Behavioral of POWER_DOWN_TIMER is
	
	signal self_destruct_count		:integer range 0 to (2**26) - 1 := 0;
	signal self_destruct_signal	:std_logic	:= '0';
	signal fuse_lit					:std_logic	:= '0';
begin
	
	
	LIGHT_THE_FUSE	:	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			fuse_lit <= '0';
		elsif (clk'event and clk = '1') then
			if (fuse_lit = '0') then
				if (initiate_destruct_sequence = '1') then
					fuse_lit <= '1';
				else
					fuse_lit <= '0';
				end if;
			else
				if (self_destruct_signal = '1') then
					fuse_lit <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			self_destruct_count <= 0;
			self_destruct <= '0';
		elsif (clk'event and clk = '1') then
			if (fuse_lit = '1') then
				if (self_destruct_count = 200000000) then -- 200000000 @ 50-MHz = 4 second timer
					self_destruct_count <= 0;
					self_destruct_signal <= '1';
				else
					self_destruct_count <= self_destruct_count + 1;
					self_destruct_signal <= '0';
				end if;
			else
				self_destruct_count <= 0;
				self_destruct_signal <= '0';
			end if;
		end if;
	end process;
	
	self_destruct <= self_destruct_signal;

end Behavioral;

