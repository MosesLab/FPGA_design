----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:42:14 08/20/2014 
-- Design Name: 
-- Module Name:    DDR2_bus_arbiter - Behavioral 
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

entity DDR2_bus_arbiter is
end DDR2_bus_arbiter;

architecture Behavioral of DDR2_bus_arbiter is

	type DDR2_ARBITER_STATES is (IDLE,CAMERA_ACK,LB_ACK);
	signal current_state	:DDR2_ARBITER_STATES;
	signal next_state		:DDR2_ARBITER_STATES;
	
begin

	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			current_state <= IDLE;
		elsif (clk'event and clk = '1') then
			current_state <= next_state;
		end if;
	end process;
	
	process(current_state,camera_req,lb_req) is
	begin
		case (current_state) is
			when IDLE =>
				if (camera_req = '1') then
					next_state <= CAMERA_ACK;
				elsif (lb_req = '1') then
					next_state <= LB_ACK;
				else
					next_state <= IDLE;
				end if;
				
			when CAMERA_ACK =>
				if (camera_req = '0') then
					if (lb_req = '1') then
						next_state <= LB_ACK;
					else
						next_state <= IDLE;
					end if;
				else
					next_state <= CAMERA_ACK;
				end if;
			when LB_ACK =>
				if (lb_req = '0') then
					if (camera_req = '1') then
						next_state <= CAMERA_ACK;
					else
						next_state <= IDLE;
					end if;
				else
					next_state <= LB_ACK;
				end if;
				
		end case;
	end process;

	process(current_state) is
	begin
		case (current_state) is
			when IDLE =>
				DDR2_mux_sel <= "00";
			when CAMERA_ACK =>
				DDR2_mux_sel <= "00";
			when LB_ACK =>
				DDR2_mux_sel <= "00";
		end case;
	end process;

end Behavioral;

