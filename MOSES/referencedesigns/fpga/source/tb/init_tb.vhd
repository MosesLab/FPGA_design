--********************************************************************************
-- Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary Information of Connect Tech, Inc
-- and should be treated as Confidential.
--********************************************************************************
-- Project: 	FreeForm/PCI104
-- Module:		init_tb.vhd
-- Parent:		N/A
-- Description: Simple test bench; mimic PLX local bus transactions
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2007-12-18	MF		Created
-- 2008-04-03	MF		Update for use with emac_plx
-- 2009-03-11	MF		Revised for Rev D
-- '			'		Added reset process
--********************************************************************************

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.ctiUtil.all;
use work.ctiSim.all;
use work.txt_util.all;

library UNISIM;
use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
ENTITY init_tb IS
END init_tb;

----------------------------------------------------------------------------------
ARCHITECTURE simulation OF init_tb IS 
----------------------------------------------------------------------------------
	constant c_ref_design : boolean := FALSE;
	constant c_clk50Osc : boolean := TRUE;
	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Type Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--n/a
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	component ref_design is
----------------------------------------------------------------------------------
	port ( 

		-- Main clock
		mainclkp : in  std_logic;
		mainclkn : in  std_logic;
		--memClkPad : in std_logic;
			
		-- plx interface (in order of apperance)
		lb_adsn : inout std_logic; 						-- asserted by lb master
		lb_bigendn : out std_logic;						-- input to PLX
		lb_blastn : inout std_logic; 						-- asserted by lb master
		lb_breqi : out std_logic;
		lb_breqo : in std_logic;
		lb_btermn : out std_logic;						-- asserted by lb slave
		lb_ccsn : out std_logic;
		lb_dackn : in std_logic_vector(1 downto 0);
		lb_eotn : inout std_logic;						-- when DMPAF PLX out, when EOTN PLX in
		lb_dp : out std_logic_vector(3 downto 0); 		-- inout
		lb_dreqn : out std_logic_vector(1 downto 0);	
		lb_la : inout std_logic_vector(31 downto 2); 		-- asserted by master
		lb_lben : inout std_logic_vector(3 downto 0); 		-- inout
		lb_lclko_plx : out std_logic;					-- U5-B21 >> U4-D16
		lb_lclko_loop : out std_logic;					-- U5-A20 >> U5-Y21
		lb_lclkfb : in std_logic;						-- this is y21
		lb_ld : inout std_logic_vector(31 downto 0);
		lb_lhold : in std_logic;						-- asserted by PLX
		lb_lholda : out std_logic;						-- asserted by arbiter
		lb_lintin : out std_logic;						
		lb_linton : in std_logic;
		lb_lresetn : in std_logic;
		lb_lserrn : in std_logic;						-- was just in
		lb_lw_rn : inout std_logic; 						-- asserted by master
		lb_pmereon : out std_logic;
		lb_readyn : inout std_logic; 						-- asserted by slave
		lb_useri : out std_logic;
		lb_usero : in std_logic;
		lb_waitn : in std_logic; 						-- asserted by master

		plx_hostenn : in std_logic;

		-- MIIA
		miia_rxdv : in std_logic;
		miia_rxer : in std_logic;
		miia_rxd : inout std_logic_vector(3 downto 0);
		miia_rxclk : in std_logic;
		miia_txen : out std_logic;
		miia_txd : out std_logic_vector(3 downto 0);
		miia_txclk : in std_logic;
		miia_crs : in std_logic;
		miia_col : in std_logic;
		miia_intn : out std_logic;
		
		-- MIIB
		miib_rxdv : in std_logic;
		miib_rxer : in std_logic;
		miib_rxd : inout std_logic_vector(3 downto 0);
		miib_rxclk : in std_logic;
		miib_txen : out std_logic;
		miib_txd : out std_logic_vector(3 downto 0);
		miib_txclk : in std_logic;
		miib_crs : in std_logic;
		miib_col : in std_logic;
		miib_intn : out std_logic;
		
		-- MII Common
		mii_clk : in std_logic;
		mii_resetn : out std_logic;
		mii_mdc : out std_logic;
		mii_mdio : inout std_logic;
		
		-- RS485 0
		rs0_rx : in std_logic;
		rs0_tx : out std_logic;
		rs0_renn : out std_logic;
		rs0_ten : out std_logic;
		
		-- RS485 1	
		rs1_rx : in std_logic;
		rs1_tx : out std_logic;
		rs1_renn : out std_logic;
		rs1_ten : out std_logic;
		
		-- SPI B
		spib_clk : out std_logic;
		spib_csn : out std_logic;
		spib_mosi : out std_logic;
		spib_miso : in std_logic;
		
		spia_csn : out std_logic;
		spia_mosi : out std_logic;
		
		-- EEPROM
		eth_ee_clk : out std_logic;
		eth_ee_dido : inout std_logic;
		eth_ee_cs : out std_logic;
		
		-- GPIO
		gpio_p : inout std_logic_vector(31 downto 0);
		gpio_n : inout std_logic_vector(31 downto 0);
			
		--DDR2 interface
		ddr2_a : out  std_logic_vector (13 downto 0);
		ddr2_dq : inout  std_logic_vector (31 downto 0); --inout
		ddr2_dqs : inout  std_logic_vector (3 downto 0); --inout
		ddr2_dqs_n : inout  std_logic_vector (3 downto 0);--inout
		ddr2_ba : out  std_logic_vector (2 downto 0);
		ddr2_odt : out  std_logic_vector(0 downto 0);
		ddr2_we_n : out  std_logic;
		ddr2_cas_n : out  std_logic;
		ddr2_ras_n : out  std_logic;
		ddr2_dm : out  std_logic_vector (3 downto 0);
		ddr2_cs_n : out  std_logic_vector(0 downto 0);
		ddr2_ck : out  std_logic_vector(0 downto 0);
		ddr2_ck_n : out  std_logic_vector(0 downto 0);
		ddr2_cke : out  std_logic_vector(0 downto 0);
		
		-- User LEDs
		user_led : out std_logic_vector(3 downto 0);
		hss_user_io : inout std_logic_vector(3 downto 0);

		-- MGT
		mgt112_tx0p : out std_logic;
		mgt112_tx0n : out std_logic;
		mgt112_rx0p : in std_logic;
		mgt112_rx0n	: in std_logic;
		mgt112_tx1p : out std_logic;
		mgt112_tx1n : out std_logic;
		mgt112_rx1p : in std_logic;
		mgt112_rx1n : in std_logic;

		mgt114_tx0p : out std_logic;
		mgt114_tx0n : out std_logic;
		mgt114_rx0p : in std_logic;
		mgt114_rx0n	: in std_logic;
		mgt114_tx1p : out std_logic;
		mgt114_tx1n : out std_logic;
		mgt114_rx1p : in std_logic;
		mgt114_rx1n : in std_logic;
		
		mgt114_refclkp  : in std_logic;
		mgt114_refclkn  : in std_logic
	);
	end component ref_design;
	

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Signal Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	signal mainclkp :  std_logic := '0';
	signal mainclkn :  std_logic := '0';
	
	-- PLX Local Bus
	signal lb_adsn :  std_logic;
	signal lb_blastn :  std_logic;
	signal lb_breqo :  std_logic;
	signal lb_lclki :  std_logic;
	signal lb_lhold :  std_logic;
	signal lb_linton :  std_logic;
	signal lb_lresetn :  std_logic;
	signal lb_lserrn :  std_logic;
	signal lb_lw_rn :  std_logic;
	signal lb_usero :  std_logic;
	signal lb_waitn :  std_logic;
	signal plx_hostenn :  std_logic;
	signal lb_dackn :  std_logic_vector(1 downto 0);
	signal lb_la :  std_logic_vector(31 downto 2);
	signal lb_lben :  std_logic_vector(3 downto 0);
	signal lb_ld :  std_logic_vector(31 downto 0);
	signal lb_bigendn :  std_logic;
	signal lb_breqi :  std_logic;
	signal lb_btermn :  std_logic;
	signal lb_ccsn :  std_logic;
	signal lb_eotn :  std_logic;
	signal lb_dp :  std_logic_vector(3 downto 0);
	signal lb_dreqn :  std_logic_vector(1 downto 0);
	signal lb_lclko :  std_logic;
	signal lb_lclko_nodly :  std_logic;
	signal lb_lholda :  std_logic;
	signal lb_lintin :  std_logic;
	signal lb_pmereon :  std_logic;
	signal lb_readyn :  std_logic;
	signal lb_useri :  std_logic;
	signal lb_lclkfb : std_logic;
  signal lb_lclko_loop : std_logic;

   -- MII inteface pads
	signal miia_rxdv :  std_logic := '0';
	signal miia_rxer :  std_logic := '0';
	signal miia_rxclk :  std_logic := '0';
	signal miia_txclk :  std_logic := '0';
	signal miia_crs :  std_logic := '0';
	signal miia_col :  std_logic := '0';
	signal miib_rxdv :  std_logic := '0';
	signal miib_rxer :  std_logic := '0';
	signal miib_rxclk :  std_logic := '0';
	signal miib_txclk :  std_logic := '0';
	signal miib_crs :  std_logic := '0';
	signal miib_col :  std_logic := '0';
	signal mii_clk :  std_logic := '0';
	signal miia_rxd :  std_logic_vector(3 downto 0) := (others=>'0');
	signal miib_rxd :  std_logic_vector(3 downto 0) := (others=>'0');
	signal miia_txen :  std_logic;
	signal miia_txd :  std_logic_vector(3 downto 0);
	signal miia_intn :  std_logic;
	signal miib_txen :  std_logic;
	signal miib_txd :  std_logic_vector(3 downto 0);
	signal miib_intn :  std_logic;
	signal mii_resetn :  std_logic;
	signal mii_mdc :  std_logic;
	signal mii_mdio :  std_logic;
	
	-- GPIO pads
	signal gpio_p :  std_logic_vector(31 downto 0);
	signal gpio_n :  std_logic_vector(31 downto 0);
	
	-- DDR2 pads
	signal ddr2_dqs :  std_logic_vector(3 downto 0);
	signal ddr2_dqs_n :  std_logic_vector(3 downto 0);
	signal ddr2_a :  std_logic_vector(13 downto 0);
	signal ddr2_dq :  std_logic_vector(31 downto 0);
	signal ddr2_ba :  std_logic_vector(2 downto 0);
	signal ddr2_odt :  std_logic_vector(0 to 0);
	signal ddr2_we_n :  std_logic;
	signal ddr2_cas_n :  std_logic;
	signal ddr2_ras_n :  std_logic;
	signal ddr2_dm :  std_logic_vector(3 downto 0);
	signal ddr2_cs_n :  std_logic_vector(0 to 0);
	signal ddr2_ck :  std_logic_vector(0 to 0);
	signal ddr2_ck_n :  std_logic_vector(0 to 0);
	signal ddr2_cke :  std_logic_vector(0 to 0);

   -- Serial pads
	signal rs0_tx :  std_logic;
	signal rs0_renn :  std_logic;
	signal rs0_ten :  std_logic;
	signal rs1_tx :  std_logic;
	signal rs1_renn :  std_logic;
	signal rs1_ten :  std_logic;
	signal rs0_rx :  std_logic := '0';
	signal rs1_rx :  std_logic := '0';
	
	-- SPI flash pads
	signal spib_miso :  std_logic := '0';
	signal spib_clk :  std_logic;
	signal spib_csn :  std_logic;
	signal spib_mosi :  std_logic;
	signal spia_csn :  std_logic;
	signal spia_mosi :  std_logic;
	signal eth_ee_clk :  std_logic;
	signal eth_ee_cs :  std_logic;
	signal eth_ee_dido :  std_logic;

   -- other pads
	signal user_led :  std_logic_vector(3 downto 0);
	signal hss_user_io :  std_logic_vector(3 downto 0);

   -- misc signals
	signal simFinished : boolean := FALSE;
	signal lb_la_32 :  std_logic_vector(31 downto 0);
	signal dmWrMem : std_logic_matrix_32(15 downto 0);
	signal dmRdMem : std_logic_matrix_32(15 downto 0);
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Constant Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- PLX timing constants
    -- clock to output
    constant TCO_ADSn : time := 6.3 ns;
    constant TCO_BLASTn : time := 6.3 ns;
    --BREQo 6.8 ns
    --BTERM# 6.8 ns
    --DACK[1:0]# 6.3 ns
    --DMPAF/EOT# 6.6 ns
    --DP[3:0] 6.8 ns
    constant TCO_LA : time := 6.8 ns;
    constant TCO_LBEn : time := 6.3 ns;
    constant TCO_LD : time := 6.4 ns;
    constant TCO_LHOLD : time := 6.8 ns;
    --LSERR# 7.5 ns
    constant TCO_LWRn : time := 6.3 ns;
    constant TCO_READYn : time := 7.2 ns;
    --USERo/LLOCKo# 6.3 ns
    --WAIT# 6.4 ns

    -- setup to clock
    constant TSU_ADSn : time := 2.1 ns; -- 1 ns
    --constant BIGENDn : time :=  4.0 ns 1 ns
    constant TSU_BLASTn : time :=  3.4 ns; --1 ns
    --BREQi 0.3 ns 1 ns
    --BTERM# 4.0 ns 1 ns
    --CCS# 2.9 ns 1 ns
    --DMPAF/EOT# 4.2 ns 1 ns
    --DP[3:0] 2.9 ns 1 ns
    --DREQ[1:0]# 3.3 ns 1 ns
    constant TSU_LA : time :=  3.4 ns; -- 1 ns
    constant TSU_LBEn  : time := 3.6 ns; -- 1 ns
    constant TSU_LD : time :=  3.1 ns; -- 1 ns
    constant TSU_LHOLDA : time :=  2.5 ns; -- 1 ns
    constant TSU_LWRn : time :=  3.5 ns; -- 1 ns
    constant TSU_READYn : time :=  4.0 ns; -- 1 ns
    --USERi/LLOCKi# 2.9 ns 1 ns
    --WAIT# 4.0 ns 1 ns

----------------------------------------------------------------------------------	
BEGIN -- architecture
----------------------------------------------------------------------------------


	--============================================================================
	-- Instantiate the Unit Under Test (UUT)

	uut: ref_design
	PORT MAP(
		mainclkp => mainclkp,
		mainclkn => mainclkn,
		lb_adsn => lb_adsn,
		lb_bigendn => lb_bigendn,
		lb_blastn => lb_blastn,
		lb_breqi => lb_breqi,
		lb_breqo => lb_breqo,
		lb_btermn => lb_btermn,
		lb_ccsn => lb_ccsn,
		lb_dackn => lb_dackn,
		lb_eotn => lb_eotn,
		lb_dp => lb_dp,
		lb_dreqn => lb_dreqn,
		lb_la => lb_la,
		lb_lben => lb_lben,

		lb_lclkfb => lb_lclkfb,
		lb_ld => lb_ld,
		lb_lhold => lb_lhold,
		lb_lholda => lb_lholda,
		lb_lintin => lb_lintin,
		lb_linton => lb_linton,
		lb_lresetn => lb_lresetn,
		lb_lserrn => lb_lserrn,
		lb_lw_rn => lb_lw_rn,
		lb_pmereon => lb_pmereon,
		lb_readyn => lb_readyn,
		lb_useri => lb_useri,
		lb_usero => lb_usero,
		lb_waitn => lb_waitn,
		plx_hostenn => plx_hostenn,
		miia_rxdv => miia_rxdv,
		miia_rxer => miia_rxer,
		miia_rxd => miia_rxd,
		miia_rxclk => miia_rxclk,
		miia_txen => miia_txen,
		miia_txd => miia_txd,
		miia_txclk => miia_txclk,
		miia_crs => miia_crs,
		miia_col => miia_col,
		miia_intn => miia_intn,
		miib_rxdv => miib_rxdv,
		miib_rxer => miib_rxer,
		miib_rxd => miib_rxd,
		miib_rxclk => miib_rxclk,
		miib_txen => miib_txen,
		miib_txd => miib_txd,
		miib_txclk => miib_txclk,
		miib_crs => miib_crs,
		miib_col => miib_col,
		miib_intn => miib_intn,
		mii_clk => mii_clk,
		mii_resetn => mii_resetn,
		mii_mdc => mii_mdc,
		mii_mdio => mii_mdio,
		rs0_rx => rs0_rx,
		rs0_tx => rs0_tx,
		rs0_renn => rs0_renn,
		rs0_ten => rs0_ten,
		rs1_rx => rs1_rx,
		rs1_tx => rs1_tx,
		rs1_renn => rs1_renn,
		rs1_ten => rs1_ten,
		spib_clk => spib_clk,
		spib_csn => spib_csn,
		spib_mosi => spib_mosi,
		spib_miso => spib_miso,
		spia_csn => spia_csn,
		spia_mosi => spia_mosi,
		eth_ee_clk => eth_ee_clk,
		eth_ee_dido => eth_ee_dido,
		eth_ee_cs => eth_ee_cs,
		gpio_p => gpio_p,
		gpio_n => gpio_n,
		ddr2_a => ddr2_a,
		ddr2_dq => ddr2_dq,
		ddr2_dqs => ddr2_dqs,
		ddr2_dqs_n => ddr2_dqs_n,
		ddr2_ba => ddr2_ba,
		ddr2_odt => ddr2_odt,
		ddr2_we_n => ddr2_we_n,
		ddr2_cas_n => ddr2_cas_n,
		ddr2_ras_n => ddr2_ras_n,
		ddr2_dm => ddr2_dm,
		ddr2_cs_n => ddr2_cs_n,
		ddr2_ck => ddr2_ck,
		ddr2_ck_n => ddr2_ck_n,
		ddr2_cke => ddr2_cke,
		user_led => user_led,
		hss_user_io => hss_user_io,
		mgt112_tx0p => open,
		mgt112_tx0n => open,
		mgt112_rx0p => '1',
		mgt112_rx0n	=> '0',
		mgt112_tx1p => open,
		mgt112_tx1n => open,
		mgt112_rx1p => '1',
		mgt112_rx1n => '0',
		mgt114_tx0p => open,
		mgt114_tx0n => open,
		mgt114_rx0p => '1',
		mgt114_rx0n	=> '0',
		mgt114_tx1p => open,
		mgt114_tx1n => open,
		mgt114_rx1p => '1',
		mgt114_rx1n => '0',
		mgt114_refclkp  => '1',
		mgt114_refclkn  => '0'	
	);


	--============================================================================
	-- Clocking
	
    p_clock100 : PROCESS
		begin
		mainclkp  <= '0';
		mainclkn  <= '1';
		wait for 5 ns;
		mainclkp  <= '1';
		mainclkn  <= '0';
		wait for 5 ns;
    end PROCESS;										   

g_clk50OscY : if c_clk50Osc = TRUE generate
    p_clock50 : PROCESS
		begin
		lb_lclkfb  <= '0';
		wait for 10 ns;
		lb_lclkfb  <= '1';
		wait for 10 ns;
    end PROCESS;	
	
	lb_lclko <= lb_lclkfb;
end generate;

g_clk50OscN : if c_clk50Osc = FALSE generate
	lb_lclkfb <= lb_lclko_loop after 3 ns;
end generate;
	
    lb_la_32 <= lb_la & "00";

	p_reset : process
	begin
		lb_lresetn  <= '0';
		wait for 100 ns;
		lb_lresetn  <= '1';
		wait;
	end process;

	--============================================================================
	-- Default pullups
	
	lb_lresetn <= 'H';
	lb_lholda <= 'L';
	lb_breqi <= 'L';
	lb_readyn <= 'H';
	lb_blastn <= 'H';
	lb_btermn <= 'H';
	lb_waitn <= 'H';
	lb_lw_rn <= 'H';
	lb_useri <= 'H';
	lb_lintin <= 'H';
	lb_ccsn <= 'H';
	lb_bigendn <= 'H';
	--pmereqn?
	lb_dreqn <= "HH";
	lb_eotn <= 'H';
	lb_dackn <= "HH";
	
	lb_lben <= "HHHH";
	plx_hostenn <= 'H';
	lb_dackn <= "HH";
	lb_linton <=  'H';
	lb_adsn <= 'H';
	lb_dp <= "HHHH";
	lb_lserrn <= 'H';
	lb_breqo <= 'L';

	




	--============================================================================
	stimulus : PROCESS
	--============================================================================	

		variable dataBuf : std_logic_matrix_32(15 downto 0);
		variable dataBen : std_logic_matrix_04(15 downto 0);
		variable i_vec : std_logic_vector(3 downto 0);

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		procedure clearDataBuf is
		begin
		   for i in 0 to dataBuf'Left loop
			  dataBuf(i) := (others => '0');
			  dataBen(i) := (others => '1');
		 end loop;
		end procedure;

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		procedure idleBus (tadj : in time) is
		begin
		   wait for TCO_adsn - tadj;  -- 6.3
			lb_adsn <= '1';
			lb_blastn <= '1';
			lb_lw_rn <= '1';
			lb_lben <= (others => '1');
			wait for 1 ns; -- 6.4
			lb_ld <= (others => 'Z');
			wait for 4 ns; -- 6.8
			lb_la <= (others => '0');
			wait for 4 ns;
			lb_readyn <= 'Z';
		end procedure;	

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
		procedure tristateBus (tadj : in time) is
		begin
		   wait for TCO_adsn - tadj;  -- 6.3
			lb_adsn <= 'Z';
			lb_blastn <= 'Z';
			lb_lw_rn <= 'Z';
			lb_lben <= (others => 'Z');
			wait for 1 ns; -- 6.4
			lb_ld <= (others => 'Z');
			wait for 4 ns; -- 6.8
			lb_la <= (others => 'Z');
			wait for 4 ns;
			lb_readyn <= 'Z';
		end procedure;	

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		procedure acquireBus is
		begin
			wait until rising_edge(lb_lclko);
			wait for TCO_LHOLD;
			lb_lhold <= '1';
			
			while lb_lholda = '0' loop
	      		wait until rising_edge(lb_lclko);
	         wait for	TSU_LHOLDA;
	  		end loop;
			
			idleBus(TSU_LHOLDA);
			msg("bus acquired");
		end procedure;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
		procedure releaseBus is
		begin
			wait until rising_edge(lb_lclko);
			wait for TCO_LHOLD;
			lb_lhold <= '0';
			
			while lb_lholda = '1' loop
	      		wait until rising_edge(lb_lclko);
	        wait for	TSU_LHOLDA;
	  		end loop;
			
			tristateBus(TSU_LHOLDA);
			
			msg("bus released");
		end procedure;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
		procedure writeSingleCycle(	addr : in std_logic_vector(31 downto 0); 
									data : in std_logic_vector(31 downto 0) ) is
									
			variable tmp : std_logic_vector(31 downto 0);
		begin
			--wait for 2 ns;
			
			wait until rising_edge(lb_lclko);
			
			if (lb_lholda = '1') then
		
	         wait for TCO_adsn;
				lb_adsn <= '0';
				wait for 5 ns;
				lb_la <= addr(31 downto 2);
			
				wait until rising_edge(lb_lclko);
				wait for TCO_adsn;
				lb_adsn <= '1';
				lb_lben <= x"0";
				lb_blastn <= '0';
				lb_lw_rn <= '1';
				wait for 1 ns;
				lb_ld <= data;
				
				while (lb_readyn = '1') loop
	            			wait until rising_edge(lb_lclko);
	            			wait for TSU_readyn;
	     			end loop;
	     			
	     			-- Data should be clock in here
	         tmp := lb_la & "00";
	     			msg ("Wrote Addr:" & hstr( tmp ) & " Data:" & hstr( lb_ld ) );
	     			
	  			while (lb_readyn = '0') loop
	            			wait until rising_edge(lb_lclko);
	            			wait for TSU_readyn; 
	     			end loop;
	     			
				--wait for 2 ns;
				--lb_blastn <= '1';
				idleBus(TSU_readyn);
				
				--wait until rising_edge(lb_lclko);
				
			else
				msg("bus not acquired");
			end if;
			
			wait for 50 ns;
		end procedure;

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		procedure writeBurst(	addr_in : in std_logic_vector(31 downto 0); 
									data : in std_logic_matrix_32(15 downto 0);
									start_index : natural;
									ben : in std_logic_matrix_04(15 downto 0);
									burstSize : natural ) is
									
		    variable i : natural := 0;
			variable cnt : natural := 0;
			variable addr : std_logic_vector(31 downto 0);
			variable tmp : std_logic_vector(31 downto 0);
		begin
		
		i := start_index;
		addr := addr_in;
		
		wait until rising_edge(lb_lclko);
		
		if (lb_lholda = '1') then
		
			wait for TCO_adsn;
			lb_adsn <= '0';
			wait for 5 ns;
			lb_la <= addr(31 downto 2);
			
			wait until rising_edge(lb_lclko);
			wait for TCO_adsn;
			lb_adsn <= '1';
			lb_lben <= ben(i);
			lb_lw_rn <= '1';
			wait for 1 ns;			
			lb_ld <= data(i);
			
			while (lb_readyn = '1') loop
				wait until rising_edge(lb_lclko);
				wait for TSU_readyn;
			end loop;
			
			while (lb_readyn = '0') and (cnt  < burstSize) loop
				
				wait for (TCO_lben - TSU_readyn);
				lb_lben <= ben(i);
				
				if 	(cnt = burstSize-1) then
					lb_blastn <= '0';   
				end if;
				
				wait for 1 ns;
				lb_ld <= data(i); 		
				
				wait for 4 ns;
				lb_la <= addr(31 downto 2);
				
				wait for 0.1 ns; -- for assignment to be complete.               
				tmp := lb_la & "00";
				msg ("Wrote Addr:" & hstr( tmp ) & " Data:" & hstr( lb_ld ) );
				
				wait until rising_edge(lb_lclko);
				wait for TSU_readyn;
				--wait for 2 ns;
				i := i+1; 
				cnt	:= cnt + 1;
				addr := addr + 4;
			end loop;
			
			--wait for 2 ns;
			--lb_blastn <= '1';
			idleBus(TSU_readyn);
			
			--wait until rising_edge(lb_lclko);
			msg ("Burst write complete" );
			else
			msg("bus not acquired");
		end if;
		
		wait for 50 ns;
		end procedure;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		procedure readSingleCycle(	addr : in std_logic_vector(31 downto 0); 
									exdata : in std_logic_vector(31 downto 0) ) is
									
			variable tmp : std_logic_vector(31 downto 0);
		begin

			wait until rising_edge(lb_lclko);
			
			if (lb_lholda = '1') then
		
				wait for TCO_lwrn;
				lb_lw_rn <= '0';

				wait until rising_edge(lb_lclko);
				wait for TCO_adsn;
				lb_adsn <= '0';
				lb_lben <= x"0";
				wait for 5 ns;         
				lb_la <= addr(31 downto 2);

				wait until rising_edge(lb_lclko);
				wait for TCO_adsn;
				lb_adsn <= '1';
				lb_blastn <= '0';

				while lb_readyn = '1' loop
					wait until rising_edge(lb_lclko);
					wait for	TSU_readyn;
				end loop;

				--wait for TSU_LD;
				tmp := lb_la & "00";
				msg ("Read Addr:" & hstr( tmp ) & " Data:" & hstr( lb_ld ) );
				
				assert (exdata = lb_ld) 
					REPORT "Read Data [ "& hstr( lb_ld ) & " ] <> Expected Data [ " & hstr( exdata ) & " ]"
					SEVERITY ERROR;

				while lb_readyn = '0' loop
					wait until rising_edge(lb_lclko);
					wait for TSU_readyn;
				end loop;

				wait for TCO_blastn - TSU_readyn;
				lb_blastn <= '1';

				wait until rising_edge(lb_lclko);			
				idleBus(0 ns);
				
			else
				msg("bus not acquired");
			end if;
			
			wait for 50 ns;
		end procedure;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		procedure readBurst(	addr_in : in std_logic_vector(31 downto 0); 
									exdata : in std_logic_matrix_32(15 downto 0);
									start_index : natural;
									burstSize : natural ) is								
		    variable i : natural := 0;
			variable cnt : natural := 0;
			variable addr : std_logic_vector(31 downto 0);
			variable tmp : std_logic_vector(31 downto 0);
		begin
		
			i := start_index;
			addr := addr_in;
			
			wait until rising_edge(lb_lclko);
			
			if (lb_lholda = '1') then
			
			wait for TCO_lwrn;
			lb_lw_rn <= '0';
			
			wait until rising_edge(lb_lclko);
			wait for TCO_adsn;
			lb_adsn <= '0';
			lb_lben <= x"0";
			wait for 5 ns;
			lb_la <= addr(31 downto 2);
					
			wait until rising_edge(lb_lclko);


			while cnt < burstSize loop
			
				wait for TCO_blastn;
				if 	(cnt = burstSize-1) then
					lb_blastn <= '0';   
				end if;
				
				lb_adsn <= '1';

				wait for 5 ns;				
				lb_la <= addr(31 downto 2);
				
				-- if readyn goes low before we have finished reading...
				while lb_readyn = '1' loop
					wait until rising_edge(lb_lclko);
					wait for TSU_readyn;
				end loop;	
				
				wait for 1 ns;

				tmp := lb_la & "00";
				msg ("Read Addr:" & hstr( tmp ) & " Data:" & hstr( lb_ld ) );
				
				wait for TSU_ld;
				assert (exdata(i) = lb_ld) 
					REPORT "Read Data [ "& hstr( lb_ld ) & " ] <> Expected Data [ " & hstr( exdata(i) ) & " ]"
					SEVERITY ERROR;
								
		  
				
				wait until rising_edge(lb_lclko);	
				i := i+1;
				cnt := cnt + 1;
				addr := addr + 4;
			
			end loop;

				wait for (TCO_blastn-TSU_readyn);
				lb_blastn <= '1';
				
				wait until rising_edge(lb_lclko);
				idleBus(0 ns);
				
				
			else
				msg("bus not acquired");
			end if;
			
			wait for 50 ns;
			
		end procedure;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		procedure dmTransaction is								
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		    variable i : natural := 0;
			variable cnt : natural := 0;
			variable addr : std_logic_vector(31 downto 0);
			variable tmp : std_logic_vector(31 downto 0);
			variable lastCycle : boolean := FALSE;
		begin
			wait until rising_edge(lb_lclko);
			
			if lb_lholda = '0' then
			
	        wait for	TCO_READYn;
			lb_readyn <= '1';
			
	        while lb_adsn = '1' or lb_adsn = 'H' loop
	        	wait until rising_edge(lb_lclko);
				wait for TSU_ADSn;
	  		end loop;
	      
	        while lb_adsn = '0' loop
	        		wait until rising_edge(lb_lclko);
					wait for TSU_ADSn;
	  		end loop;
	        
			while lastCycle = FALSE loop
			
				wait until rising_edge(lb_lclko);
				wait for TSU_BLASTn;
	          		if lb_blastn = '0' then
	          		   lastCycle := TRUE;       		    
	  		    end if;
	  		    
	            wait for	TCO_READYn-TSU_BLASTn;			
				lb_readyn <= '0';
				
				tmp := lb_la & "00";
				
				
				i := to_integer( unsigned(lb_la(5 downto 2)) );
				
				if (lb_lw_rn = '1') then
					-- write
					msg ("Direct master:" & hstr( tmp ) & " Data:" & hstr( lb_ld ) );
					if lb_la(31 downto 8) = x"000001" then
	         				dmWrMem(i) <= lb_ld;
	    				end if;
				else
					-- read
					msg ("Direct master:" & hstr( tmp ) & " Data:" & hstr( dmRdMem(i) ) );
					if lb_la(31 downto 8) = x"000002" then		
	         				lb_ld <= dmRdMem(i);
	    				end if;
				end if;
	            
	        end loop;
			
			while lb_blastn='0' loop
			    wait until rising_edge(lb_lclko);
			    wait for TSU_BLASTn;
			end loop;
			
			wait for TCO_READYn-TSU_BLASTn;
			lb_readyn <= '1';
			
			end if;
			
			wait for 50 ns;
				
		end procedure;
	
	
		procedure configWait is								
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		    variable i : natural := 0;
			variable cnt : natural := 0;
			variable addr : std_logic_vector(31 downto 0);
			variable tmp : std_logic_vector(31 downto 0);
			variable lastCycle : boolean := FALSE;
		begin
			wait until rising_edge(lb_lclko);
			
			if lb_lholda = '0' then
			
	        wait for	TCO_READYn;
			
			lb_readyn <= '1';

	      
			while lastCycle = FALSE loop
			
				i := 0;
				while (lb_adsn = '1' or lb_adsn = 'H') and i < 20 loop
					wait until rising_edge(lb_lclko);
					wait for TSU_ADSn;
					
					i := i + 1;
				end loop;
				
	         lb_readyn <= '1';
				
				if i >= 20 then
				    msg("adsn high for 20 cycles");
				    lastCycle := true;
				    		exit;
				end if;
				

				
				while lb_adsn = '0' loop
		        		wait until rising_edge(lb_lclko);
						wait for TSU_ADSn;
						msg("wait address high");
		  		end loop;
	        
				wait until rising_edge(lb_lclko);
				wait for TSU_BLASTn;
	     
	  		    
	            wait for	TCO_READYn-TSU_BLASTn;			
				lb_readyn <= '0';
				
				tmp := lb_la & "00";
				
				
				--i := to_integer( unsigned(lb_la(5 downto 2)) );
				
				if (lb_ccsn = '0') then
					if (lb_lw_rn = '1') then
						-- write
						msg ("Configuration write:" & hstr( tmp ) & " Data:" & hstr( lb_ld ) );
					else
						-- read
						msg ("Configuration read:" );
					end if;
				else
					msg ("Expecting configuraiton cylce" );
				end if;
	            
	        end loop;
			
			while lb_blastn='0' loop
			    wait until rising_edge(lb_lclko);
			    wait for TSU_BLASTn;
			end loop;
			
			wait for TCO_READYn-TSU_BLASTn;
			lb_readyn <= '1';
			
			end if;
			
			wait for 50 ns;
				
		end procedure;
	begin -- PROCESS
		tristateBus(0 ns);
		clearDataBuf;
		wait until lb_lresetn = '1';
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("Configuration writes.");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 
		configWait;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("4 single writes, 4 single reads");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 
		
		acquireBus;
		writeSingleCycle(x"00000100", x"11223344");
		writeSingleCycle(x"00000104", x"55667788");
		writeSingleCycle(x"00000108", x"99AABBCC");
		writeSingleCycle(x"0000010C", x"DDEEFF00");
		wait for 20 ns;
		readSingleCycle(x"00000100", x"11223344");
		readSingleCycle(x"00000104", x"55667788");
		readSingleCycle(x"00000108", x"99AABBCC");
		readSingleCycle(x"0000010C", x"DDEEFF00");
		releaseBus;
		
		wait for 100 ns;
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("Burst Write, 4 single reads");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 
		
		dataBuf(0) := x"aa223344";
		dataBuf(1) := x"aa667788";
		dataBuf(2) := x"aaAABBCC";
		dataBuf(3) := x"aaEEFF00";
		dataBuf(4) := x"00000001"; -- FPGA will stop storing; because it is limited burst 4
		dataBuf(5) := x"00000002";
		dataBuf(6) := x"00000003";
		dataBuf(7) := x"00000004";   
			  
		dataBen(0) := x"0";
		dataBen(1) := x"0";
		dataBen(2) := x"0";
		dataBen(3) := x"0";
		dataBen(4) := x"0";
		dataBen(5) := x"0";
		dataBen(6) := x"0";
		dataBen(7) := x"0";
	    
	    acquireBus;
		writeBurst(x"00000110", dataBuf, 0, dataBen, 8);
	    readSingleCycle(x"00000110", dataBuf(0));
		readSingleCycle(x"00000114", dataBuf(1));
		readSingleCycle(x"00000118", dataBuf(2));
		readSingleCycle(x"0000011C", dataBuf(3));
		--readSingleCycle(x"00000110", x"00000000");
		releaseBus;
		
		wait for 100 ns;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("Read burst, expect failures on last 4 dwords.");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 
		acquireBus;
		
		-- expect dummy data for last 4 lwords of burst
		dataBuf(0) := x"11223344";
		dataBuf(1) := x"55667788";
		dataBuf(2) := x"99AABBCC";
		dataBuf(3) := x"DDEEFF00"; 
		dataBuf(4) := x"aa223344";
		dataBuf(5) := x"aa667788";
		dataBuf(6) := x"aaAABBCC";
		dataBuf(7) := x"aaEEFF00";
		
		readBurst(x"00000100", dataBuf, 0, 8);
		releaseBus;
		
		
		wait for 100 ns;
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("Write Burst, Bytes");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 	
	    dataBuf(0) := x"AAAAAAAA";
	    dataBuf(1) := x"BBBBBBBB";
	    dataBuf(2) := x"CCCCCCCC";
	    dataBuf(3) := x"DDDDDDDD";
	    
	    dataBen(0) := x"E";
	    dataBen(1) := x"D";
	    dataBen(2) := x"B";
	    dataBen(3) := x"7";
		
		acquireBus;
		writeBurst(x"00000120", dataBuf, 0, dataBen, 4);
		
		readSingleCycle(x"00000120", x"000000AA");
		readSingleCycle(x"00000124", x"0000BB00");
		readSingleCycle(x"00000128", x"00CC0000");
		readSingleCycle(x"0000012C", x"DD000000");
		releaseBus;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("Read/Write To memory");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 	
		acquireBus;
		
		for i in 0 to 15 loop
			i_vec := std_logic_vector(to_unsigned(i,4));
			dataBuf(i) := i_vec & i_vec & i_vec & i_vec & i_vec & i_vec & i_vec & i_vec;
			dataBen(i) := "0000";
		end loop;
		
		
		writeBurst(x"00000140", dataBuf, 0, dataBen, 4);
		writeBurst(x"00000150", dataBuf, 4, dataBen, 4);
		writeBurst(x"00000160", dataBuf, 8, dataBen, 4);
		writeBurst(x"00000170", dataBuf, 12, dataBen, 4);
		
		msg("4 LWORD Read-burst 0x40");
		readBurst(x"00000140", dataBuf, 0,  4);
		msg("4 LWORD Read-burst 0x50");
		readBurst(x"00000150", dataBuf, 4,  4);
		msg("4 LWORD Read-burst 0x60");
		readBurst(x"00000160", dataBuf, 8,  4);
		msg("4 LWORD Read-burst 0x70");
		readBurst(x"00000170", dataBuf, 12,  4);
		
	--	readSingleCycle(x"00000040", x"00000000");
	--	readSingleCycle(x"00000044", x"11111111");
	--	readSingleCycle(x"00000048", x"22222222");
	--	readSingleCycle(x"0000004C", x"33333333");
	--	
	--	readSingleCycle(x"00000050", x"44444444");
	--	readSingleCycle(x"00000054", x"55555555");
	--	readSingleCycle(x"00000058", x"66666666");
	--	readSingleCycle(x"0000005C", x"77777777");
	--	
	--	readSingleCycle(x"00000060", x"88888888");
	--	readSingleCycle(x"00000064", x"99999999");
	--	readSingleCycle(x"00000068", x"AAAAAAAA");
	--	readSingleCycle(x"0000006C", x"BBBBBBBB");
	--	
	--	readSingleCycle(x"00000070", x"CCCCCCCC");				
	--	readSingleCycle(x"00000074", x"DDDDDDDD");				
	--	readSingleCycle(x"00000078", x"EEEEEEEE");				
	--   readSingleCycle(x"0000007C", x"FFFFFFFF");		
		
		releaseBus;
		
		wait for 100 ns;
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("Setup master transaction");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 
		
		dmRdMem(0) <= x"01010101";
		dmRdMem(1) <= x"02010101";
		dmRdMem(2) <= x"03010101";
		dmRdMem(3) <= x"04010101";
		dmRdMem(4) <= x"05010101";			
		dmRdMem(5) <= x"06010101";
		dmRdMem(6) <= x"07010101";
		dmRdMem(7) <= x"08010101";
		dmRdMem(8) <= x"09010101";
		dmRdMem(9) <= x"0A010101";
		dmRdMem(10) <= x"0B010101";
		dmRdMem(11) <= x"0C010101";
		dmRdMem(12) <= x"0D010101";
		dmRdMem(13) <= x"0E010101";							
		dmRdMem(14) <= x"0F010101";								
		dmRdMem(15) <= x"01010102";										

		msg("setup dm write");
		acquireBus;
		writeSingleCycle(x"00000034", x"00000100");	-- addr
		writeSingleCycle(x"00000038", x"00000004");	-- cnt 
		writeSingleCycle(x"00000030", x"00000003");	-- ctrl
		releaseBus;
		
		dmTransaction;
		
		wait for 200 ns;
		
		msg("setup dm read");
		acquireBus;
		writeSingleCycle(x"00000034", x"00000200");	-- addr
		writeSingleCycle(x"00000038", x"00000009");	-- cnt
		writeSingleCycle(x"00000030", x"00000000");	-- clear ctrl
		writeSingleCycle(x"00000030", x"00000001");	-- ctrl
		releaseBus;
		
		dmTransaction;
		
		wait for 200 ns;
		
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		title("SIMULATION COMPLETE");
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	  
		simFinished <= TRUE;
	end process;

	--============================================================================
	-- p_dm : process
	--============================================================================
	-- begin
       --dmTransaction;
    -- end process p_dm;
END simulation;