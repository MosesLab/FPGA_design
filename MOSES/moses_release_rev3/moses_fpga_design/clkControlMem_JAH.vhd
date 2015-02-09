--********************************************************************************
-- Copyright © 2008 Connect Tech Inc. All Rights Reserved. 
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary Information of Connect Tech, Inc
-- and should be treated as Confidential.
--
--********************************************************************************
-- Project: 	FreeForm/PCI-104
-- Module:		clkControlMem
-- Parent:		init_plx
-- Description: Generates all clocks used internal, also forwards clock to PLX
--				bridge and deskews.
--
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2008-02-04	MF		Created
-- 2008-02-14	MF		Add PLL to create 266 Mhz
-- 2008-02-19	MF		change the level 1 reset to be based on the locked clock
-- 2008-07-07	MF		Modifications for rev C
-- 2008-07-30	MF		Added deskewing DCM for revC
-- 2008-11-24	MF		Add check for PCB rev D
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clkControlMem_JAH is
    port ( 
		clk100M_SE		: in	std_logic;
		lb_lclko			: out std_logic;
		lb_lclko_loop	: out	std_logic;
		lb_lclko_fb		: in  std_logic;
		clk50 			: out std_logic;
		ddr2_clk200		: out std_logic;
		locked			: out	std_logic
	);
end clkControlMem_JAH;

architecture Behavioral of clkControlMem_JAH is
	
	signal	clk50_internal				:std_logic;
	signal	clk50_buffered				:std_logic;
	
	signal	lb_lclk_internal			:std_logic;
	
	signal	clk50_plx_loop				:std_logic;
	signal	clk50_plx_loop_buffered	:std_logic;
	signal	clk50_plx_loop_output	:std_logic;
	
	signal	clk100M_SE_clk0			:std_logic;
	signal	clk100M_SE_clk0_buffered			:std_logic;
	
	
	signal	lb_lclko_fb_buffered		:std_logic;
	signal	lb_lclk_ODDR				:std_logic;
	
	signal	ddr2_clk200_signal		:std_logic;

	signal	dcm0_locked					:std_logic;
	signal	dcm1_locked					:std_logic;
	signal	dcm_rst						:std_logic;
	signal	rst							:std_logic;
	
begin
	
	locked <= dcm0_locked and dcm1_locked;
	
	--DCM0 resest logic
	p_dcm0_rst : process(clk100M_SE)
		variable cnt : unsigned(4 downto 0) := (others => '0');
		begin
			if rising_edge(clk100M_SE) then
				if cnt(3) = '0' then
					cnt := cnt +1;
				end if; 
			end if;			
			dcm_rst <= not cnt(3);
		end process;
	
	-- Generating the external 50-MHz clock, which will be aligned with the internal 50-MHz clock
	DCM_BASE0 : DCM_BASE
		generic map (
			CLKDV_DIVIDE => 2.0, -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
										--   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
			CLKFX_DIVIDE => 2,   -- Can be any integer from 1 to 32 (previously 6)
			CLKFX_MULTIPLY => 3, -- Can be any integer from 2 to 32 (previously 2)
			CLKIN_DIVIDE_BY_2 => FALSE, -- TRUE/FALSE to enable CLKIN divide by two feature
			CLKIN_PERIOD => 10.0, -- Specify period of input clock in ns from 1.25 to 1000.00
			CLKOUT_PHASE_SHIFT => "NONE", -- Specify phase shift mode of NONE or FIXED
			CLK_FEEDBACK => "1X",         -- Specify clock feedback of NONE or 1X
			DCM_PERFORMANCE_MODE => "MAX_SPEED",   -- Can be MAX_SPEED or MAX_RANGE
			DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
																--   an integer from 0 to 15
			DFS_FREQUENCY_MODE => "LOW",   -- LOW or HIGH frequency mode for frequency synthesis
			DLL_FREQUENCY_MODE => "LOW",   -- LOW, HIGH, or HIGH_SER frequency mode for DLL
			DUTY_CYCLE_CORRECTION => TRUE, -- Duty cycle correction, TRUE or FALSE
			FACTORY_JF => X"F0F0",          -- FACTORY JF Values Suggested to be set to X"F0F0" 
			PHASE_SHIFT => 0, -- Amount of fixed phase shift from -255 to 1023
			STARTUP_WAIT => FALSE) -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
		port map (
			CLK0 => clk100M_SE_clk0,         -- 0 degree DCM CLK ouptput
			CLK180 => open,     -- 180 degree DCM CLK output
			CLK270 => open,     -- 270 degree DCM CLK output
			CLK2X => ddr2_clk200_signal,       -- 2X DCM CLK output
			CLK2X180 => open, -- 2X, 180 degree DCM CLK out
			CLK90 => open,       -- 90 degree DCM CLK output
			CLKDV => open,       -- Divided DCM CLK out (CLKDV_DIVIDE)
			CLKFX => open, --ddr2_clk200_signal,       -- DCM CLK synthesis out (M/D)
			CLKFX180 => open, -- 180 degree CLK synthesis out
			LOCKED => dcm0_locked,     -- DCM LOCK status output
			CLKFB => clk100M_SE_clk0_buffered, -- DCM clock feedback
			CLKIN => clk100M_SE,       -- Clock input (from IBUFG, BUFG or DCM)
			RST => dcm_rst            -- DCM asynchronous reset input
		);
		
	-- DDR2 200-MHz clock buffer
	BUFG0 : BUFG
		port map (
			O => ddr2_clk200,    			-- Clock buffer output
			I => ddr2_clk200_signal    -- Clock buffer input
		);
	
	-- DCM0 Feedback path
	BUFG1 : BUFG
		port map (
			O => clk100M_SE_clk0_buffered,     -- Clock buffer output
			I => clk100M_SE_clk0      -- Clock buffer input
		);
	
	lb_lclko_loop <= '0';
	lb_lclko <= '0';

	DCM_ADV_INST : DCM_ADV
   generic map( CLK_FEEDBACK => "1X",
            CLKDV_DIVIDE => 2.0,
            CLKFX_DIVIDE => 1,
            CLKFX_MULTIPLY => 4,
            CLKIN_DIVIDE_BY_2 => FALSE,
            CLKIN_PERIOD => 20.000,
            CLKOUT_PHASE_SHIFT => "NONE",
            DCM_AUTOCALIBRATION => TRUE,
            DCM_PERFORMANCE_MODE => "MAX_SPEED",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE => "LOW",
            DLL_FREQUENCY_MODE => "LOW",
            DUTY_CYCLE_CORRECTION => TRUE,
            FACTORY_JF => x"F0F0",
            PHASE_SHIFT => 0,
            STARTUP_WAIT => FALSE,
            SIM_DEVICE => "VIRTEX5")
      port map (CLKFB=>clk50_buffered,
                CLKIN=>lb_lclko_fb_buffered, --CLKIN_IBUFG,
                DADDR(6 downto 0)=> "0000000",
                DCLK=>'0',
                DEN=>'0',
                DI(15 downto 0)=>x"0000",
                DWE=>'0',
                PSCLK=>'0',
                PSEN=>'0',
                PSINCDEC=>'0',
                RST=> dcm_rst,
                CLKDV=>open,
                CLKFX=>open,
                CLKFX180=>open,
                CLK0=>clk50_internal,
                CLK2X=>open,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>open,
                CLK270=>open,
                DO=>open,
                DRDY=>open,
                LOCKED=>dcm1_locked,
                PSDONE=>open);
		
	IBUFG0 : IBUFG
		port map (
			O => lb_lclko_fb_buffered, -- Clock buffer output
			I => lb_lclko_fb  -- Clock buffer input (connect directly to top-level port)
		);
		
	BUFG4 : BUFG
		port map (
			O => clk50_buffered,     -- Clock buffer output
			I => clk50_internal     -- Clock buffer input
		);
	clk50 <= clk50_buffered;



end Behavioral;

