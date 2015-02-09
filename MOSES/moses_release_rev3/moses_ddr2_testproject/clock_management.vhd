----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:48:12 10/02/2014 
-- Design Name: 
-- Module Name:    clock_management - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity clock_management is
	port(
		-- This is the 100-MHz differential input clock
		clk100M		:in	std_logic;
		
		clk50			:out	std_logic;
		
		-- These are the clocks required to run the DDR2 interface
		ddr2_clk0		:out	std_logic;	-- 150-MHz clock for controller and interface logic
		ddr2_clk90		:out	std_logic;	-- 90-deg phase-shifted version of 50-MHz system clock
		ddr2_clkdv		:out	std_logic;	-- Divided-by-two, edge-aligned version of 50-MHz clock
		
		rst_n				:in	std_logic;
		pll_locked		:out	std_logic
	);
end clock_management;

architecture Behavioral of clock_management is

	COMPONENT pll
		PORT(
			CLKIN1_IN : IN std_logic;
			RST_IN : IN std_logic;          
			CLKOUT0_OUT : OUT std_logic;
			CLKOUT1_OUT : OUT std_logic;
			CLKOUT2_OUT : OUT std_logic;
			CLKOUT3_OUT : OUT std_logic;
			LOCKED_OUT : OUT std_logic
			);
	END COMPONENT;

	signal	rst							:std_logic;
--	signal	clk150M						:std_logic;
--	signal	clk150M_fb					:std_logic;
--	signal	clk150M_clk0				:std_logic;
--	signal	pll_locked_signal			:std_logic;
--	signal	dcm0_locked					:std_logic;
--	signal	clk150M_clk90_buffered	:std_logic;
--	signal	clk150M_clk90				:std_logic;
--	signal	clk150M_clkdv_buffered	:std_logic;
--	signal	clk150M_clkdv				:std_logic;
	
begin

	rst <= not rst_n;
	--pll_locked <= dcm0_locked and pll_locked_signal;
	
	
	PLL0: pll 
		port map(
		CLKIN1_IN => clk100M,
		RST_IN => rst,
		CLKOUT0_OUT => ddr2_clk0,
		CLKOUT1_OUT => ddr2_clk90,
		CLKOUT2_OUT => ddr2_clkdv,
		CLKOUT3_OUT => clk50,
		LOCKED_OUT => pll_locked
	);


	-- Generate the 150-MHz clock
--	DCM0 : DCM_BASE
--		generic map (
--			CLKDV_DIVIDE => 2.0, -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
--										--   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
--			CLKFX_DIVIDE => 1,   -- Can be any integer from 1 to 32
--			CLKFX_MULTIPLY => 4, -- Can be any integer from 2 to 32
--			CLKIN_DIVIDE_BY_2 => FALSE, -- TRUE/FALSE to enable CLKIN divide by two feature
--			CLKIN_PERIOD => 5.0, -- Specify period of input clock in ns from 1.25 to 1000.00
--			CLKOUT_PHASE_SHIFT => "NONE", -- Specify phase shift mode of NONE or FIXED
--			CLK_FEEDBACK => "1X",         -- Specify clock feedback of NONE or 1X
--			DCM_PERFORMANCE_MODE => "MAX_SPEED",   -- Can be MAX_SPEED or MAX_RANGE
--			DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
--																--   an integer from 0 to 15
--			DFS_FREQUENCY_MODE => "HIGH",   -- LOW or HIGH frequency mode for frequency synthesis
--			DLL_FREQUENCY_MODE => "HIGH",   -- LOW, HIGH, or HIGH_SER frequency mode for DLL
--			DUTY_CYCLE_CORRECTION => TRUE, -- Duty cycle correction, TRUE or FALSE
--			FACTORY_JF => X"F0F0",          -- FACTORY JF Values Suggested to be set to X"F0F0" 
--			PHASE_SHIFT => 0, -- Amount of fixed phase shift from -255 to 1023
--			STARTUP_WAIT => FALSE) -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
--		port map (
--			CLK0 => clk150M_clk0,         -- 0 degree DCM CLK ouptput
--			CLK180 => open,     	 -- 180 degree DCM CLK output
--			CLK270 => open,    	 -- 270 degree DCM CLK output
--			CLK2X => open,       -- 2X DCM CLK output
--			CLK2X180 => open, -- 2X, 180 degree DCM CLK out
--			CLK90 => clk150M_clk90,       -- 90 degree DCM CLK output
--			CLKDV => clk150M_clkdv,       -- Divided DCM CLK out (CLKDV_DIVIDE)
--			CLKFX => open,       -- DCM CLK synthesis out (M/D)
--			CLKFX180 => open, -- 180 degree CLK synthesis out
--			LOCKED => dcm0_locked,     -- DCM LOCK status output
--			CLKFB => clk150M_fb,       -- DCM clock feedback
--			CLKIN => clk150M,  -- Clock input (from IBUFG, BUFG or DCM)
--			RST => rst            -- DCM asynchronous reset input
--		);
		
--	BUFG0 : BUFG
--		port map (
--			O => clk150M_fb,     -- Clock buffer output
--			I => clk150M_clk0      -- Clock buffer input
--		);
--	ddr2_clk0 <= clk150M_fb;
--		
--	BUFG2 : BUFG
--		port map (
--			O => clk150M_clk90_buffered,     -- Clock buffer output
--			I => clk150M_clk90      -- Clock buffer input
--		);
--	ddr2_clk90 <= clk150M_clk90_buffered;
--		
--	BUFG3 : BUFG
--		port map (
--			O => clk150M_clkdv_buffered,     -- Clock buffer output
--			I => clk150M_clkdv      -- Clock buffer input
--		);
--	ddr2_clkdv <= clk150M_clkdv_buffered;
--		
--	DCM1 : DCM_BASE
--		generic map (
--			CLKDV_DIVIDE => 2.0, -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
--										--   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
--			CLKFX_DIVIDE => 8,   -- Can be any integer from 1 to 32
--			CLKFX_MULTIPLY => 2, -- Can be any integer from 2 to 32
--			CLKIN_DIVIDE_BY_2 => FALSE, -- TRUE/FALSE to enable CLKIN divide by two feature
--			CLKIN_PERIOD => 5.0, -- Specify period of input clock in ns from 1.25 to 1000.00
--			CLKOUT_PHASE_SHIFT => "NONE", -- Specify phase shift mode of NONE or FIXED
--			CLK_FEEDBACK => "1X",         -- Specify clock feedback of NONE or 1X
--			DCM_PERFORMANCE_MODE => "MAX_SPEED",   -- Can be MAX_SPEED or MAX_RANGE
--			DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
--																--   an integer from 0 to 15
--			DFS_FREQUENCY_MODE => "HIGH",   -- LOW or HIGH frequency mode for frequency synthesis
--			DLL_FREQUENCY_MODE => "HIGH",   -- LOW, HIGH, or HIGH_SER frequency mode for DLL
--			DUTY_CYCLE_CORRECTION => TRUE, -- Duty cycle correction, TRUE or FALSE
--			FACTORY_JF => X"F0F0",          -- FACTORY JF Values Suggested to be set to X"F0F0" 
--			PHASE_SHIFT => 0, -- Amount of fixed phase shift from -255 to 1023
--			STARTUP_WAIT => FALSE) -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
--		port map (
--			CLK0 => clk150M_clk0,         -- 0 degree DCM CLK ouptput
--			CLK180 => open,     -- 180 degree DCM CLK output
--			CLK270 => open,     -- 270 degree DCM CLK output
--			CLK2X => open,       -- 2X DCM CLK output
--			CLK2X180 => open, -- 2X, 180 degree DCM CLK out
--			CLK90 => clk150M_clk90,       -- 90 degree DCM CLK output
--			CLKDV => clk150M_clkdv,       -- Divided DCM CLK out (CLKDV_DIVIDE)
--			CLKFX => clk50M,       -- DCM CLK synthesis out (M/D)
--			CLKFX180 => open, -- 180 degree CLK synthesis out
--			LOCKED => dcm1_locked,     -- DCM LOCK status output
--			CLKFB => clk150M_clk0_buffered,       -- DCM clock feedback
--			CLKIN => clk150M,       -- Clock input (from IBUFG, BUFG or DCM)
--			RST => rst            -- DCM asynchronous reset input
--		);
--		
--		BUFG1 : BUFG
--		port map (
--			O => clk150M_clk0_buffered,     -- Clock buffer output
--			I => clk150M_clk0      -- Clock buffer input
--		);
--		ddr2_clk0 <= clk150M_clk0_buffered;
--		ddr2_clk150M	<= clk150M_clk0_buffered;
--		

--		
--		BUFG4 : BUFG
--		port map (
--			O => clk50M_buffered,     -- Clock buffer output
--			I => clk50M      -- Clock buffer input
--		);
--		clk50 <= clk50M_buffered;
		
end Behavioral;

