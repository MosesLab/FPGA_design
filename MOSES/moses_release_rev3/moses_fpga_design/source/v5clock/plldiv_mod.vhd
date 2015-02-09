
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity plldiv_mod is
   port ( CLKIN1_IN         : in    std_logic; 
          sel				: in    std_logic_vector(1 downto 0); 
          RST_IN            : in    std_logic; 
          CLKOUT	       	: out   std_logic; 
          LOCKED_OUT        : out   std_logic);
end plldiv_mod;

architecture BEHAVIORAL of plldiv_mod is
   signal CLKFBOUT_CLKFBIN  : std_logic;
   signal CLKOUT0_unBUF       : std_logic;
   signal CLKOUT1_unBUF       : std_logic;
   signal CLKOUT2_unBUF       : std_logic;
   signal CLKOUT3_unBUF       : std_logic;
   signal CLKOUT01       : std_logic;
   signal CLKOUT23       : std_logic;
   signal GND_BIT           : std_logic;
   signal GND_BUS_5         : std_logic_vector (4 downto 0);
   signal GND_BUS_16        : std_logic_vector (15 downto 0);
   signal VCC_BIT           : std_logic;
begin
   GND_BIT <= '0';
   GND_BUS_5(4 downto 0) <= "00000";
   GND_BUS_16(15 downto 0) <= "0000000000000000";
   VCC_BIT <= '1';
   
   u_CLKOUT01 : BUFGMUX_CTRL
      port map (I0=>CLKOUT0_unBUF,
                I1=>CLKOUT1_unBUF,
                S=>sel(0),
                O=>CLKOUT01);
   
   u_CLKOUT23 : BUFGMUX_CTRL
      port map (I0=>CLKOUT2_unBUF,
                I1=>CLKOUT3_unBUF,
                S=>sel(0),
                O=>CLKOUT23);
   
   u_CLKOUT : BUFGMUX_CTRL
      port map (I0=>CLKOUT01,
                I1=>CLKOUT23,
                S=>sel(1),
                O=>CLKOUT );   
   
   PLL_ADV_INST : PLL_ADV
   generic map( BANDWIDTH => "OPTIMIZED",
            CLKIN1_PERIOD => 20.000,
            CLKIN2_PERIOD => 10.000,
            CLKOUT0_DIVIDE => 5,
            CLKOUT1_DIVIDE => 4,
            CLKOUT2_DIVIDE => 3,
            CLKOUT3_DIVIDE => 2,
            CLKOUT4_DIVIDE => 8,
            CLKOUT5_DIVIDE => 8,
            CLKOUT0_PHASE => 0.000,
            CLKOUT1_PHASE => 0.000,
            CLKOUT2_PHASE => 0.000,
            CLKOUT3_PHASE => 0.000,
            CLKOUT4_PHASE => 0.000,
            CLKOUT5_PHASE => 0.000,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT1_DUTY_CYCLE => 0.500,
            CLKOUT2_DUTY_CYCLE => 0.500,
            CLKOUT3_DUTY_CYCLE => 0.500,
            CLKOUT4_DUTY_CYCLE => 0.500,
            CLKOUT5_DUTY_CYCLE => 0.500,
            COMPENSATION => "SYSTEM_SYNCHRONOUS",
            DIVCLK_DIVIDE => 1,
            CLKFBOUT_MULT => 8,
            CLKFBOUT_PHASE => 0.0,
            REF_JITTER => 0.005000)
      port map (CLKFBIN=>CLKFBOUT_CLKFBIN,
                CLKINSEL=>VCC_BIT,
                CLKIN1=>CLKIN1_IN,
                CLKIN2=>GND_BIT,
                DADDR(4 downto 0)=>GND_BUS_5(4 downto 0),
                DCLK=>GND_BIT,
                DEN=>GND_BIT,
                DI(15 downto 0)=>GND_BUS_16(15 downto 0),
                DWE=>GND_BIT,
                REL=>GND_BIT,
                RST=>RST_IN,
                CLKFBDCM=>open,
                CLKFBOUT=>CLKFBOUT_CLKFBIN,
                CLKOUTDCM0=>open,
                CLKOUTDCM1=>open,
                CLKOUTDCM2=>open,
                CLKOUTDCM3=>open,
                CLKOUTDCM4=>open,
                CLKOUTDCM5=>open,
                CLKOUT0=>CLKOUT0_unBUF,
                CLKOUT1=>CLKOUT1_unBUF,
                CLKOUT2=>CLKOUT2_unBUF,
                CLKOUT3=>CLKOUT3_unBUF,
                CLKOUT4=>open,
                CLKOUT5=>open,
                DO=>open,
                DRDY=>open,
                LOCKED=>LOCKED_OUT);
   
end BEHAVIORAL;


