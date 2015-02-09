--********************************************************************************
-- Copyright � 2008 Connect Tech Inc. All Rights Reserved. 
--********************************************************************************
-- Project: 	FreeForm/PCI-104
-- Module:		clkfwd_mod
-- Parent:		clkControl
-- Description: takes in a 50 Mhz clock and forwards it.
--
-- * based on .vhd file generated by clkfwd.xaw
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2008-01-09	MF		Created
--********************************************************************************

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity clkfwd_mod is
   port ( 	CE_IN           : in    std_logic; 
			CLKFB_IN        : in    std_logic; 
			CLKIN_IN        : in    std_logic; 
			RST_IN          : in    std_logic; 
			R_IN            : in    std_logic; 
			S_IN            : in    std_logic; 
			CLKIN_IBUFG_OUT : out   std_logic; 
			CLK0_OUT        : out   std_logic; 
			ddr_clk_out : out std_logic_vector(1 downto 0);
			LOCKED_OUT      : out   std_logic);
end clkfwd_mod;

architecture BEHAVIORAL of clkfwd_mod is
   signal CLKFB_IBUFG     : std_logic;
--   signal CLKIN_IBUFG     : std_logic;
   signal CLK0_UNBUF        : std_logic;
   signal CLK0_BUF            : std_logic;
   signal GND_BIT         : std_logic;
   signal GND_BUS_7       : std_logic_vector (6 downto 0);
   signal GND_BUS_16      : std_logic_vector (15 downto 0);
   signal VCC_BIT         : std_logic;
begin
   GND_BIT <= '0';
   GND_BUS_7(6 downto 0) <= "0000000";
   GND_BUS_16(15 downto 0) <= "0000000000000000";
   VCC_BIT <= '1';
   
 --CLKIN_IBUFG_OUT <= CLKIN_IBUFG;
   CLKIN_IBUFG_OUT <= CLKIN_IN;
   
   CLK0_OUT <= CLK0_BUF;
   
   CLKFB_IBUFG_INST : IBUFG
      port map (I=>CLKFB_IN,
                O=>CLKFB_IBUFG);
				

   
--   CLKIN_IBUFG_INST : IBUFG
--      port map (I=>CLKIN_IN,
--                O=>CLKIN_IBUFG);
-- MF >> already buffered.
   
   CLK0_BUFG_INST : BUFG
      port map (I=>CLK0_UNBUF,
                O=>CLK0_BUF);
   
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
      port map (CLKFB=>CLKFB_IBUFG,
                CLKIN=>CLKIN_IN, --CLKIN_IBUFG,
                DADDR(6 downto 0)=>GND_BUS_7(6 downto 0),
                DCLK=>GND_BIT,
                DEN=>GND_BIT,
                DI(15 downto 0)=>GND_BUS_16(15 downto 0),
                DWE=>GND_BIT,
                PSCLK=>GND_BIT,
                PSEN=>GND_BIT,
                PSINCDEC=>GND_BIT,
                RST=>RST_IN,
                CLKDV=>open,
                CLKFX=>open,
                CLKFX180=>open,
                CLK0=>CLK0_UNBUF,
                CLK2X=>open,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>open,
                CLK270=>open,
                DO=>open,
                DRDY=>open,
                LOCKED=>LOCKED_OUT,
                PSDONE=>open);
   
	oddr_0 : ODDR
	generic map( 
		INIT => '0',
		DDR_CLK_EDGE => "OPPOSITE_EDGE",
		SRTYPE => "SYNC")
	port map (
		C=>CLK0_BUF,
		CE=>CE_IN,
		D1=>VCC_BIT,
		D2=>GND_BIT,
		R=>R_IN,
		S=>S_IN,
		Q=>DDR_CLK_OUT(0) );
	
	oddr_1 : ODDR
	generic map(
		INIT => '0',
		DDR_CLK_EDGE => "OPPOSITE_EDGE",
		SRTYPE => "SYNC")
	port map (
		C=>CLK0_BUF,
		CE=>CE_IN,
		D1=>VCC_BIT,
		D2=>GND_BIT,
		R=>R_IN,
		S=>S_IN,
		Q=>DDR_CLK_OUT(1) );				
   
end BEHAVIORAL;

