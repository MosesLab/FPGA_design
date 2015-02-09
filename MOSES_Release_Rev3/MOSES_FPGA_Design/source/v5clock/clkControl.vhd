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
-- Module:		clkControl
-- Parent:		init_plx
-- Description: Generates all clocks used internal, also forwards clock to PLX
--				bridge and deskews.
--
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-01-09	MF		Created
-- 2008-01-23	MF		Add clkfx output
-- 2008-02-11	MF		Add clk200Lock output
-- 2008-03-06	MF		Removed clkfb_out (was for local bus monitor)
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clkControl is
	generic ( simulation : boolean := false );
    port ( 
           mainclkp : in  STD_LOGIC;
           mainclkn : in  STD_LOGIC;
           lclkfb : in  STD_LOGIC;
		   --lclkfb_out : out std_logic;
           lclko : out  STD_LOGIC_vector(1 downto 0);  
		   clkfx : out std_logic;
           clk50 : out  STD_LOGIC;
           clk100 : out  STD_LOGIC;
           clk200 : out  STD_LOGIC;
		   clk200Locked : out std_logic;
           allClkStable : out std_logic
	);
end clkControl;

architecture Behavioral of clkControl is

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
	--	clkfb_out : out std_logic;		
		RST_IN : in std_logic;
		R_IN : in std_logic;
		S_IN : in std_logic;          
		CLKIN_IBUFG_OUT : out std_logic;
		CLK0_OUT : out std_logic;
		ddr_clk_out : out std_logic_vector(1 downto 0);
		LOCKED_OUT : out std_logic
		);
	END component;
	
	signal clkfx_buf : std_logic;
	signal clk50_buf : std_logic;
	signal clk100_buf : std_logic;
    signal clk100_unbuf : std_logic;	
	
	signal dcm0_rst : std_logic;
	signal dcm0_locked : std_logic;
	
	signal dcm1_rst : std_logic;
	signal dcm1_locked : std_logic;
		
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
		
		dcm0_rst <= not cnt(3);
	end process;
	
	u_DCM0 : gen200mhz port map(
		CLKIN_N_IN => mainclkn,
		CLKIN_P_IN => mainclkp,
		RST_IN => dcm0_rst,
		CLKDV_OUT => clk50_buf,
		CLKIN_IBUFGDS_OUT => clk100_unbuf,
		CLKFX_OUT => clkfx_buf,
		CLK0_OUT => clk100_buf,
		CLK2X_OUT => clk200,
		LOCKED_OUT => dcm0_locked
	);
	
	clk200Locked <= dcm0_locked;
	
	p_dcm1_rst : process(clk100_buf) --, rstn)
	
		variable cnt : unsigned(4 downto 0) := (others => '0');
	
	begin
	
		--if rstn = '0' then
		--
		--	dcm1_rst_cnt := (others => '0');
		--
		--elsif 
		if rising_edge(clk100_buf) then
			if dcm0_locked = '0' then
				cnt := (others => '0');
			else 
				if cnt(4) = '0' then
					cnt := cnt +1;
				end if;
			end if; 
		end if;
		
		dcm1_rst <= not cnt(4);
		
	end process;



	u_clkfwd: clkfwd_mod port map(
		CE_IN => '1',
		CLKFB_IN => lclkfb,
--		clkfb_out => lclkfb_out,
		CLKIN_IN => clk50_buf,
		RST_IN => dcm1_rst,
		R_IN => '0',
		S_IN => '0',
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,  -- this is input to ddr2 buffer
		ddr_clk_out(0) => tmp, --lclko want to use this when not simulating
		ddr_clk_out(1) => lclko(1), --lclko want to use this when not simulating
		LOCKED_OUT => dcm1_locked
	);
	
	g_sim : if (simulation = true) generate
		lclko(0) <= clk50_buf;
	end generate;
	
	g_nosim : if (simulation = false) generate
		lclko(0) <= tmp;
	end generate;
	
	allClkStable <= dcm1_locked;
	

	clk50 <=clk50_buf;
	clk100 <=clk100_buf;
	clkfx <= clkfx_buf;
end Behavioral;

