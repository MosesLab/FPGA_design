----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:04:53 08/06/2014 
-- Design Name: 
-- Module Name:    camera_sim - Behavioral 
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

entity camera_sim is
	port(
		clk		:in	std_logic;	-- system input clock
		rst_n		:in	std_logic;	-- system reset signal (active-low)
		trigger	:in	std_logic;	-- frame enable signal (trigger the start of a frame)
		
		pxl_clk	:out	std_logic; 
		pxl_data	:out	std_logic_vector(15 downto 0)		
	);
end camera_sim;

architecture Behavioral of camera_sim is
	
	type CAMERA_SIM_STATES is (IDLE,ACTIVE);
	signal camera_sim_next_state	:CAMERA_SIM_STATES := IDLE;
	signal camera_sim_current_state	:CAMERA_SIM_STATES	:= IDLE;
	
	signal pxl_clk_prev	:std_logic;
	signal pxl_clk_current	:std_logic;
	signal pxl_clk_rising_edge	:std_logic;
	signal pxl_clk_falling_edge	:std_logic;
	signal frame_done_flag	:std_logic;
	signal camera_sim_en	:std_logic;
	
	signal pxl_data_var	:unsigned(15 downto 0);
	signal pxl_addr		:unsigned(1 downto 0);
	signal pxl_clk_cnt	:unsigned(4 downto 0);
	
	component PXL_DATA_GENERATOR
	 Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           re : in  STD_LOGIC;
			  fe	:	in	std_logic;
           data : out  STD_LOGIC_VECTOR (15 downto 0);
			  clock	:	out	std_logic);
	end component;
	
begin

	STATE_MEM	:	process(clk,rst_n) is
	begin
		if(rst_n = '0') then
			camera_sim_current_state <= IDLE;
		elsif (clk'event and clk = '1') then
			camera_sim_current_state <= camera_sim_next_state;
		end if;
	end process;
	
	NSL	:	process(trigger) is
	begin
		case (camera_sim_current_state) is
			when IDLE =>
				if (trigger = '1') then
					camera_sim_next_state <= ACTIVE;
				else
					camera_sim_next_state <= IDLE;
				end if;
			when ACTIVE =>
				if (frame_done_flag = '1') then
					camera_sim_next_state <= IDLE;
				else
					camera_sim_next_state <= ACTIVE;
				end if;
		end case;
	end process;
	
	OUTPUT_LOGIC	:	process(camera_sim_current_state) is
	begin
		case (camera_sim_current_state) is
			when IDLE =>
				camera_sim_en <= '0';
			when ACTIVE =>
				camera_sim_en <= '1';
		end case;
	end process;
	
	-------------------------------------------------------------------
	-------------------------------------------------------------------
	-------------------------------------------------------------------
	-------------------------------------------------------------------
	

	-- pxl_clk_cnt process
	PXL_CLK_COUNTER	:	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			pxl_clk_cnt <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (camera_sim_en = '1') then
				if (pxl_clk_cnt = 25) then
					pxl_clk_cnt <= (others => '0');
				else
					pxl_clk_cnt <= pxl_clk_cnt + 1;
				end if;
			else
				pxl_clk_cnt <= (others => '0');
			end if;
		end if;
	end process;
	
	-- pxl_clk generation process
	PXL_CLK_GEN	:	process(clk,rst_n,pxl_clk_cnt) is
	begin
		if (rst_n = '0') then
			pxl_clk_current <= '1';
		elsif (clk'event and clk = '1') then
			if (camera_sim_en = '1') then
				if (pxl_clk_cnt < 12) then
					pxl_clk_current <= '0';
				else
					pxl_clk_current <= '1';
				end if;
			else
				pxl_clk_current <= '1';
			end if;
		end if;
	end process;
	
	-- Register for previous clock value
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			pxl_clk_prev <= '1';
		elsif (clk'event and clk = '1') then
			pxl_clk_prev <= pxl_clk_current;
		end if;
	end process;
	pxl_clk_rising_edge <= pxl_clk_current and (not pxl_clk_prev);
	pxl_clk_falling_edge <= (not pxl_clk_current) and pxl_clk_prev;

	
	PXL_DATA_GEN0	:	PXL_DATA_GENERATOR
	 port map( clk => clk,
			  rst_n  => rst_n,
			  re 		=> pxl_clk_rising_edge,
			  fe		=> pxl_clk_falling_edge,
			  data 	=> pxl_data,
			  clock	=> pxl_clk);
	
	-- frame termination logic
	PXL_FRAME_END	:	process(clk,rst_n) is
		variable pxl_cnt 		:integer range 0 to ((2**23)) := 0;
	begin
		if (rst_n = '0') then
			frame_done_flag <= '0';
			pxl_cnt := 0;
		elsif (clk'event and clk = '1') then
			if (camera_sim_en = '1') then
				frame_done_flag <= '0';
				if (pxl_clk_rising_edge = '1') then
					if (pxl_cnt = ((2**23)) ) then
						frame_done_flag <= '1';
						pxl_cnt := 0;
					else
						pxl_cnt := pxl_cnt + 1;
					end if;										
				end if;
			else
				frame_done_flag <= '0';
				pxl_cnt := 0;
			end if;
		end if;
	end process;
	


end Behavioral;

