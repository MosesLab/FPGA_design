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

entity clkControlMem is
	generic ( 
		c_simulation : boolean := false;
		c_ddr2type : integer := DDR2400;
		c_pcbrev : character := 'B'
	);
    port ( 
		mainclkp : in  STD_LOGIC;
		mainclkn : in  STD_LOGIC;
		lclkfb : in  STD_LOGIC;
		lclko : out  STD_LOGIC_vector(1 downto 0);  
		clkfx : out std_logic;
		clk50 : out  STD_LOGIC;
		clk100 : out  STD_LOGIC;
		clk200 : out  STD_LOGIC;
		clk200Locked : out std_logic;
		pllClk : out  STD_LOGIC;   
		pllLocked : out std_logic;
		allClkStable : out std_logic
	);
end clkControlMem;

architecture Behavioral of clkControlMem is

	component gen200mhz
	port(
		CLKIN_N_IN : in std_logic;
		CLKIN_P_IN : in std_logic;
		RST_IN : in std_logic;          
		CLKDV_OUT : out std_logic;
		CLKFX_OUT : out std_logic;
		CLKIN_IBUFGDS_OUT : out std_logic;
		CLK0_OUT : out std_logic;
		CLK2X_OUT : out std_logic;
		LOCKED_OUT : out std_logic
		);
	END component;

	component clkfwd_mod
	port(
		CE_IN : in std_logic;
		CLKFB_IN : in std_logic;
		CLKIN_IN : in std_logic;
		RST_IN : in std_logic;
		R_IN : in std_logic;
		S_IN : in std_logic;          
		CLKIN_IBUFG_OUT : out std_logic;
		CLK0_OUT : out std_logic;
		ddr_clk_out : out std_logic_vector(1 downto 0);
		LOCKED_OUT : out std_logic
		);
	END component;
	
component lclkDeskew is
   port ( CLKIN_IN        : in    std_logic; 
          RST_IN          : in    std_logic; 
          CLKIN_IBUFG_OUT : out   std_logic; 
          CLK0_OUT        : out   std_logic; 
          LOCKED_OUT      : out   std_logic);
end component lclkDeskew;	

	component memPll is
	   port ( CLKIN1_IN   : in    std_logic; 
	          RST_IN      : in    std_logic; 
	          CLKOUT0_OUT : out   std_logic; 
	          LOCKED_OUT  : out   std_logic);
	end component;
	
	signal clkfx_buf : std_logic;
	signal clk50_buf : std_logic;
	signal clk50_locked : std_logic;
	signal clk100_buf : std_logic;
	signal clk200_buf : std_logic;
    signal clk100_unbuf : std_logic;	
	
	signal dcmLvl0_rst : std_logic;
	signal dcmLvl0_locked : std_logic;
	
	signal dcmLvl1_rst : std_logic;
	signal pllLocked_x : std_logic;
	signal clkFwdDCMLocked : std_logic;
		
	signal tmp : std_logic;
	
begin

	-- MF: don't use local bus reset to reset clock circuitry
	--dcm0_rst <= not rstn;
	
	p_dcm0_rst : process(clk100_unbuf)
		variable cnt : unsigned(4 downto 0) := (others => '0');
	begin
	
		if rising_edge(clk100_unbuf) then
			if cnt(3) = '0' then
				cnt := cnt +1;
			end if; 
		end if;
		
		dcmLvl0_rst <= not cnt(3);
	end process;
	
	u_DCM0 : gen200mhz port map(
		CLKIN_N_IN => mainclkn,
		CLKIN_P_IN => mainclkp,
		RST_IN => dcmLvl0_rst,
		CLKDV_OUT => clk50_buf,
		CLKIN_IBUFGDS_OUT => clk100_unbuf,
		CLKFX_OUT => clkfx_buf,
		CLK0_OUT => clk100_buf,
		CLK2X_OUT => clk200_buf,
		LOCKED_OUT => dcmLvl0_locked
	);
	
	clk200Locked <= dcmLvl0_locked;

	p_dcm1_rst : process(clk100_buf,dcmLvl0_locked) --, rstn)
		variable cnt : unsigned(4 downto 0) := (others => '0');
	begin
		if dcmLvl0_locked = '0' then
			cnt := (others => '0');
		elsif rising_edge(clk100_buf) then
			if cnt(4) = '0' then
				cnt := cnt +1;
			end if;
		end if;
		
		dcmLvl1_rst <= not cnt(4);
		
	end process;

--g_DDR2400 : if c_ddr2type = DDR2400 generate
	pllClk <= '0';
	pllLocked <= '0';
	
	
--end generate;

--g_DDR2533 : if c_ddr2type = DDR2533 generate
--	u_memPll : memPll PORT MAP(
--		CLKIN1_IN   => clk100_unbuf,
--	    RST_IN      => dcmLvl1_rst,
--	    CLKOUT0_OUT => pllClk,
--	    LOCKED_OUT  => pllLocked_x
--	);	
--	
--	allClkStable <= pllLocked_x and clkfwdDCMLocked;
--	
--	pllLocked <= pllLocked_x;
--end generate;

g_clkRevB : if c_pcbrev = 'B' generate
	u_clkfwd: clkfwd_mod port map(
		CE_IN => '1',
		CLKFB_IN => lclkfb,
		CLKIN_IN => clk50_buf,
		RST_IN => dcmLvl1_rst,
		R_IN => '0',
		S_IN => '0',
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,  -- this is input to ddr2 buffer
		ddr_clk_out(0) => tmp, --lclko want to use this when not simulating
		ddr_clk_out(1) => lclko(1), --lclko want to use this when not simulating
		LOCKED_OUT => clkfwdDCMLocked
	);
	
	g_sim : if (c_simulation = true) generate
		lclko(0) <= clk50_buf;
	end generate;
	
	g_nosim : if (c_simulation = false) generate
		lclko(0) <= tmp;
	end generate;
	
	clk50 <=clk50_buf;	
	
	allClkStable <= clkfwdDCMLocked;
	
end generate g_clkRevB;

g_clkRevC : if c_pcbrev = 'C' or c_pcbrev = 'D' generate
	--CLK50_IBUFG : IBUFG port map (I=>lclkfb, O=>clk50_buf);	
	--CLK50_BUFG : BUFG port map (I=>clk50_buf, O=>clk50); 
		-- clk50 comes directly from PAD
		
	-- use DCM to deskdw
	u_DCM1 : lclkDeskew PORT MAP(
		CLKIN_IN => lclkfb,
		RST_IN => dcmLvl0_rst,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => clk50,
		LOCKED_OUT => clk50_locked 
	);		
		
	allClkStable <= clk50_locked and dcmLvl0_locked;
		
	lclko(0) <= '0';
	lclko(1) <= '0';
	--clkfwdDCMLocked <= '1';
end generate g_clkRevC;

	clk100 <=clk100_buf;
	clk200 <= clk200_buf;
	clkfx <= clkfx_buf;
	
end Behavioral;

