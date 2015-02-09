--********************************************************************************
-- Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary Information of Connect Tech, Inc
-- and should be treated as Confidential.
--********************************************************************************
-- Project: 	FreeForm/PCI-104
-- Module:		ref_design
-- Parent:		N/A
-- Description: Top level module, includes
--					* PLX slave
--					* PLX master
--					* SPI programmer
--					* Register controlled GPIO
--					* TEMAC interface
--					* EEPROM interface
--					* DDR2 Memory interface
--					* GTP / GTX interface
--
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-05-22	MF		Created from emac_plx.vhd
-- 2008-07-08	MF		Added generics for revision C hardware
-- 2008-09-17	MF		Added revision configuration package
-- 2008-12-08	MF		Added new emac and rocketio modules
-- 2008-12-12	MF		Merged with tester.vhd
-- 2009-03-13	MF		Add ds0,ds1 space enables for config rom
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.ffpci104_pkg.all;  --- ensure correct package is added, contains definitions for product
use work.ctiUtil.all;

library UNISIM;
use UNISIM.Vcomponents.all;

----------------------------------------------------------------------------------
entity ref_design is
----------------------------------------------------------------------------------
generic ( 
	c_revMajor 		: std_logic_vector(7 downto 0) := x"04";
	c_revMinor 		: std_logic_vector(7 downto 0) := x"00";
	c_revBuild		: std_logic_vector(7 downto 0) := x"00"
	);
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
end ref_design;

----------------------------------------------------------------------------------	
architecture rtl of ref_design is
----------------------------------------------------------------------------------
	constant GND_BITS		: std_logic_vector(31 downto 0) := (others => '0');
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- component DECLARATIONS
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	component clkControl is
	generic ( simulation : boolean := false );
	port ( 
		mainclkp : in  STD_LOGIC;
		mainclkn : in  STD_LOGIC;
		lclkfb : in  STD_LOGIC;
		lclkfb_out : out std_logic;
		lclko : out  STD_LOGIC_vector(1 downto 0);  
		clkfx : out std_logic;
		clk50 : out  STD_LOGIC;
		clk100 : out  STD_LOGIC;
		clk200 : out  STD_LOGIC;
		clk200Locked : out std_logic;
		allClkStable : out std_logic
	);
	end component;
	
	component clkControlMem is
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
	end component;	
	
	component plx32BitSlave
	port (
		lresetn			: in std_logic; 							-- Local bus reset
		lclk			: in std_logic;								-- Local clock input
		ld_dir			: out std_logic;
		lben			: in std_logic_vector(3 downto 0);			-- Local Byte Enables
		adsn			: in std_logic;								-- Addres Strobe
		blastn			: in std_logic;								-- Burst last
		READYn			: out std_logic;							-- READY I/O
		lw_rn			: in std_logic;								-- Local Write/Read															
		--lserrn        	: out std_logic;
		plxAck			: in std_logic;
		addrValid0		: in std_logic;
		addrValid1		: in std_logic;		
		wrByte0			: out std_logic_vector( 3 downto 0);
		wrByte1			: out std_logic_vector( 3 downto 0);		
		ramAccess0		: in std_logic;
		ramAccess1		: in std_logic;
		burst4			: in std_logic
	);
	end component;

	component plxArb
	port(
		lresetn : in std_logic;
		lclk : in std_logic;
		dsReq : in std_logic;
		dsReqForce : in std_logic;
		dmReq : in std_logic;          
		dsAck : OUT std_logic;
		dmAck : OUT std_logic;
		dmBackoff : OUT std_logic;
		allClkStable : in std_logic
	);
	end component;

	component plx32BitMaster
    generic (	
		c_cfgRomSize : integer := 18;
		c_ramWidth : integer := 4;
		c_txfrCntWidth : natural :=6;
		c_enPlxCfg : boolean := TRUE
	);
	port (
		lclk			: in std_logic;							
		la				: out std_logic_vector(31 downto 2);		
		ld_dir			: out std_logic;
		lben			: out std_logic_vector(3 downto 0);		
		adsn			: out std_logic;							
		blastn			: out std_logic;							
		readyn			: in std_logic;						
		lw_rn			: out std_logic;							
		lresetn			: in std_logic;
		ccsn			: out std_logic;
		dmpaf			: in std_logic;
		req				: out std_logic;
		ack				: in std_logic;
		backoff			: in std_logic;
		txfrCtrl		: in std_logic_vector(1 downto 0);
		txfrAddr		: in std_logic_vector(31 downto 0);
		txfrCnt			: in std_logic_vector(c_txfrCntWidth-1 downto 0);
		int				: out std_logic;
		cfgComplete		: out std_logic;
		ramAddr 		: out std_logic_vector(c_ramWidth-1 downto 0);
		ramWr 			: out std_logic_vector( 3 downto 0);
		ramEn 			: out std_logic;
		cfgRomPtr 		: out unsigned(4 downto 0);
        cfgRomDout 		: in std_logic_vector(47 downto 0);
		stateOut 		: out std_logic_vector(6 downto 0)
	);
	end component;

	component plxBusMonitor
	port(
		clk : in std_logic;
		lb_adsn : in std_logic;
		lb_bigendn : in std_logic;
		lb_blastn : in std_logic;
		lb_breqi : in std_logic;
		lb_breqo : in std_logic;
		lb_btermn : in std_logic;
		lb_ccsn : in std_logic;
		lb_dackn : in std_logic_vector(1 downto 0);
		lb_eotn : in std_logic;
		lb_dp : in std_logic_vector(3 downto 0);
		lb_dreqn : in std_logic_vector(1 downto 0);
		lb_la : in std_logic_vector(31 downto 2);
		lb_lben : in std_logic_vector(3 downto 0);
		lb_lclko : in std_logic;
		lb_lclki : in std_logic;
		lb_ld : in std_logic_vector(31 downto 0);
		lb_lhold : in std_logic;
		lb_lholda : in std_logic;
		lb_lintin : in std_logic;
		lb_linton : in std_logic;
		lb_lresetn : in std_logic;
		lb_lserrn : in std_logic;
		lb_lw_rn : in std_logic;
		lb_pmereon : in std_logic;
		lb_readyn : in std_logic;
		lb_useri : in std_logic;
		lb_usero : in std_logic;
		lb_waitn : in std_logic;
		allClkStable : in std_logic 
	);
	end component;

	component blockRAM
	port (
		clka: in std_logic;
		dina: in std_logic_VECTOR(31 downto 0);
		addra: in std_logic_VECTOR(3 downto 0);
		ena: in std_logic;
		wea: in std_logic_VECTOR(3 downto 0);
		douta: OUT std_logic_VECTOR(31 downto 0)
	);
	end component;

	component regBank_32 is
		generic	( 	selWidth : natural := 4;
					busReadOnly : bit_vector (63 downto 0) := (others=>'0') );
		port ( 
			clk : in  STD_LOGIC;
			rstn : in  STD_LOGIC;
			
			busEn : in std_logic;
			busSel : in  STD_LOGIC_vector((selWidth-1) downto 0);
			busWr : in  STD_LOGIC_vector(3 downto 0);
			busin : in  STD_LOGIC_VECTOR (31 downto 0);
			busOut : out  STD_LOGIC_VECTOR (31 downto 0);
	
			localWr : in std_logic_matrix_04(((2**selWidth)-1) downto 0);
			localin : in  std_logic_matrix_32 (((2**selWidth)-1) downto 0);
			localOut : out   std_logic_matrix_32 (((2**selWidth)-1) downto 0)   
	   );
	end component;

	component plxCfgRom
	generic ( 	
		c_romSize 	: integer := 20;
		c_ds0BaseAddr : std_logic_vector(31 downto 4) := x"0000000"; 
		c_ds0ByteSz	: natural := 128;
		c_ds0En		: std_logic := '1';				
		c_ds1BaseAddr : std_logic_vector(31 downto 4) := x"1000000"; 
		c_ds1ByteSz	: natural := 512;
		c_ds1En		: std_logic := '1'		
				);
	port(
		clk : in std_logic;
		addr : in unsigned(4 downto 0);          
		dout : OUT std_logic_vector(47 downto 0)
		);
	end component;

	component lbDoutMux
	port ( 	
		owner 	: in std_logic;
		dsSpace : in std_logic;
		ds0Sel 	: in std_logic;
		ds1Sel 	: in std_logic;
		ds0Data : in std_logic_matrix_32(1 downto 0);
		ds1Data : in std_logic_matrix_32(1 downto 0);		
		dmSel 	: in std_logic;
		dmData 	: in std_logic_matrix_32(1 downto 0);
		dout 	: out std_logic_vector(31 downto 0)
	);
	end component;

--	component plxSPI
--	port(
--		rst			: in std_logic;
--		clk			: in std_logic;
--		cmdReg		: in std_logic_vector(7 downto 0);
--		paramReg	: in std_logic_matrix_08(3 downto 0);
--		statusReg	: out std_logic_vector(7 downto 0);
--		statusRegWr	: out std_logic;
--		resultReg	: out std_logic_matrix_08(3 downto 0);
--		resultRegWr	: out std_logic_vector(3 downto 0);
--		dpDin		: out std_logic_vector(7 downto 0);
--		dpDout		: in std_logic_vector(7 downto 0);
--		dpAddr		: out std_logic_vector(7 downto 0);
--		dpWr		: out std_logic;
--		spiSck		: out std_logic;
--		spiSdo		: in std_logic;
--		spiSdi		: out std_logic;
--		spiCsn		: out std_logic
--		--reprogram	: out std_logic
--	);
--	end component;	

	component dpRam32_8
		port (
		clka: in std_logic;
		dina: in std_logic_VECTOR(31 downto 0);
		addra: in std_logic_VECTOR(5 downto 0);
		ena: in std_logic;
		wea: in std_logic_VECTOR(3 downto 0);
		douta: OUT std_logic_VECTOR(31 downto 0);
		clkb: in std_logic;
		dinb: in std_logic_VECTOR(7 downto 0);
		addrb: in std_logic_VECTOR(7 downto 0);
		web: in std_logic_VECTOR(0 downto 0);
		doutb: OUT std_logic_VECTOR(7 downto 0));
	end component;
	
	component v5internalConfig
	port(
		clk : in std_logic;
		start : in std_logic    
		);
	end component;

	component mig20_app is
  generic(
   BANK_WIDTH           : integer := 2; -- # of memory bank addr bits
   CKE_WIDTH            : integer := 1; -- # of memory clock enable outputs
   CLK_WIDTH            : integer := 2; -- # of clock outputs
   COL_WIDTH            : integer := 10; -- # of memory column bits
   CS_NUM               : integer := 1; -- # of separate memory chip selects
   CS_WIDTH             : integer := 2; -- # of total memory chip selects
   CS_BITS              : integer := 0; -- set to log2(CS_NUM) (rounded up)
   DM_WIDTH             : integer := 4; -- # of data mask bits
   DQ_WIDTH             : integer := 32; -- # of data width
   DQ_PER_DQS           : integer := 8; -- # of DQ data bits per strobe
   DQS_WIDTH            : integer := 4; -- # of DQS strobes
   DQ_BITS              : integer := 5; -- set to log2(DQS_WIDTH*DQ_PER_DQS)
   DQS_BITS             : integer := 2; -- set to log2(DQS_WIDTH)
   ODT_WIDTH            : integer := 2; -- # of memory on-die term enables
   ROW_WIDTH            : integer := 13; -- # of memory row and # of addr bits
   ADDITIVE_LAT         : integer := 0; -- additive write latency 
   BURST_LEN            : integer := 4; -- burst length (in double words)
   BURST_TYPE           : integer := 0; -- burst type (=0 seq; =1 interleaved)
   CAS_LAT              : integer := 3; -- CAS latency
   ECC_ENABLE           : integer := 0; -- enable ECC (=1 enable)
   APPDATA_WIDTH        : integer := 64; -- # of usr read/write data bus bits
   MULTI_BANK_EN        : integer := 1; -- Keeps multiple banks open. (= 1 enable)
   TWO_T_TIME_EN        : integer := 0; -- 2t timing for unbuffered dimms
   ODT_TYPE             : integer := 3; -- ODT (=0(none),=1(75),=2(150),=3(50))
   REDUCE_DRV           : integer := 0; -- reduced strength mem I/O (=1 yes)
   REG_ENABLE           : integer := 0; -- registered addr/ctrl (=1 yes)
   TREFI_NS             : integer := 7800; -- auto refresh interval (ns)
   TRAS                 : integer := 40000; -- active->precharge delay
   TRCD                 : integer := 15000; -- active->read/write delay
   TRFC                 : integer := 105000; -- refresh->refresh, refresh->active delay
   TRP                  : integer := 15000; -- precharge->command delay
   TRTP                 : integer := 7500; -- read->precharge delay
   TWR                  : integer := 15000; -- used to determine write->precharge
   TWTR                 : integer := 7500; -- write->read delay
   SIM_ONLY             : integer := 0; -- = 1 to skip SDRAM power up delay
   DEBUG_EN             : integer := 0; -- Enable debug signals/controls
-- DQS_IO_COL           : bit_vector := "10000000"; -- I/O column location of DQS groups (=0, left; =1 center, =2 right)
   DQS_IO_COL 			: bit_vector := "00001000"; 
-- DQ_IO_MS             : bit_vector := "10100101101001011010010110100101"; -- Master/Slave location of DQ I/O (=0 slave) 
   DQ_IO_MS				: bit_vector := "11101000001001101011001010100110"; -- Master/Slave location of DQ I/O (=0 slave)
   CLK_PERIOD           : integer := 5000; -- Core/Memory clock period (in ps)
   RST_ACT_LOW          : integer := 1; -- =1 for active low reset, =0 for active high
   DLL_FREQ_MODE        : string := "HIGH"  -- DCM Frequency range
   );
  port(
   ddr2_dq               : inout std_logic_vector((DQ_WIDTH-1) downto 0);
   ddr2_a                : out   std_logic_vector((ROW_WIDTH-1) downto 0);
   ddr2_ba               : out   std_logic_vector((BANK_WIDTH-1) downto 0);
   ddr2_ras_n            : out   std_logic;
   ddr2_cas_n            : out   std_logic;
   ddr2_we_n             : out   std_logic;
   ddr2_cs_n             : out   std_logic_vector((CS_WIDTH-1) downto 0);
   ddr2_odt              : out   std_logic_vector((ODT_WIDTH-1) downto 0);
   ddr2_cke              : out   std_logic_vector((CKE_WIDTH-1) downto 0);
   ddr2_dm               : out   std_logic_vector((DM_WIDTH-1) downto 0);
   --sys_clk_p             : in    std_logic;
   --sys_clk_n             : in    std_logic;
   --clk200_p              : in    std_logic;
   --clk200_n              : in    std_logic;
   -- MF, this modules recevies internal clocks
   sys_clk_i				: in std_logic;
   clk200_i				: in std_logic;
	dcmClkinLock	: in std_logic;   
   sys_rst_n             : in    std_logic;
   phy_init_done         : out   std_logic;
   rst0_tb               : out   std_logic;
   clk0_tb               : out   std_logic;
   app_wdf_afull         : out   std_logic;
   app_af_afull          : out   std_logic;
   rd_data_valid         : out   std_logic;
   app_wdf_wren          : in    std_logic;
   app_af_wren           : in    std_logic;
   app_af_addr           : in    std_logic_vector(30 downto 0);
   app_af_cmd            : in    std_logic_vector(2 downto 0);
   rd_data_fifo_out      : out   std_logic_vector((APPDATA_WIDTH-1) downto 0);
   app_wdf_data          : in    std_logic_vector((APPDATA_WIDTH-1) downto 0);
   app_wdf_mask_data     : in    std_logic_vector((APPDATA_WIDTH/8-1) downto 0);
   ddr2_dqs              : inout std_logic_vector((DQS_WIDTH-1) downto 0);
   ddr2_dqs_n            : inout std_logic_vector((DQS_WIDTH-1) downto 0);
   ddr2_ck               : out   std_logic_vector((CLK_WIDTH-1) downto 0);
   ddr2_ck_n             : out   std_logic_vector((CLK_WIDTH-1) downto 0)
   );

--  attribute X_CORE_inFO : string;
--  attribute X_CORE_inFO of mig20 : ENTITY IS
--    "mig_v2_00_ddr2_v5, Coregen 9.2i_ip2";
	end component;

	component dp_32_64
	port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(31 downto 0);
		addra: IN std_logic_VECTOR(5 downto 0);
		ena: IN std_logic;
		wea: IN std_logic_VECTOR(3 downto 0);
		douta: OUT std_logic_VECTOR(31 downto 0);
		clkb: IN std_logic;
		dinb: IN std_logic_VECTOR(63 downto 0);
		addrb: IN std_logic_VECTOR(4 downto 0);
		web: IN std_logic_VECTOR(7 downto 0);
		doutb: OUT std_logic_VECTOR(63 downto 0));
	end component dp_32_64;
	
	component emac_init is
	generic ( 	c_porCntBit : natural := 24; 
				c_lbtest : boolean := FALSE );
	 -- was 24
    port(
		clk							: in std_logic;
		lb_lresetn					: in std_logic;
		
		-- emac interface
		temac_rstni					: in std_logic;
		temac_rsto                  : out std_logic;

		-- Host Interface
		host_clk                    : out std_logic;
		host_opcode                 : out std_logic_vector(1 downto 0);
		host_req                    : out std_logic;
		host_miim_sel               : out std_logic;
		host_addr                   : out std_logic_vector(9 downto 0);
		host_wr_data                : out std_logic_vector(31 downto 0);
		host_miim_rdy               : in  std_logic;
		host_rd_data                : in  std_logic_vector(31 downto 0);
		host_emac1_sel              : out std_logic;
		
		-- Local Bus interface to host interface
		busi_opcode                 : in std_logic_vector(1 downto 0);
		busi_req                    : in std_logic;
		busi_miim_sel               : in std_logic;
		busi_addr                   : in std_logic_vector(9 downto 0);
		busi_wr_data                : in std_logic_vector(31 downto 0);
		buso_miim_rdy               : out std_logic;
		buso_rd_data                : out  std_logic_vector(31 downto 0);
		busi_emac1_sel              : in std_logic;			
		
		-- National Phy strapping
		phy_strap					: out std_logic;
		phy_resetn					: out std_logic;
		phy_ad1_rxd0_A				: out std_logic;
		phy_ad2_rxd1_A				: out std_logic;
		phy_ad3_rxd0_B				: out std_logic;
		phy_ad4_rxd1_B				: out std_logic;
		phya_pwrDown				: out std_logic;
		phyb_pwrDown				: out std_logic;
		
		done						: out std_logic
      );
	end component emac_init;	

	component eepromMaster is
	generic ( c_numReg : natural := 16 );
	port ( 
		rstn	: in std_logic;
		clk		: in std_logic;
		-- micro wire interface
		sk		: out std_logic;
		cs		: out std_logic;
		sd		: inout std_logic;
		--sdi		: out std_logic;
		--sdo		: in std_logic;
		--tri		: out std_logic;   
		-- host interface
		mwStart	: in std_logic;
		mwCmd	: in std_logic_vector(1 downto 0);
		mwAddr	: in std_logic_vector(7 downto 0);
		mwRdCnt : in std_logic_vector(3 downto 0);
		mwDo	: in std_logic_vector(15 downto 0);
		mwDone	: out std_logic;	 
		mwDi	: out std_logic_vector(15 downto 0);
	
		regQ : out std_logic_matrix_16(c_numReg-1 downto 0);
		stateOut : out std_logic_vector(31 downto 0)
	);
	end component eepromMaster;
	
	component serialSimple
	Port ( 
		rstn 		: in  std_logic; -- assume reset is asynch
		clk 		: in  std_logic;
		rx 			: in  std_logic;
		tx 			: out std_logic;
		renn		: out std_logic;
		ten 		: out std_logic;
		baudSet   	: in std_logic_vector(7 downto 0);
		tx_data		: in std_logic_vector(7 downto 0);
		rx_data		: out std_logic_vector(7 downto 0);
		ctrl		: in std_logic_vector(7 downto 0);
		status		: out std_logic_vector(7 downto 0)
	);
	end component serialSimple;
	
	
	component EXAMPLE_MGT_TOP is
	generic
	(
		EXAMPLE_CONFIG_INDEPENDENT_LANES        : integer   := 1;
		EXAMPLE_LANE_WITH_START_CHAR            : integer   := 0;
		EXAMPLE_WORDS_IN_BRAM                   : integer   := 512;
		EXAMPLE_SIM_GTPRESET_SPEEDUP            : integer   := 1;
		EXAMPLE_SIM_PLL_PERDIV2                 : bit_vector:= x"190";
		EXAMPLE_USE_CHIPSCOPE                   : integer   := 1     -- Set to 1 to use Chipscope to drive resets
	);
	port
	(
		TILE0_REFCLK_PAD_N_IN                   : in   std_logic;
		TILE0_REFCLK_PAD_P_IN                   : in   std_logic;
		GTPRESET_IN                             : in   std_logic;
		TILE0_PLLLKDET_OUT                      : out  std_logic;
		TILE1_PLLLKDET_OUT                      : out  std_logic;
		RXN_IN                                  : in   std_logic_vector(3 downto 0);
		RXP_IN                                  : in   std_logic_vector(3 downto 0);
		TXN_OUT                                 : out  std_logic_vector(3 downto 0);
		TXP_OUT                                 : out  std_logic_vector(3 downto 0);
		tile0ch0_loopback						: in  std_logic_vector(2 downto 0);
		tile0ch1_loopback						: in  std_logic_vector(2 downto 0);
		tile1ch0_loopback						: in  std_logic_vector(2 downto 0);
		tile1ch1_loopback						: in  std_logic_vector(2 downto 0);
		altClkIn								: in std_logic
	);
	end component EXAMPLE_MGT_TOP;	

	component gpioChipSync is
	generic(
		constant c_num_serdes : natural := 16;
		constant c_serdes_width : natural := 4
	);
	Port ( 
		clk50		: in STD_LOGIC;
		clk200		: in std_logic;
		lb_resetn	: in STD_LOGIC;	-- asynch
		dataRx_p	: in std_logic_vector(c_num_serdes-1 DOWNTO 0);
		dataRx_n	: in std_logic_vector(c_num_serdes-1 DOWNTO 0);
		dataTx_p	: out std_logic_vector(c_num_serdes-1 DOWNTO 0);
		dataTx_n	: out std_logic_vector(c_num_serdes-1 DOWNTO 0);
		clkRx_p		: in std_logic;
		clkRx_n		: in std_logic;
		clkTx_p		: out std_logic;
		clkTx_n		: out std_logic;
		errCnt		: out std_logic_vector(15 downto 0);
		ctrl		: in std_logic_vector(7 downto 0);
		result		: out std_logic_vector(31 downto 0);
		status		: out std_logic_vector(7 downto 0)
	);
	end component gpioChipSync;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- SIGNAL / CONSTANT DECLARATIONS
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	-- internal clock signals
	signal clk50 : std_logic;
	signal clk100 : std_logic;
	signal clk200 : std_logic;
	signal clk200Locked : std_logic;

	signal memClk_bufg : std_logic;
	signal memClk_ibufg : std_logic;
	signal memClk : std_logic;
	signal pllClk : std_logic;
	signal pllLocked : std_logic;
	
		
	-- PLX signals
	signal ld_out :  std_logic_vector(31 downto 0);
	
	signal dm_adsn :  std_logic;
	signal dm_blastn :  std_logic;
	signal dm_la :  std_logic_vector(31 downto 2);
	signal dm_lben :  std_logic_vector(3 downto 0);
	signal dm_ld_dir : std_logic;
	signal dm_lw_rn :  std_logic;
	
	signal ds_readyn :  std_logic;
	signal ds_ld_dir :	std_logic;
    --signal ds_lserrn : std_logic;
	
	-- PLX Arbitration
	signal dsAck : std_logic;
	signal dmReq : std_logic;
	signal dmAck : std_logic;
	signal dmBackoff : std_logic;	
	
	-- Direct master memory access
	constant c_dmtxfrCntWidth : natural := 6;
	
	signal dmTxfrCtrl		: std_logic_vector(1 downto 0);
	signal dmTxfrAddr		: std_logic_vector(31 downto 0);
	signal dmTxfrCnt		: std_logic_vector(c_dmtxfrCntWidth-1 downto 0);
	signal dmint			: std_logic;
	
	-- Direct slave address space 0
	-- address space sizing constants
	constant c_ds0En			: std_logic := '1';		
	constant c_ds0RegSel		: natural := 5; --32 addressable locations
	constant c_ds0RegDepth		: natural := 2**c_ds0RegSel;
	constant c_ds0RamSel		: natural := 6; --64 addressable locations
--	constant c_ds0RamDepth		: natural := 2**c_ds0RamSel;

--	constant c_ds0NumAddrBit 	: natural := 1 + maximum(c_ds0RamSel,c_ds0RegSel);
	constant c_ds0NumAddrBit 	: natural := 8;

--	constant c_ds0RegUnused 	: natural := c_ds0NumAddrBit-1-c_ds0RegSel;
--	constant c_ds0RamUnused 	: natural := c_ds0NumAddrBit-1-c_ds0RamSel;
	
	constant c_ds0ByteSz 		: natural := (2**c_ds0NumAddrBit)*4; -- 2^8*4=128*4=1024
	constant c_ds0BaseAddr 		: std_logic_vector(31 downto c_ds0NumAddrBit+2) := GND_BITS(31 downto c_ds0NumAddrBit+2);
	constant c_ds0BaseAddr28 	: std_logic_vector(31 downto 4) := c_ds0BaseAddr & GND_BITS(c_ds0NumAddrBit+1 downto 4);
	signal ds0BaseAddr : std_logic_vector(31 downto 0);
	
	signal ds0RegEn				: std_logic;
	--signal ds0RegWr				: std_logic_vector(3 downto 0 );
	--signal ds0RegSel			: std_logic_vector(c_ds0RegSel-1 downto 0 );
	signal ds0RegDout			: std_logic_vector(31 downto 0);
	signal ds0RegLocalWr		: std_logic_matrix_04(c_ds0RegDepth-1 downto 0);	
	signal ds0RegLocalin		: std_logic_matrix_32(c_ds0RegDepth-1 downto 0);
	signal ds0RegLocalOut		: std_logic_matrix_32(c_ds0RegDepth-1 downto 0);	
	signal ds0RamEn				: std_logic;
	--signal ds0RamWr				: std_logic_vector(3 downto 0 );
	--signal ds0RamAddr			: std_logic_vector((c_ds0RamSel-1) downto 0 );
	signal ds0WrByte			: std_logic_vector(3 downto 0);
	signal ds0AddrValid			: std_logic;
	
	signal ds0RamAccess			: std_logic;
	
	signal dmRamEn				: std_logic;
	signal dmRamWr				: std_logic_vector( 3 downto 0 );
	signal dmRamAddr			: std_logic_vector((c_ds0RamSel-1) downto 0 );

	-- Direct slave address space 1
	signal ds1AddrValid			: std_logic;
	constant c_ds1En			: std_logic := '1';	
	constant c_ds1RegSel		: natural := 3;
	constant c_ds1RegDepth		: natural := 2**c_ds1RegSel;
	constant c_ds1RamSel		: natural := 6;
	constant c_ds1RamDepth		: natural := 2**c_ds1RamSel; -- 64
	
	constant c_ds1NumAddrBit	: natural := 1+ maximum(c_ds1RamSel,c_ds1RegSel);
	constant c_ds1RegUnused 	: natural := c_ds1NumAddrBit-1-c_ds1RegSel;
	constant c_ds1RamUnused 	: natural := c_ds1NumAddrBit-1-c_ds1RamSel;	
	
	constant c_ds1ByteSz 		: natural := (2**c_ds1NumAddrBit)*4;	
	constant c_ds1BaseAddr 		: std_logic_vector(31 downto c_ds1NumAddrBit+2) := '1' & GND_BITS(30 downto c_ds1NumAddrBit+2);
	constant c_ds1BaseAddr28 	: std_logic_vector(31 downto 4) := c_ds1BaseAddr & GND_BITS(c_ds1NumAddrBit+1 downto 4);

	signal ds1RegEn				: std_logic;
	signal ds1RegWr				: std_logic_vector(3 downto 0);
	signal ds1RegSel			: std_logic_vector((c_ds1RegSel-1) downto 0);
	signal ds1RegDout			: std_logic_vector(31 downto 0);
	signal ds1RegLocalWr		: std_logic_matrix_04((c_ds1RegDepth-1) downto 0);	
	signal ds1RegLocalin		: std_logic_matrix_32((c_ds1RegDepth-1) downto 0);
	signal ds1RegLocalOut		: std_logic_matrix_32((c_ds1RegDepth-1) downto 0);	
	
	signal ds1RamEn				: std_logic;
	signal ds1RamWr				: std_logic_vector(3 downto 0 );
	signal ds1RamAddr			: std_logic_vector((c_ds1RamSel-1) downto 0 );
	signal ds1WrByte			: std_logic_vector(3 downto 0);
	signal ds1RamDout			: std_logic_vector(31 downto 0);
		
	
	-- Shared RAM buffer, Direct Slave space 0 and Direct master
	--signal RamDout			: std_logic_vector(31 downto 0);
	--signal RamEn			: std_logic;
	--signal RamWr			: std_logic_vector( 3 downto 0 );
	--signal RamAddr			: std_logic_vector( 3 downto 0 );
	
	signal allClkStable 	: std_logic;

	-- Configuration
	constant c_cfgRomSize	: integer := 20 ;  --note harded coded config rom is in cfgromcomponent
	
	signal cfgComplete 		: std_logic;
	signal cfgRomAddr		: unsigned(4 downto 0);
	signal cfgRomDout		: std_logic_vector(47 downto 0);
	
	signal reprogram		: std_logic;

	-- interrupts
	signal intSrc			: std_logic_vector(31 downto 0);
	signal intGen			: std_logic_vector(31 downto 0);	
	signal intMask			: std_logic_vector(31 downto 0);		

	-- SPI dual port ram
	signal dpDinB			: std_logic_VECTOR(7 downto 0);
	signal dpAddrB			: std_logic_VECTOR(7 downto 0);
	signal dpWrB			: std_logic;
	signal dpDoutB			: std_logic_VECTOR(7 downto 0);
	
	-- 
	signal lb_ccsn_x : std_logic;
	signal lb_clkfb_x : std_logic;
	
	signal spia_clk :  std_logic;
	signal spia_miso :  std_logic;
	
	signal spiSck 			:  std_logic;
	signal spiSdo 			:  std_logic;
	signal spiSdi 			:  std_logic;
	signal spiCsn 			:  std_logic;
	signal spiMuxSel		:  std_logic;	
		
	signal spiint : std_logic;

	signal lb_rst : std_logic;
	
	-- Single ended GPio
	signal gpio_p_o			: std_logic_vector(31 downto 0);
	signal gpio_p_t			: std_logic_vector(31 downto 0);
	signal gpio_p_i			: std_logic_vector(31 downto 0);
	signal gpio_n_o			: std_logic_vector(31 downto 0);
	signal gpio_n_t			: std_logic_vector(31 downto 0);
	signal gpio_n_i			: std_logic_vector(31 downto 0);

	signal gpio_o			: std_logic_vector(15 downto 0);
	--signal gpio_t			: std_logic_vector(31 downto 0);
	signal gpio_i			: std_logic_vector(15 downto 0);
	
--	signal dmStateOut 		: std_logic_vector(6 downto 0);
	
	
	-- Revision
	constant rev			: std_logic_vector(31 downto 0) := c_bldType & c_revMajor & c_revMinor & c_revBuild;
	
	attribute iob : string;
	attribute iob of gpio_p : signal is "FALSE";
	attribute iob of gpio_n :  signal is "FALSE";
--	attribute iob of gpio_p_o : signal is "FALSE";
--	attribute iob of gpio_n_o :  signal is "FALSE";
--	attribute iob of gpio_p_t : signal is "FALSE";
--	attribute iob of gpio_n_t :  signal is "FALSE";
	
	signal memClkPad : std_logic;
	
	-- MIG backend signalling
	constant TCYC_PLX 			: time := 20 ns;
	constant DP_A_WIDTH			: integer := 6;
	constant MAX_BURST			: integer := 16;
	constant BURST_SZ_WIDTH		: integer := 4; 
	
	signal clk0_tb            	: std_logic;
	signal rst0_tb            	: std_logic;
	signal app_af_afull       	: std_logic;
	signal app_wdf_afull      	: std_logic;
	signal rd_data_valid      	: std_logic;
	signal rd_data_fifo_out   	: std_logic_vector(64-1 downto 0);
	signal app_af_wren        	: std_logic;
	signal app_af_cmd         	: std_logic_vector(2 downto 0);
	signal app_af_addr        	: std_logic_vector(30 downto 0);
	signal app_wdf_wren       	: std_logic;
	signal app_wdf_data       	: std_logic_vector(64-1 downto 0);
	signal app_wdf_mask_data	: std_logic_vector((64/8)-1 downto 0);
	signal phy_init_done 		: std_logic;
		
	signal txfrCtrlA			: std_logic_vector(1 downto 0);
	signal txfrCmdA				: std_logic_vector(2 downto 0);
	signal txfrSzA				: std_logic_vector(BURST_SZ_WIDTH-1 downto 0);
	signal txfrAddrA			: std_logic_vector(30 downto 0);
	signal txfrStatusA			: std_logic_vector(3 downto 0);
	
	signal dpEnA				: std_logic;
	signal dpWenA				: std_logic_vector(3 downto 0);
	signal dpAddrA				: std_logic_vector(DP_A_WIDTH-1 downto 0);
--	signal dpDinA				: std_logic_vector(31 downto 0);
	signal dpDoutA				: std_logic_vector(31 downto 0);
	
	-- DDR2 
--	signal dqs_i : std_logic_vector (3 downto 0);
--	signal dqs_o : std_logic_vector (3 downto 0);	
	
	
--	function f_DQ_IO_MS(sel : character) return bit_vector is
--		--variable v : bit_vector(31 downto 0);
--	begin
--		case(sel) is
--			when 'B' 	=> return("11101000001001101011001010100110");
--			when 'C' 	=> return("11001100100101011011001000100011");
--			when others => return("00000000000000000000000000000000");
--			
--	  --DQ_IO_MS => "11101000001001101011001010100110" -- rev b
--	  --DQ_IO_MS => "11001100100101011011001000100011" -- rev c			
--		end case;
--		
--		--return(v);
--	end function;
--	
--	constant c_DQ_IO_MS : bit_vector := f_DQ_IO_MS(c_pcbrev);
		
	-- EMAC backend signalling
	signal emac_reset : std_logic;
    signal emaca_tx_ifg_delay       : std_logic_vector(7 downto 0)  := (others => '0');
    signal emaca_pause_val          : std_logic_vector(15 downto 0) := (others => '0');
    signal emaca_pause_req          : std_logic;  
    signal emacb_tx_ifg_delay       : std_logic_vector(7 downto 0)  := (others => '0');
    signal emacb_pause_val          : std_logic_vector(15 downto 0) := (others => '0');
    signal emacb_pause_req          : std_logic;  

	signal host_clk : std_logic;
    signal host_opcode          : std_logic_vector(1 downto 0)  := (others => '1');
    signal host_addr            : std_logic_vector(9 downto 0)  := (others => '1');
    signal host_wr_data         : std_logic_vector(31 downto 0) := (others => '0');
    signal host_rd_data         : std_logic_vector(31 downto 0);
    signal host_miim_sel        : std_logic                     := '0';
    signal host_req             : std_logic                     := '0';
    signal host_miim_rdy        : std_logic;
    signal host_emac1_sel       : std_logic                     := '0';
	
	signal mii_mdio_i            : std_logic;
    signal mii_mdio_o           : std_logic;
    signal mii_mdio_t           : std_logic;
	
	signal	phy_strap					:  std_logic;
	signal	phy_resetn					:  std_logic;
	signal	phy_ad1_rxd0_A				:  std_logic;
	signal	phy_ad2_rxd1_A				:  std_logic;
	signal	phy_ad3_rxd0_B				:  std_logic;
	signal	phy_ad4_rxd1_B				:  std_logic;	
	
	signal TemacPhy_RST_n :  std_logic;
	
	-- microwire master interface
	signal mwStart	:  std_logic;
	signal mwCmd	:  std_logic_vector(1 downto 0);
	signal mwAddr	:  std_logic_vector(7 downto 0);
	signal mwRdCnt :  std_logic_vector(3 downto 0);
	signal mwDo	:  std_logic_vector(15 downto 0);
	signal mwDone	:  std_logic;	 
	signal mwDi	:  std_logic_vector(15 downto 0);
	signal eepromData : std_logic_matrix_16(15 downto 0);

--	signal mwStartx	:  std_logic;
--	signal mwCmdx	:  std_logic_vector(1 downto 0);
--	signal mwAddrx	:  std_logic_vector(7 downto 0);
--	signal mwRdCntx :  std_logic_vector(3 downto 0);
--	signal mwDox	:  std_logic_vector(15 downto 0);
	
	-- simple serial interface
	signal rs0_baudSet  :  std_logic_vector(7 downto 0);
	signal rs0_txData	:  std_logic_vector(7 downto 0);
	signal rs0_rxData	:  std_logic_vector(7 downto 0);
	signal rs0_ctrl		:  std_logic_vector(7 downto 0);
	signal rs0_status	:  std_logic_vector(7 downto 0);	
	
	signal rs1_baudSet  :  std_logic_vector(7 downto 0);
	signal rs1_txData	:  std_logic_vector(7 downto 0);
	signal rs1_rxData	:  std_logic_vector(7 downto 0);
	signal rs1_ctrl		:  std_logic_vector(7 downto 0);
	signal rs1_status	:  std_logic_vector(7 downto 0);	
	
--	signal mwStateOut :  std_logic_vector(31 downto 0);	
	
	-- Local Bus interface to emace host interface
	signal busi_opcode                 : std_logic_vector(1 downto 0);
	signal busi_req                    : std_logic;
	signal busi_miim_sel               : std_logic;
	signal busi_addr                   : std_logic_vector(9 downto 0);
	signal busi_wr_data                : std_logic_vector(31 downto 0);
	signal buso_miim_rdy               : std_logic;
	signal buso_rd_data                : std_logic_vector(31 downto 0);
	signal busi_emac1_sel              : std_logic;		
	
	signal emacInitDone              : std_logic;		
	
	--------------
	-- EMAC stuff
	--------------
	
    -- Global asynchronous reset
    --signal reset_i               : std_logic;

    -- client interface clocking signals - EMAC0
--    signal ll_clk_0_i            : std_logic;

    -- address swap transmitter connections - EMAC0
    signal tx_ll_data_0_i      : std_logic_vector(7 downto 0);
    signal tx_ll_sof_n_0_i     : std_logic;
    signal tx_ll_eof_n_0_i     : std_logic;
    signal tx_ll_src_rdy_n_0_i : std_logic;
    signal tx_ll_dst_rdy_n_0_i : std_logic;

   -- address swap receiver connections - EMAC0
    signal rx_ll_data_0_i           : std_logic_vector(7 downto 0);
    signal rx_ll_sof_n_0_i          : std_logic;
    signal rx_ll_eof_n_0_i          : std_logic;
    signal rx_ll_src_rdy_n_0_i      : std_logic;
    signal rx_ll_dst_rdy_n_0_i      : std_logic;

    -- create a synchronous reset in the transmitter clock domain
    signal ll_pre_reset_0_i          : std_logic_vector(5 downto 0);
    signal ll_reset_0_i              : std_logic;

    attribute async_reg : string;
    attribute async_reg of ll_pre_reset_0_i : signal is "true";


    -- client interface clocking signals - EMAC1
--    signal ll_clk_1_i            : std_logic;

    -- address swap transmitter connections - EMAC1
    signal tx_ll_data_1_i      : std_logic_vector(7 downto 0);
    signal tx_ll_sof_n_1_i     : std_logic;
    signal tx_ll_eof_n_1_i     : std_logic;
    signal tx_ll_src_rdy_n_1_i : std_logic;
    signal tx_ll_dst_rdy_n_1_i : std_logic;

    -- address swap receiver connections - EMAC1
    signal rx_ll_data_1_i           : std_logic_vector(7 downto 0);
    signal rx_ll_sof_n_1_i          : std_logic;
    signal rx_ll_eof_n_1_i          : std_logic;
    signal rx_ll_src_rdy_n_1_i      : std_logic;
    signal rx_ll_dst_rdy_n_1_i      : std_logic;

    -- create a synchronous reset in the transmitter clock domain
    signal ll_pre_reset_1_i          : std_logic_vector(5 downto 0);
    signal ll_reset_1_i              : std_logic;


    attribute async_reg of ll_pre_reset_1_i : signal is "true";

    -- HOSTCLK input to MAC
    signal host_clk_i                : std_logic;

    -- EMAC0 Clocking signals

    -- MII input clocks from PHY
    signal tx_phy_clk_0              : std_logic;
    signal rx_clk_0_i                : std_logic;
    -- Client clocks at 1.25/12.5MHz
    signal tx_client_clk_0           : std_logic;
    signal rx_client_clk_0           : std_logic;
    signal tx_client_clk_0_o         : std_logic;
    signal rx_client_clk_0_o         : std_logic;

    -- EMAC1 Clocking signals

    signal tx_phy_clk_1              : std_logic;
    signal rx_clk_1_i                : std_logic;
    signal tx_client_clk_1           : std_logic;
    signal rx_client_clk_1           : std_logic;
    signal tx_client_clk_1_o         : std_logic;
    signal rx_client_clk_1_o         : std_logic;

    --attribute buffer_type : string;
    --attribute buffer_type of host_clk_i  : signal is "none";

	signal emac0Tx_lb_do	: std_logic_vector(31 downto 0);	
	signal emac0Tx_lb_en	: std_logic;	
	signal emac0Tx_pktSend	: std_logic;
	signal emac0Tx_pktSz	: std_logic_vector(5 downto 0);  --> 1 based
	signal emac0Tx_pktDone	: std_logic;
	
	signal emac0Rx_lb_do	: std_logic_vector(31 downto 0);	
	signal emac0Rx_lb_en	: std_logic;		
	signal emac0Rx_pktProcd : std_logic;
	signal emac0Rx_pktSz 	: std_logic_vector(5 downto 0);  --> 1 based
	signal emac0Rx_pktDone	: std_logic;	
	
	signal emac1Tx_lb_do	: std_logic_vector(31 downto 0);	
	signal emac1Tx_lb_en	: std_logic;	
	signal emac1Tx_pktSend	: std_logic;
	signal emac1Tx_pktSz	: std_logic_vector(5 downto 0);  --> 1 based
	signal emac1Tx_pktDone	: std_logic;
	
	signal emac1Rx_lb_do	: std_logic_vector(31 downto 0);	
	signal emac1Rx_lb_en	: std_logic;		
	signal emac1Rx_pktProcd : std_logic;
	signal emac1Rx_pktSz 	: std_logic_vector(5 downto 0);  --> 1 based
	signal emac1Rx_pktDone	: std_logic;	
	
	------
	-- gtp stuff
	------
--	signal gtp_rst				: std_logic;
	signal gtp_rx_rst 			: std_logic;
	signal gtp_tx_rst 			: std_logic;          
	signal gtp_tile0_pll_ok 	: std_logic;
	signal gtp_tile1_pll_ok 	: std_logic;


	signal rstn 				: std_logic;
--	signal ddr2_writing 		: std_logic;
		
--	signal spiaStatusRegWr 		: std_logic;
--	signal spiaCmdReg 			: std_logic_Vector(7 downto 0);
--	signal spiaStatusReg 		: std_logic_Vector(7 downto 0);
--	
--	signal spibStatusRegWr 		: std_logic;
--	signal spibCmdReg 			: std_logic_Vector(7 downto 0);
--	signal spibStatusReg 		: std_logic_Vector(7 downto 0);	
	
	signal emac_ram_en 			: std_logic;
	signal gtp_ram_en 			: std_logic;
	signal gtp_do				: std_logic_vector(31 downto 0);
		
	signal gtp_tx_start			: std_logic_vector(3 downto 0);
	signal gtp_tx_done			: std_logic_vector(3 downto 0);
	signal gtp_tx_sz			: std_logic_matrix_08(3 downto 0);
	
	signal gtp_rx_done			: std_logic_vector(3 downto 0);
	signal gtp_rx_sz			: std_logic_matrix_08(3 downto 0);
	signal gtp_rx_ok			: std_logic_vector(3 downto 0);
	signal gtp_rx_err_cnt		: std_logic_vector(31 downto 0);
	
	signal gtp_loopback			: std_logic_matrix_03(3 downto 0); -- := (others => '0');
	
	signal hss_user_io_i		: std_logic_vector(3 downto 0);
	signal hss_user_io_o		: std_logic_vector(3 downto 0);
	signal hss_user_io_t		: std_logic_vector(3 downto 0);
	
begin ----------------------------------------------------------------------------

	rstn <= lb_lresetn;
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Local bus slave control
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	u_plx32BitSlave: plx32BitSlave 
	port map(
		lresetn		=> rstn,
		lclk	=> clk50,
		ld_dir	=> ds_ld_dir,
		lben	=> lb_lben,
		adsn	=> lb_adsn,
		blastn	=> lb_blastn,
		readyn	=> ds_readyn,
		lw_rn	=> lb_lw_rn,
		--lserrn => ds_lserrn,
		plxAck	=> dsAck,
		addrValid0 => ds0AddrValid,
		wrByte0 => ds0WrByte,
		ramAccess0	=> ds0RamAccess,
		addrValid1 => ds1AddrValid,
		wrByte1 => ds1WrByte,
		ramAccess1 => ds1RamEn,		
		burst4 => '1'
	);

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Local bus space 0
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- c_ds0NumAddrBit = 8, then 8-1+2 is 9 the highest address bit

--	decode											pattern										loc
	gtp_ram_en 		<= '1' when lb_la(9) 			= '1'		else '0';	-- 8 to 2, 2^7 = 	128 
	ds0RamEn		<= '1' when lb_la(9 downto 8) 	= "01" 		else '0';	-- 7 to 2, 2^6 = 	64  
	emac_ram_en		<= '1' when lb_la(9 downto 7) 	= "001" 	else '0';	-- 6 to 2, 2^5 = 	32
	emac0Tx_lb_en	<= '1' when lb_la(9 downto 5) 	= "00100" 	else '0';	-- 4 to 2, 2^3 = 	8 
	emac0Rx_lb_en	<= '1' when lb_la(9 downto 5) 	= "00101"  	else '0';	-- 4 to 2, 2^3 = 	8
	emac1Tx_lb_en	<= '1' when lb_la(9 downto 5) 	= "00110"  	else '0';	-- 4 to 2, 2^3 = 	8
	emac1Rx_lb_en	<= '1' when lb_la(9 downto 5) 	= "00111"  	else '0';	-- 4 to 2, 2^3 = 	8
	ds0RegEn		<= '1' when lb_la(9 downto 7) 	= "000" 	else '0';	-- 6 to 2, 2^5 = 	32
																								---
--																								256																								
	
	ds0RamAccess <= (not ds0RegEn);
	ds0AddrValid <= '1' when lb_la(31 downto 10) = ds0BaseAddr(31 downto 10) else '0';	
		
    dpEnA	<= dmRamEn	 when dmAck = '1' else ds0RamEn;
    dpAddrA	<= dmRamAddr when dmAck = '1' else lb_la(7 downto 2);
    dpWenA	<= dmRamWr	 when dmAck = '1' else ds0WrByte;
                
	-- Register bank
	u_ds0Reg: regBank_32 
	generic map (
		selWidth => c_ds0RegSel,
		busReadOnly => x"FFFFFFFF" & 
						"1011001010101000" &
						"1000001001001010" )
	port map(
		clk => clk50,
		rstn => rstn,
		busEn => ds0RegEn,
		busSel => lb_la((c_ds0RegSel-1+2) downto 2),
		busWr => ds0WrByte,
		busin => lb_ld,
		busOut => ds0RegDout,
		localWr => ds0RegLocalWr,
		localin => ds0RegLocalin,
		localOut => ds0RegLocalOut
	);
	
	-- Reg	PLX		Contents
	-- 0	rw		interrupt mask
					intMask	<= ds0RegLocalOut(0);
	-- 1	r		interrupt source
					ds0RegLocalin(1) <= intSrc;
					ds0RegLocalWr(1) <= "1111";
	-- 2	rw		emac in
					emac1Rx_pktProcd <= ds0RegLocalOut(2)(31);
					emac1Tx_pktSend	 <= ds0RegLocalOut(2)(23);
					emac1Tx_pktSz	 <= ds0RegLocalOut(2)(21 downto 16);
					
					emac0Rx_pktProcd <= ds0RegLocalOut(2)(15);
					emac0Tx_pktSend	 <= ds0RegLocalOut(2)(7);
					emac0Tx_pktSz	 <= ds0RegLocalOut(2)(5 downto 0);
	-- 3	r		emac out		
					ds0RegLocalIn(3)(31)			<= emac1Rx_pktDone;
					ds0RegLocalIn(3)(29 downto 24)	<= emac1Rx_pktSz;
					ds0RegLocalIn(3)(23)			<= emac1Tx_pktDone;	
					
					ds0RegLocalIn(3)(15)			<= emac0Rx_pktDone;
					ds0RegLocalIn(3)(13 downto 8)	<= emac0Rx_pktSz;
					ds0RegLocalIn(3)(7)				<= emac0Tx_pktDone;
					
					ds0RegLocalWr(3) <= "1111";
	
	-- 4	rw		GPIO_p output
					gpio_p_o	<= ds0RegLocalOut(4);
	-- 5	rw		GPIO_p direction
					gpio_p_t	<= ds0RegLocalOut(5);
	-- 6	r		GPIO_P input
					ds0RegLocalin(6) <= gpio_p_i;
					ds0RegLocalWr(6) <= "1111";
	-- 7	rw		GPIO_n output
					gpio_n_o	<= ds0RegLocalOut(7);
	-- 8	rw		GPIO_n direction 	
					gpio_n_t	<= ds0RegLocalOut(8);
	-- 9	r		GPIO_n input 
					ds0RegLocalin(9) <= gpio_n_i;
					ds0RegLocalWr(9) <= "1111";
					
	-- 10	rw		GTP counts
					gtp_tx_sz(3) <= ds0RegLocalOut(10)(31 downto 24);
					gtp_tx_sz(2) <= ds0RegLocalOut(10)(23 downto 16);
					gtp_tx_sz(1) <= ds0RegLocalOut(10)(15 downto 8);			
					gtp_tx_sz(0) <= ds0RegLocalOut(10)(7  downto 0);
					
						
	-- 11	rw		user led
					user_led	<= ds0RegLocalOut(11)(3 downto 0);		
	-- 12	rw		Direct master transfer control
					dmTxfrCtrl		<= ds0RegLocalOut(12)(1 downto 0);	
	-- 13	rw		Direct master transfer address
					dmTxfrAddr		<= ds0RegLocalOut(13);	
	-- 14	rw		Direct master transfer count
					dmTxfrCnt		<= ds0RegLocalOut(14)(c_dmtxfrCntWidth-1 downto 0);	
	-- 15	r		Revision
					ds0RegLocalin(15) <= rev;
					ds0RegLocalWr(15) <= "1111";	
	-- 16	rw	
					txfrCtrlA <= ds0RegLocalOut(16)(1 downto 0);
	-- 17	rw						
					txfrCmdA <= ds0RegLocalOut(17)(2 downto 0);
					txfrSzA <= ds0RegLocalOut(17)(BURST_SZ_WIDTH-1+16 downto 16);
	-- 18	rw						
					txfrAddrA <= ds0RegLocalOut(18)(30 downto 0);
	-- 19	r
					ds0RegLocalin(19)(3 downto 0) <= txfrStatusA;
					ds0RegLocalin(19)(4) <= clk200Locked;
					ds0RegLocalin(19)(5) <= allClkStable;
					ds0RegLocalin(19)(31 downto 6) <= (others => '0');
					ds0RegLocalWr(19) <= "1111";		
	-- 20	rw
					mwStart <=  ds0RegLocalOut(20)(0);
					mwCmd	<=  ds0RegLocalOut(20)(2 downto 1);
					mwRdCnt <=  ds0RegLocalOut(20)(7 downto 4);
					mwAddr	<=  ds0RegLocalOut(20)(15 downto 8);
					mwDo	<=  ds0RegLocalOut(20)(31 downto 16);
	--21	r
					ds0RegLocalin(21)(0) <= mwDone;
					ds0RegLocalin(21)(15 downto 1) <= (others => '0');
					ds0RegLocalin(21)(31 downto 16) <= mwDi;
					ds0RegLocalWr(21) <= "1111";	
	-- 22	rw		-- serial baud rate, ctrl, and tx data
					rs0_baudSet	<= ds0RegLocalOut(22)(31 downto 24);
					rs0_ctrl	<= ds0RegLocalOut(22)(23 downto 16);
					--rs0		<= ds0RegLocalOut(22)(15 downto 8);
					rs0_txData	<= ds0RegLocalOut(22)(7 downto 0);
	-- 23	r		-- Serial status, rx data
					ds0RegLocalin(23)(31 downto 24) <= (others => '0');
					ds0RegLocalin(23)(23 downto 16) <= rs0_status;
					ds0RegLocalin(23)(15 downto 8) <= (others => '0');
					ds0RegLocalin(23)(7 downto 0) <= rs0_rxData;
					ds0RegLocalWr(23) <= "1111";	
	-- 24	rw		-- serial baud rate, ctrl, and tx data
					rs1_baudSet	<= ds0RegLocalOut(24)(31 downto 24);
					rs1_ctrl	<= ds0RegLocalOut(24)(23 downto 16);
					--rs1		<= ds0RegLocalOut(24)(15 downto 8);
					rs1_txData	<= ds0RegLocalOut(24)(7 downto 0);
	-- 25	r		-- Serial status, rx data
					ds0RegLocalin(25)(31 downto 24) <= (others => '0');
					ds0RegLocalin(25)(23 downto 16) <= rs1_status;
					ds0RegLocalin(25)(15 downto 8) <= (others => '0');
					ds0RegLocalin(25)(7 downto 0) <= rs1_rxData;
					ds0RegLocalWr(25) <= "1111";
	-- 26	rw		-- EMAC host control
					--				<= ds0RegLocalOut(26)(31 downto 25);
					busi_req		<= ds0RegLocalOut(26)(24);					
					--				<= ds0RegLocalOut(26)(23 downto 20);
					busi_miim_sel	<= ds0RegLocalOut(26)(19);	
					busi_emac1_sel	<= ds0RegLocalOut(26)(18);	
					busi_opcode		<= ds0RegLocalOut(26)(17 downto 16);	
					--				<= ds0RegLocalOut(26)(15 downto 10)
					busi_addr		<= ds0RegLocalOut(26)(9 downto 0);	
	-- 27	rw		-- EMAC host wr data
					busi_wr_data	<= ds0RegLocalOut(27);	
	-- 28	r		-- EMAC host status												
					ds0RegLocalin(28)(31 downto 2) <= (others=>'0');
					ds0RegLocalin(28)(1) <= emacInitDone;
					ds0RegLocalin(28)(0) <= buso_miim_rdy;
					ds0RegLocalWr(28) <= "0001";
	-- 29	r		-- EMAC host rd data
					ds0RegLocalin(29) <= buso_rd_data;
					ds0RegLocalWr(29) <= "1111";
	-- 30	rw		GTP Control

					gtp_rx_ok(3)	<= ds0RegLocalOut(30)(28);
					gtp_tx_start(3) <= ds0RegLocalOut(30)(27);
					gtp_loopback(3) <= ds0RegLocalOut(30)(26 downto 24);
	
					gtp_rx_ok(2)	<= ds0RegLocalOut(30)(20);
					gtp_tx_start(2) <= ds0RegLocalOut(30)(19);
					gtp_loopback(2) <= ds0RegLocalOut(30)(18 downto 16);
					
					gtp_rx_ok(1)	<= ds0RegLocalOut(30)(12);
					gtp_tx_start(1) <= ds0RegLocalOut(30)(11);
					gtp_loopback(1) <= ds0RegLocalOut(30)(10 downto 8);				
					
					gtp_rx_ok(0)	<= ds0RegLocalOut(30)(4);
					gtp_tx_start(0) <= ds0RegLocalOut(30)(3);
					gtp_loopback(0) <= ds0RegLocalOut(30)(2 downto 0);
					
					gtp_rx_rst <= ds0RegLocalOut(30)(30);
					gtp_tx_rst <= ds0RegLocalOut(30)(31);

		
	-- 31	r		GTP Status
					ds0RegLocalin(31)(31 downto 27) <= gtp_rx_sz(3)(4 downto 0);
					ds0RegLocalin(31)(26) <= gtp_rx_done(3);
					ds0RegLocalin(31)(25) <= gtp_tx_done(3);
					ds0RegLocalin(31)(24) <= gtp_tile1_pll_ok;
					
					ds0RegLocalin(31)(23 downto 19) <= gtp_rx_sz(2)(4 downto 0);
					ds0RegLocalin(31)(18) <= gtp_rx_done(2);
					ds0RegLocalin(31)(17) <= gtp_tx_done(2);
					ds0RegLocalin(31)(16) <= gtp_tile1_pll_ok;
					
					ds0RegLocalin(31)(15 downto 11) <= gtp_rx_sz(1)(4 downto 0);
					ds0RegLocalin(31)(10) <= gtp_rx_done(1);
					ds0RegLocalin(31)(9) <= gtp_tx_done(1);
					ds0RegLocalin(31)(8) <= gtp_tile0_pll_ok;
					
					ds0RegLocalin(31)(7 downto 3) <= gtp_rx_sz(0)(4 downto 0);
					ds0RegLocalin(31)(2) <= gtp_rx_done(0);
					ds0RegLocalin(31)(1) <= gtp_tx_done(0);
					ds0RegLocalin(31)(0) <= gtp_tile0_pll_ok;	

					ds0RegLocalWr(31) <= "1111";
					
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Local bus space 1
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	-- expecting a 128 dword space 10 0000 00[00]
	
	ds1RegSel <= lb_la((c_ds1RegSel-1+2) downto 2);
	ds1RegWr <= ds1WrByte;
	--ds1RegEn <= '1' when lb_la((c_ds1NumAddrBit-1+2) downto (c_ds1RegSel+2)) = c_ds1RegEnMask else '0';
	g_ds1regEnY : if c_ds1RegUnused = 0 generate
		ds1regEn <= not lb_la(c_ds1NumAddrBit-1+2);
	end generate;

	g_ds1regEnN : if c_ds1RegUnused > 0 generate
		ds1RegEn <= '1' when  lb_la(c_ds1NumAddrBit-1+2) = '0' and
							  (lb_la((c_ds1NumAddrBit-1+3) downto (c_ds1RegSel+2)) = 
							   GND_BITS((c_ds1NumAddrBit-1+3) downto (c_ds1RegSel+2))) else '0';
	end generate;

	ds1RamAddr <= lb_la((c_ds1RamSel-1+2)downto 2);
	ds1RamWr <= ds1WrByte;
	ds1RamEn <= lb_la(c_ds1NumAddrBit-1+2); -- 8
	
	ds1AddrValid <= '1' when lb_la(31 downto (c_ds1NumAddrBit+2)) = c_ds1BaseAddr else '0';
	
	-- Register bank
	u_ds1Reg: regBank_32 
	generic map (selWidth => c_ds1RegSel,
				 busReadOnly => x"FFFFFFFFFFFFFF" & "10001100" ) 
	port map(
		clk => clk50,
		rstn => rstn,
		busEn => ds1RegEn,
		busSel => ds1RegSel,
		busWr => ds1RegWr,
		busin => lb_ld,
		busOut => ds1RegDout,
		localWr => ds1RegLocalWr,
		localin => ds1RegLocalin,
		localOut => ds1RegLocalOut
	);	
	
	-- Reg	PLX		Contents
	-- 0	rw		SPI command
	-- 1	rw		SPI parameters
	-- 2	r		SPI status
	-- 3	r		SPI result
	-- 4	rw		SPI select
	-- 5	rw		DS0 base address
	-- 6	rw		HSS User io output and dir
	-- 7	r		HSS User io input
	

	spiMuxSel <= ds1RegLocalOut(4)(0);
	ds0BaseAddr <= ds1RegLocalOut(5);	
	hss_user_io_o	<= ds1RegLocalOut(6)(3 downto 0);					
	hss_user_io_t	<= ds1RegLocalOut(6)(11 downto 8);	
	ds1RegLocalIn(7) <= x"0000000" & hss_user_io_i;
	ds1RegLocalWr(7) <= (others => '1');	
					



	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- local bus arbiter
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	u_plxArb: plxArb 
	port map(
		lresetn => rstn,
		lclk => clk50,
		dsReq => lb_lhold,
		dsAck => dsAck,
		dsReqForce => lb_breqo,
		dmReq => dmReq,
		dmAck => dmAck,
		dmBackoff => dmBackoff,
		allClkStable => allClkStable
	);
		
	lb_lholda <= dsAck;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- local bus master
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	u_plx32BitMaster: plx32BitMaster 
	generic map (  
		c_cfgRomSize => c_cfgRomSize,
		c_ramWidth => c_ds0RamSel,
		c_txfrCntWidth => c_dmtxfrCntWidth,
		c_enPlxCfg => c_enPlxCfg
	)
	port map(
		lclk => clk50,
		la => dm_la,
		ld_dir => dm_ld_dir,
		lben => dm_lben,
		adsn => dm_adsn,
		blastn => dm_blastn,
		readyn => lb_readyn,
		lw_rn => dm_lw_rn,
		lresetn => rstn,
		ccsn => lb_ccsn_x,
		dmpaf => lb_eotn,
		req => dmReq,
		ack => dmAck,
		backoff => dmBackoff,		
		txfrCtrl	=> dmTxfrCtrl,
		txfrAddr	=> dmTxfrAddr,
		txfrCnt	=> dmTxfrCnt,
		int		=> dmint,
		cfgComplete	=> cfgComplete,
		ramAddr => dmramAddr,
		ramWr => dmramWr,
		ramEn => dmramEn,
		cfgRomPtr => cfgRomAddr,
        cfgRomDout => cfgRomDout,
		stateOut => open
	);
	
	lb_ccsn <= lb_ccsn_x;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- local bus configuration rom
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
g_enPlxCfgY : if c_enPlxCfg = TRUE generate
    u_CfgRom: plxCfgRom 
	generic map ( 
		c_romSize 	=> c_cfgRomSize,
		c_ds0BaseAddr => c_ds0BaseAddr28,
		c_ds0ByteSz	=> c_ds0ByteSz,
		c_ds0En		=> c_ds0En,		
		c_ds1BaseAddr => c_ds1BaseAddr28,
		c_ds1ByteSz	=> c_ds1ByteSz,
		c_ds1En		=> c_ds1En
	)
	port map(
		clk => clk50,
		addr => cfgRomAddr,
		dout => cfgRomDout
	);  
end generate g_enPlxCfgY;

g_enPlxCfgN : if c_enPlxCfg = FALSE generate
		cfgRomDout <= (others => '0');
end generate g_enPlxCfgN;

	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- local bus signalling path
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

	-- Bus direction control
	lb_adsn		<= dm_adsn 		when dmAck = '1' else 'Z';
	lb_la		<= dm_la 		when dmAck = '1' else (others =>'Z');
	lb_lben		<= dm_lben 		when dmAck = '1' else (others =>'Z');
	lb_blastn	<= dm_blastn	when dmAck = '1' else 'Z';
	lb_lw_rn	<= dm_lw_rn 	when dmAck = '1' else 'Z';
	
	lb_readyn	<= ds_readyn	when dsAck = '1' else 'Z';	
	--lb_lserrn <= ds_lserrn when  dsAck = '1' else 'Z';	
	
	lb_ld <= ld_out when dm_ld_dir = '1' or ds_ld_dir = '1' else (others => 'Z');
	
	-- Data path
--	u_dp : lbDoutMux
--	port map ( 	owner => dmAck,
--	
--				dmSel => cfgComplete,
--				dmData(0) => cfgRomDout(31 downto 0),
--				dmData(1) => dpDoutA,
--					
--				dsSpace => ds1AddrValid,
--				ds0Sel => ds0RamEn,
--				ds0Data(0) => ds0RegDout,
--				ds0Data(1) => dpDoutA,
--				ds1Sel => ds1RamEn,
--				ds1Data(0) => ds1RegDout,
--				ds1Data(1) => ds1RamDout,
--					
--				dout => ld_out );

--	ldmuxSel(2) <= dmAck;
--	ldmuxSel(1) <= ds1AddrValid;
--	ldmuxSel(0) <= (	dmAck and cfgComplete ) or 
--				   (not dmAck and ( (not ds1AddrValid and ds0RamEn ) or  
--								  (      ds1AddrValid and ds1RamEn ) ) );
--				 
--				 
--ld_out <=	ds0RegDout 					when muxSel = "000" else
--			dpDoutA 					when muxSel = "001" else
--			ds1RegDout 					when muxSel = "010" else
--			ds1RamDout 					when muxSel = "011" else
--			cfgRomDout(31 downto 0) 	when muxSel = "100" else
--			dpDoutA 					when muxSel = "101" else
--			cfgRomDout(31 downto 0) 	when muxSel = "110" else
--			dpDoutA 					when muxSel = "111";  

	p_ld_out : process(dmAck,cfgComplete,dpDoutA,cfgRomDout,ds1AddrValid,ds1RamEn,
						ds1RamDout,ds1RegDout,ds0RamEn,lb_la,
						emac0Tx_lb_do,emac0Rx_lb_do,emac1Tx_lb_do,emac1Rx_lb_do,ds0RegDout,gtp_do,dpDoutA)
	begin
		if dmAck='1' then
			if cfgComplete = '1' then
					ld_out <=	dpDoutA;
			else
					ld_out <=	cfgRomDout(31 downto 0);
			end if;
		else
			if  ds1AddrValid = '1' then   --   = '1' lb_la(10)
				if ds1RamEn = '1' then
					ld_out <=	ds1RamDout;
				else
					ld_out <=	ds1RegDout;
				end if;
			else
				if lb_la(9) = '1' then
					ld_out <=	gtp_do;
				else
					if lb_la(8) = '1' then
						ld_out <=	dpDoutA;
					else
						if lb_la(7) = '1' then
							case lb_la(6 downto 5) is
								when "00" => ld_out <=	emac0Tx_lb_do;
								when "01" => ld_out <=	emac0Rx_lb_do;
								when "10" => ld_out <=	emac1Tx_lb_do;
								when "11" => ld_out <=	emac1Rx_lb_do;							
								when others => ld_out <= (others=>'0');
							end case;
						else
							ld_out <=	ds0RegDout;
						end if;
					end if;
				end if;			
			end if;
		end if;
	end process p_ld_out;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- local bus tie offs
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

	-- PLX interface
--	lb_adsn <= 'Z';	
--	lb_blastn <= 'Z';				-- PU on board
--	lb_la <= (others => 'Z');
--	lb_lben <= (others => 'Z'); 	-- PUs on board
--	lb_ld <= (others => 'Z');
--	lb_lholda <= 'Z'; 				-- PD on board
--	lb_lresetn <= 'Z';  			-- PU on board
--  lb_lserrn : in std_logic;
--	lb_lw_rn <= 'Z';				-- PU on board
--	lb_readyn <= 'Z';				-- PU on board
--	lb_ccsn <= 'Z'; 				-- PU on board
--	lb_lintin <= 'Z'; 				-- PU on board 
	
	lb_bigendn <= '1';				-- PU on board
	lb_breqi <= 'Z'; 				-- PD on board
	lb_btermn <= 'Z';				-- PU on board
	lb_eotn <= 'Z'; 				-- PU on board
	lb_dp <= (others => 'Z'); 		-- PUs on board
	lb_dreqn <= (others => 'Z');	-- PUs on board

--  lb_linton : in std_logic;
	lb_pmereon <= 'Z';				-- PU on board
	lb_useri <= 'Z';				-- PU on board
--  lb_usero : in std_logic;
--	lb_waitn <= 'Z';				-- PU on board
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- local bus monitor
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

	g_busmon : if c_plxDebug = TRUE generate
	u_busmon : plxBusMonitor 
	port MAP(
		clk => clk200,
		lb_adsn => lb_adsn,
		lb_bigendn => '0', --lb_bigendn,
		lb_blastn => lb_blastn,
		lb_breqi => '0', --lb_breqi,
		lb_breqo => lb_breqo,
		lb_btermn => '0', --lb_btermn,
		lb_ccsn => lb_ccsn_x,
		lb_dackn => "00", --lb_dackn,
		lb_eotn => '0', --lb_eotn,
		lb_dp => "0000", --lb_dp,
		lb_dreqn => "00", --lb_dreqn,
		lb_la => lb_la,
		lb_lben => lb_lben,
		lb_lclko => clk50,
		lb_lclki => '0',
		lb_ld => lb_ld,
		lb_lhold => lb_lhold,
		lb_lholda => dsAck,
		lb_lintin => '0', --lb_lintin,
		lb_linton => lb_linton,
		lb_lresetn => rstn,
		lb_lserrn => lb_lserrn,
		lb_lw_rn => lb_lw_rn,
		lb_pmereon => '0', --lb_pmereon,
		lb_readyn => lb_readyn,
		lb_useri => '0', --lb_useri,
		lb_usero => lb_usero,
		lb_waitn => lb_waitn,
		allClkStable => allClkStable
	);
	end generate g_busmon;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Local interrupt, uses register that are mapped
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	intSrc(0) <= dmint;
	intSrc(1) <= spiint;
	intSrc(31 downto 2) <= (others => '0');
	intGen <= intSrc and not intMask;
	
	lb_lintin <= '0' when intGen /= x"00000000" else '1';

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- SPI flash programmer
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	lb_rst <= not rstn;
	
	u_spi : entity work.plxSPIf2 
	port MAP(
		rst 			=> lb_rst,
		clk 			=> clk50,
		cmdReg 			=> ds1RegLocalOut(0)(7 downto 0),
		paramReg(0) 	=> ds1RegLocalOut(1)(7 downto 0),
		paramReg(1) 	=> ds1RegLocalOut(1)(15 downto 8),
		paramReg(2) 	=> ds1RegLocalOut(1)(23 downto 16),
		paramReg(3) 	=> ds1RegLocalOut(1)(31 downto 24),
		statusReg		=> ds1RegLocalin(2)(7 downto 0),
		statusRegWr		=> ds1RegLocalWr(2)(0),
		resultReg(0)	=> ds1RegLocalin(3)(7 downto 0),
		resultReg(1) 	=> ds1RegLocalin(3)(15 downto 8),
		resultReg(2) 	=> ds1RegLocalin(3)(23 downto 16),
		resultReg(3) 	=> ds1RegLocalin(3)(31 downto 24),
		resultRegWr(0) 	=> ds1RegLocalWr(3)(0),
		resultRegWr(1) 	=> ds1RegLocalWr(3)(1),
		resultRegWr(2) 	=> ds1RegLocalWr(3)(2),
		resultRegWr(3) 	=> ds1RegLocalWr(3)(3),
		dpDin 			=> dpDinB,
		dpDout 			=> dpDoutB,
		dpAddr 			=> dpAddrB,
		dpWr 			=> dpWrB,
--		spiSck 			=> spib_clk,
--		spiSdo 			=> spib_miso,
--		spiSdi 			=> spib_mosi,
--		spiCsn 			=> spib_csn
		spiSck 			=> spiSck, --spia_clk,
		spiMiso 		=> spiSdo, --spia_miso,
		spiMosi 		=> spiSdi, --spia_mosi,
		spiSS 			=> spiCsn --spia_csn
	);	

	
	spia_clk <=  spiSck when spiMuxSel = '0' else '0';
	spia_mosi <= spiSdi when spiMuxSel = '0' else '0';
	spia_csn <=  spiCsn when spiMuxSel = '0' else '1';

	spib_clk <=  spiSck when spiMuxSel = '1' else '0';
	spib_mosi <= spiSdi when spiMuxSel = '1' else '0';
	spib_csn <=  spiCsn when spiMuxSel = '1' else '1';

	spiSdo <= spia_miso when spiMuxSel = '0' else spib_miso;
	
	--spib_clk <= '0';
	--spib_mosi <= '0';
	--spib_csn <= '1';

	spiint <= ds1RegLocalOut(2)(0);	
	reprogram <= ds1RegLocalOut(2)(1);
	
	-- dual port ram for SPI
	u_dpram : dpRam32_8
	port map (
		clka	=> clk50,
		dina 	=> lb_ld,
		addra	=> ds1RamAddr,
		ena		=> ds1RamEn,
		wea 	=> ds1WrByte,		
		douta 	=> ds1RamDout,
		clkb	=> clk50,
		dinb	=> dpDinB,
		addrb	=> dpAddrB,
		web(0)	=> dpWrB,
		doutb	=> dpDoutB
	);
	
	u_v5internalConfig: v5internalConfig port MAP(
		clk => clk50,
		start => reprogram
	);
	-- The startup v5 primitive is required to access dedicated config pins
	-- attached CCLK, D_in which are directly connected to the spi flash.
	-- See UG191 for more details
	
	g_v5 : if c_simulation = false generate
		u_startupV5 : STARTUP_VIRTEX5
		port map (
			CFGCLK => open,
			CFGMCLK => open,
			DinSPI => spia_miso,
			EOS => open, 
			TCKSPI => open,  -- JTAG pin
			CLK => '0', 
			GSR => '0',
			GTS => '0', 
			USRCCLKO => spia_clk,
			USRCCLKTS => '0',
			USRDONEO => '0',
			USRDONETS => '1'
		);
	end generate;
		


	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Ethernet interface
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
-- UNCOMMNENT THIS CODE WHEN NOT USING EMAC
--
--		miia_txen <= '0';
--		miia_txd <= (others => '0');
--		miib_txen <= '0';
--		miib_txd <= (others => '0');	
--		
--		miia_intn <= 'Z';
--		miib_intn <= 'Z';
--		mii_mdio <= 'Z';
--		mii_mdc <= 'Z';
--		mii_resetn <= 'Z';
	
	-- emac loopback test module

		mii_mdio <= mii_mdio_o when mii_mdio_t = '0' else 'Z';
		-- switch level of tristate
		mii_mdio_i <= mii_mdio;
	
		emaca_pause_req <= '0';
		emaca_pause_val <= "0000000000000000";
		emacb_pause_req <= '0';
		emacb_pause_val <= "0000000000000000";
	
		miia_rxd(0) <= phy_ad1_rxd0_A when phy_strap = '1' else 'Z';
		miia_rxd(1) <= phy_ad2_rxd1_A when phy_strap = '1' else 'Z';
		miia_rxd(2) <= 'Z';
		miia_rxd(3) <= 'Z';
		
		miib_rxd(0) <= phy_ad3_rxd0_B when phy_strap = '1' else 'Z';
		miib_rxd(1) <= phy_ad4_rxd1_B when phy_strap = '1' else 'Z';	
		miib_rxd(2) <= 'Z';
		miib_rxd(3) <= 'Z';
	
		u_emac_init : emac_init
		generic map ( 	c_porCntBit => c_emacPorCntBit,
						c_lbtest => TRUE 						)
		port map (
			clk => clk50,
			lb_lresetn => rstn,
			temac_rstni => '0',
			temac_rsto => emac_reset,
			host_clk => host_clk,
			host_opcode => host_opcode,
			host_req => host_req,
			host_miim_sel => host_miim_sel,
			host_addr => host_addr,
			host_wr_data => host_wr_data,
			host_miim_rdy => host_miim_rdy,
			host_rd_data => host_rd_data,
			host_emac1_sel => host_emac1_sel,
			busi_opcode => busi_opcode,
			busi_req => busi_req,
			busi_miim_sel => busi_miim_sel,
			busi_addr => busi_addr,
			busi_wr_data => busi_wr_data,
			buso_miim_rdy => buso_miim_rdy,
			buso_rd_data => buso_rd_data,
			busi_emac1_sel => busi_emac1_sel,
			phy_strap => phy_strap,
			phy_resetn => mii_resetn,
			phy_ad1_rxd0_A => phy_ad1_rxd0_A,
			phy_ad2_rxd1_A => phy_ad2_rxd1_A,
			phy_ad3_rxd0_B => phy_ad3_rxd0_B,
			phy_ad4_rxd1_B => phy_ad4_rxd1_B,
			phya_pwrDown => miia_intn,
			phyb_pwrDown => miib_intn,
			done => emacInitDone
		);
	

		--~~~~~~~~~~~~~~~~~~~~~~~~
		-- The logic below was formerly in v5_emac_v1_3_example_design.vhd
		-- it has been moved up a level to make interconnection easier.

--		ll_clk_0_i <= clk50;  --formerly clkApp, which was a port mapped to clk20;
--		ll_clk_1_i <= clk50;  --formerly clkApp, which was a port mapped to clk20;
		
		-- EMAC0 Clocking

		-- Client clocks are looped back into emac wrapper
		-- Note that these clocks can be different
		
		-- TX_CLIENT_CLK_0 and TX_LL_CLOCK_0
		-- RX_CLIENT_CLK_0 and RX_LL_CLOCK_0
		
		-- Put the PHY clocks from the EMAC through BUFGs.
		-- Used to clock the PHY side of the EMAC wrappers.
		bufg_phy_tx_0 : BUFG port map (I => miia_txclk, O => tx_phy_clk_0); -- MII_TX_CLK_0
		bufg_phy_rx_0 : BUFG port map (I => miia_rxclk, O => rx_clk_0_i); -- MII_RX_CLK_0

		-- Put the client clocks from the EMAC through BUFGs.
		-- Used to clock the client side of the EMAC wrappers.
		bufg_client_tx_0 : BUFG port map (I => tx_client_clk_0_o, O => tx_client_clk_0);
		bufg_client_rx_0 : BUFG port map (I => rx_client_clk_0_o, O => rx_client_clk_0);

		-- EMAC1 Clocking

		-- Put the PHY clocks from the EMAC through BUFGs.
		-- Used to clock the PHY side of the EMAC wrappers.
		bufg_phy_tx_1 : BUFG port map (I =>  miib_txclk, O => tx_phy_clk_1); -- MII_TX_CLK_1
		bufg_phy_rx_1 : BUFG port map (I =>  miib_rxclk, O => rx_clk_1_i); -- MII_RX_CLK_1

		-- Put the client clocks from the EMAC through BUFGs.
		-- Used to clock the client side of the EMAC wrappers.
		bufg_client_tx_1 : BUFG port map (I => tx_client_clk_1_o, O => tx_client_clk_1);
		bufg_client_rx_1 : BUFG port map (I => rx_client_clk_1_o, O => rx_client_clk_1);
	

g_emactbN : if c_standalone = FALSE generate		
		u_emacTx0 : entity work.emacTx		
		port map
		(       
			ll_clk_i		=> clk50, --ll_clk_0_i,
			ll_reset_i		=> ll_reset_0_i,
			lb_di			=> lb_ld,
			lb_do			=> emac0Tx_lb_do,
			lb_a			=> lb_la(4 downto 2),
			lb_en			=> emac0tx_lb_en,
			lb_wr			=> ds0WrByte,
			pktSend			=> emac0Tx_pktSend,
			pktSz			=> emac0Tx_pktSz,
			pktDone			=> emac0Tx_pktDone,
			tx_ll_data		=> tx_ll_data_0_i,
			tx_ll_sof_n		=> tx_ll_sof_n_0_i,
			tx_ll_eof_n		=> tx_ll_eof_n_0_i,
			tx_ll_src_rdy_n	=> tx_ll_src_rdy_n_0_i,
			tx_ll_dst_rdy_n	=> tx_ll_dst_rdy_n_0_i
		);
		
		u_emacRx0 : entity work.emacRx		
		port map
		(       
			ll_clk_i		=> clk50, --ll_clk_0_i,
			ll_reset_i		=> ll_reset_0_i,
			lb_di			=> lb_ld,
			lb_do			=> emac0Rx_lb_do,
			lb_a			=> lb_la(4 downto 2),
			lb_en			=> emac0Rx_lb_en,
			lb_wr			=> ds0WrByte,
			pktProcd		=> emac0Rx_pktProcd,
			pktSz			=> emac0Rx_pktSz,
			pktDone			=> emac0Rx_pktDone,
			rx_ll_data 		=> rx_ll_data_0_i,
			rx_ll_sof_n 	=> rx_ll_sof_n_0_i,
			rx_ll_eof_n 	=> rx_ll_eof_n_0_i,
			rx_ll_src_rdy_n => rx_ll_src_rdy_n_0_i,
			rx_ll_dst_rdy_n => rx_ll_dst_rdy_n_0_i
		);
		
		u_emacTx1 : entity work.emacTx		
		port map
		(       
			ll_clk_i		=> clk50, --ll_clk_1_i,
			ll_reset_i		=> ll_reset_1_i,
			lb_di			=> lb_ld,
			lb_do			=> emac1Tx_lb_do,
			lb_a			=> lb_la(4 downto 2),
			lb_en			=> emac1Tx_lb_en,
			lb_wr			=> ds0WrByte,
			pktSend			=> emac1Tx_pktSend,
			pktSz			=> emac1Tx_pktSz,
			pktDone			=> emac1Tx_pktDone,
			tx_ll_data		=> tx_ll_data_1_i,
			tx_ll_sof_n		=> tx_ll_sof_n_1_i,
			tx_ll_eof_n		=> tx_ll_eof_n_1_i,
			tx_ll_src_rdy_n	=> tx_ll_src_rdy_n_1_i,
			tx_ll_dst_rdy_n	=> tx_ll_dst_rdy_n_1_i
		);		
		
		u_emacRx1 : entity work.emacRx		
		port map
		(       
			ll_clk_i		=> clk50, --ll_clk_0_i,
			ll_reset_i		=> ll_reset_0_i,
			lb_di			=> lb_ld,
			lb_do			=> emac1Rx_lb_do,
			lb_a			=> lb_la(4 downto 2),
			lb_en			=> emac1Rx_lb_en,
			lb_wr			=> ds0WrByte,
			pktProcd		=> emac1Rx_pktProcd,
			pktSz			=> emac1Rx_pktSz,
			pktDone			=> emac1Rx_pktDone,
			rx_ll_data 		=> rx_ll_data_1_i,
			rx_ll_sof_n 	=> rx_ll_sof_n_1_i,
			rx_ll_eof_n 	=> rx_ll_eof_n_1_i,
			rx_ll_src_rdy_n => rx_ll_src_rdy_n_1_i,
			rx_ll_dst_rdy_n => rx_ll_dst_rdy_n_1_i
		);
end generate g_emactbN;

g_emactbY : if c_standalone = TRUE generate		
		u_icmp0 : entity work.emacICMP
		port map
		(       
			ll_clk_i => clk50, --ll_clk_0_i,
			ll_reset_i => ll_reset_0_i,
			rx_ll_data => rx_ll_data_0_i,
			rx_ll_sof_n => rx_ll_sof_n_0_i,
			rx_ll_eof_n => rx_ll_eof_n_0_i,
			rx_ll_src_rdy_n => rx_ll_src_rdy_n_0_i,
			rx_ll_dst_rdy_n => rx_ll_dst_rdy_n_0_i,
			tx_ll_data => tx_ll_data_0_i,
			tx_ll_sof_n => tx_ll_sof_n_0_i,
			tx_ll_eof_n => tx_ll_eof_n_0_i,
			tx_ll_src_rdy_n => tx_ll_src_rdy_n_0_i,
			tx_ll_dst_rdy_n => tx_ll_dst_rdy_n_0_i
		);
		u_icmp1 : entity work.emacICMP
		port map
		(       
			ll_clk_i => clk50, --ll_clk_1_i,
			ll_reset_i => ll_reset_1_i,
			rx_ll_data => rx_ll_data_1_i,
			rx_ll_sof_n => rx_ll_sof_n_1_i,
			rx_ll_eof_n => rx_ll_eof_n_1_i,
			rx_ll_src_rdy_n => rx_ll_src_rdy_n_1_i,
			rx_ll_dst_rdy_n => rx_ll_dst_rdy_n_1_i,
			tx_ll_data => tx_ll_data_1_i,
			tx_ll_sof_n => tx_ll_sof_n_1_i,
			tx_ll_eof_n => tx_ll_eof_n_1_i,
			tx_ll_src_rdy_n => tx_ll_src_rdy_n_1_i,
			tx_ll_dst_rdy_n => tx_ll_dst_rdy_n_1_i
		);
end generate g_emactbY;
		
		-- Create synchronous reset in the transmitter clock domain.
		-- did use ll_clk_0_i
		p_ll_reset_emac0 : process (clk50, emac_reset) -- was reset_i
		begin
			if emac_reset = '1' then
				ll_pre_reset_0_i <= (others => '1');
				ll_reset_0_i     <= '1';
			elsif clk50'event and clk50 = '1' then
				ll_pre_reset_0_i(0)          <= '0';
				ll_pre_reset_0_i(5 downto 1) <= ll_pre_reset_0_i(4 downto 0);
				ll_reset_0_i                 <= ll_pre_reset_0_i(5);
			end if;
		end process p_ll_reset_emac0;		
		
		-- Create synchronous reset in the transmitter clock domain.
				-- did use ll_clk_1_i
		p_ll_reset_emac1 : process (clk50, emac_reset) -- was reset_i
		begin
			if emac_reset = '1' then
				ll_pre_reset_1_i <= (others => '1');
				ll_reset_1_i     <= '1';
			elsif clk50'event and clk50 = '1' then
				ll_pre_reset_1_i(0)          <= '0';
				ll_pre_reset_1_i(5 downto 1) <= ll_pre_reset_1_i(4 downto 0);
				ll_reset_1_i                 <= ll_pre_reset_1_i(5);
			end if;
		end process p_ll_reset_emac1;
		
		u_emac : entity work.v5_emac_v1_3_locallink 
		PORT MAP(
		
			--~~~~~~~~~~~~~~~~~~
			-- EMAC0 
			--~~~~~~~~~~~~~~~~~~
			-- Clocking
			TX_CLIENT_CLK_OUT_0             => tx_client_clk_0_o,	-- TX Client Clock output from EMAC0
			RX_CLIENT_CLK_OUT_0             => rx_client_clk_0_o,	-- RX Client Clock output from EMAC0
			TX_PHY_CLK_OUT_0                => open,				-- TX PHY Clock output from EMAC0
			TX_CLIENT_CLK_0                 => tx_client_clk_0,		-- EMAC0 TX Client Clock input from BUFG
			RX_CLIENT_CLK_0                 => rx_client_clk_0,		-- EMAC0 RX Client Clock input from BUFG
			TX_PHY_CLK_0                    => tx_phy_clk_0, 		-- EMAC0 TX PHY Clock input from BUFG
			
			-- Local link Receiver Interface
			RX_LL_CLOCK_0                   => clk50, --ll_clk_0_i,
			RX_LL_RESET_0                   => ll_reset_0_i,
			RX_LL_DATA_0                    => rx_ll_data_0_i,
			RX_LL_SOF_N_0                   => rx_ll_sof_n_0_i,
			RX_LL_EOF_N_0                   => rx_ll_eof_n_0_i,
			RX_LL_SRC_RDY_N_0               => rx_ll_src_rdy_n_0_i,
			RX_LL_DST_RDY_N_0               => rx_ll_dst_rdy_n_0_i,
			RX_LL_FIFO_STATUS_0             => open,

			-- Local link Transmitter Interface
			TX_LL_CLOCK_0                   => clk50, --ll_clk_0_i,
			TX_LL_RESET_0                   => ll_reset_0_i,
			TX_LL_DATA_0                    => tx_ll_data_0_i,
			TX_LL_SOF_N_0                   => tx_ll_sof_n_0_i,
			TX_LL_EOF_N_0                   => tx_ll_eof_n_0_i,
			TX_LL_SRC_RDY_N_0               => tx_ll_src_rdy_n_0_i,
			TX_LL_DST_RDY_N_0               => tx_ll_dst_rdy_n_0_i,

			-- Client Receiver Interface		
			EMAC0CLIENTRXDVLD => open,
			EMAC0CLIENTRXFRAMEDROP => open,
			EMAC0CLIENTRXSTATS => open,
			EMAC0CLIENTRXSTATSVLD => open,
			EMAC0CLIENTRXSTATSBYTEVLD => open,
			
			-- Client Transmitter Interface		
			CLIENTEMAC0TXIFGDELAY => emaca_tx_ifg_delay,
			EMAC0CLIENTTXSTATS => open,
			EMAC0CLIENTTXSTATSVLD => open,
			EMAC0CLIENTTXSTATSBYTEVLD => open,
			
			-- MAC Control Interface
			CLIENTEMAC0PAUSEREQ => emaca_pause_req,
			CLIENTEMAC0PAUSEVAL => emaca_pause_val,
			
			-- miia
			MII_COL_0 => miia_col,
			MII_CRS_0 => miia_crs,
			MII_TXD_0 => miia_txd,
			MII_TX_EN_0 => miia_txen,
			MII_TX_ER_0 => open,
			MII_TX_CLK_0 					=> tx_phy_clk_0, -- buffered miia_txclk,
			MII_RXD_0 => miia_rxd,
			MII_RX_DV_0 => miia_rxdv,
			MII_RX_ER_0 => miia_rxer,
			MII_RX_CLK_0 					=> rx_clk_0_i, -- buffered miia_rxclk,
			
			-- management
			MDC_0 => mii_mdc,
			MDIO_0_I => mii_mdio_i,
			MDIO_0_O => mii_mdio_o,
			MDIO_0_T => mii_mdio_t,

			--~~~~~~~~~~~~~~~~~~
			-- EMAC1 
			--~~~~~~~~~~~~~~~~~~

			-- Clocking
			TX_CLIENT_CLK_OUT_1             => tx_client_clk_1_o,-- TX Client Clock output from EMAC1
			RX_CLIENT_CLK_OUT_1             => rx_client_clk_1_o,-- RX Client Clock output from EMAC1
			TX_PHY_CLK_OUT_1                => open,-- TX PHY Clock output from EMAC1
			TX_CLIENT_CLK_1                 => tx_client_clk_1,-- EMAC1 TX Client Clock input from BUFG
			RX_CLIENT_CLK_1                 => rx_client_clk_1,-- EMAC1 RX Client Clock input from BUFG
			TX_PHY_CLK_1                    => tx_phy_clk_1, -- EMAC1 TX PHY Clock input from BUFG

			-- Local link Receiver Interface
			RX_LL_CLOCK_1                   => clk50, --ll_clk_1_i,
			RX_LL_RESET_1                   => ll_reset_1_i,
			RX_LL_DATA_1                    => rx_ll_data_1_i,
			RX_LL_SOF_N_1                   => rx_ll_sof_n_1_i,
			RX_LL_EOF_N_1                   => rx_ll_eof_n_1_i,
			RX_LL_SRC_RDY_N_1               => rx_ll_src_rdy_n_1_i,
			RX_LL_DST_RDY_N_1               => rx_ll_dst_rdy_n_1_i,
			RX_LL_FIFO_STATUS_1             => open,

			-- Local link Transmitter Interface
			TX_LL_CLOCK_1                   => clk50, --ll_clk_1_i,
			TX_LL_RESET_1                   => ll_reset_1_i,
			TX_LL_DATA_1                    => tx_ll_data_1_i,
			TX_LL_SOF_N_1                   => tx_ll_sof_n_1_i,
			TX_LL_EOF_N_1                   => tx_ll_eof_n_1_i,
			TX_LL_SRC_RDY_N_1               => tx_ll_src_rdy_n_1_i,
			TX_LL_DST_RDY_N_1               => tx_ll_dst_rdy_n_1_i,

			-- Client Receiver Interface
			EMAC1CLIENTRXDVLD => open,
			EMAC1CLIENTRXFRAMEDROP => open,
			EMAC1CLIENTRXSTATS => open,
			EMAC1CLIENTRXSTATSVLD => open,
			EMAC1CLIENTRXSTATSBYTEVLD => open,

			-- Client Transmitter Interface
			CLIENTEMAC1TXIFGDELAY => emacb_tx_ifg_delay,
			EMAC1CLIENTTXSTATS => open,
			EMAC1CLIENTTXSTATSVLD => open,
			EMAC1CLIENTTXSTATSBYTEVLD => open,

			-- MAC Control Interface
			CLIENTEMAC1PAUSEREQ => emacb_pause_req,
			CLIENTEMAC1PAUSEVAL => emacb_pause_val,

			-- MII Interface
			MII_COL_1 => miib_col,
			MII_CRS_1 => miib_crs,
			MII_TXD_1 => miib_txd,
			MII_TX_EN_1 => miib_txen,
			MII_TX_ER_1 => open,
			MII_TX_CLK_1					=> tx_phy_clk_1, -- buffered miib_txclk,
			MII_RXD_1 => miib_rxd,
			MII_RX_DV_1 => miib_rxdv,
			MII_RX_ER_1 => miib_rxer,
			MII_RX_CLK_1 					=> rx_clk_1_i, -- buffered miib_rxclk,

			-- Generic Host Interface
			HOSTCLK => host_clk,
			HOSTOPCODE => host_opcode,
			HOSTREQ => host_req,
			HOSTMIIMSEL => host_miim_sel,
			HOSTADDR => host_addr,
			HOSTWRDATA => host_wr_data,
			HOSTMIIMRDY => host_miim_rdy,
			HOSTRDDATA => host_rd_data,
			HOSTEMAC1SEL => host_emac1_sel,

			RESET => emac_reset
			);			--rst);
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Serial ports
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
-- UNCOMMENT THESE TIE OFFS TO DISABLE SERIAL
---	
--	rs0_tx <= '0';
--	rs0_renn <= '1';
--	rs0_ten <= '0';
--	
--	rs1_tx <= '0';
--	rs1_renn <= '1';
--	rs1_ten <= '0';

--	u_serialTest0 : entity work.serialTest PORT MAP(
--		rstn => lb_lresetn,
--		clk => clk50,
--		rx => rs0_rx,
--		tx => rs0_tx,
--		renn => rs0_renn,
--		ten => rs0_ten
--	);
--	
--	u_serialTest1 : entity work.serialTest PORT MAP(
--		rstn => lb_lresetn,
--		clk => clk50,
--		rx => rs1_rx,
--		tx => rs1_tx,
--		renn => rs1_renn,
--		ten => rs1_ten
--	);	
	
	u_serialTest0 : serialSimple
	PORT MAP(
		rstn => rstn,
		clk => clk50,
		rx => rs0_rx,
		tx => rs0_tx,
		renn => rs0_renn,
		ten => rs0_ten,
		baudSet => rs0_baudSet,
		tx_data => rs0_txData,
		rx_data => rs0_rxData,
		ctrl => rs0_ctrl,
		status => rs0_status
	);
	
	u_serialTest1 : serialSimple
	PORT MAP(
		rstn => rstn,
		clk => clk50,
		rx => rs1_rx,
		tx => rs1_tx,
		renn => rs1_renn,
		ten => rs1_ten,
		baudSet => rs1_baudSet,
		tx_data => rs1_txData,
		rx_data => rs1_rxData,
		ctrl => rs1_ctrl,
		status => rs1_status		
	);		
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- EEPROM
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

	--eth_ee_clk <= '0';
	--eth_ee_dido <= 'Z';
	--eth_ee_cs <= '1';
	
	u_eeprom : eepromMaster PORT MAP(
		rstn => rstn,
		clk => clk50,
		sk => eth_ee_clk,
		cs => eth_ee_cs,
		sd => eth_ee_dido,
		mwStart => mwStart,
		mwCmd => mwCmd,
		mwAddr => mwAddr,
		mwRdCnt => mwRdCnt,
		mwDo => mwDo,
		mwDone => mwDone,
		mwDi => mwDi,
		regQ => eepromData,
		stateOut => open
	);
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- High speed user io
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		

g_hss_user_io : for j in 0 to 3 generate
	hss_user_io(j) <= hss_user_io_o(j) when hss_user_io_t(j) = '1' else 'Z';
end generate g_hss_user_io;

	hss_user_io_i <= hss_user_io;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- DDR2, copied from ddr2400_app_plx.vhd
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
	ddr2_a(13) <= '0';
	ddr2_ba(2) <= '0';
	
					
	u_mig20 : mig20_app
	generic map (
		CLK_WIDTH => 1,
		CS_WIDTH => 1,
		ODT_WIDTH => 1,
		DEBUG_EN => c_ddr2Debug,
		DQ_IO_MS => c_DQ_IO_MS,
		ODT_TYPE	=> c_ODT_TYPE,
		REDUCE_DRV	=> c_REDUCE_DRV		
	)
	port map (
		sys_clk_i           => clk200,
		clk200_i            => clk200,
		dcmClkinLock		=> clk200Locked,
		sys_rst_n         => rstn,
		ddr2_ras_n        => ddr2_ras_n,
		ddr2_cas_n        => ddr2_cas_n,
		ddr2_we_n         => ddr2_we_n,
		ddr2_cs_n         => ddr2_cs_n,
		ddr2_cke          => ddr2_cke,
		ddr2_odt          => ddr2_odt,
		ddr2_dm           => ddr2_dm,
		ddr2_dq           => ddr2_dq,
		ddr2_dqs          => ddr2_dqs,
		ddr2_dqs_n        => ddr2_dqs_n,
		ddr2_ck           => ddr2_ck,
		ddr2_ck_n         => ddr2_ck_n,
		ddr2_ba           => ddr2_ba(1 downto 0),
		ddr2_a            => ddr2_a(12 downto 0),
		
		clk0_tb           => clk0_tb,
		rst0_tb           => rst0_tb,
		app_af_afull      => app_af_afull,
		app_wdf_afull     => app_wdf_afull,
		rd_data_valid     => rd_data_valid,
		rd_data_fifo_out  => rd_data_fifo_out,
		app_af_wren       => app_af_wren,
		app_af_cmd        => app_af_cmd,
		app_af_addr       => app_af_addr,
		app_wdf_wren      => app_wdf_wren,
		app_wdf_data      => app_wdf_data,
		app_wdf_mask_data => app_wdf_mask_data,
		
		phy_init_done     => phy_init_done
	);

	u_interface : entity work.ddr2_interface port MAP(
		clkPlx => clk50,
		txfrCtrlA => txfrCtrlA,
		txfrCmdA => txfrCmdA,
		txfrSzA => txfrSzA,
		txfrAddrA => txfrAddrA,
		txfrStatusA => txfrStatusA,
		dpEnA => dpEnA,
		dpWenA => dpWenA,
		dpAddrA => dpAddrA,
		dpDinA => lb_ld,
		dpDoutA => dpDoutA,
		clk0 => clk0_tb,
		rst0 => rst0_tb,
		app_af_afull => app_af_afull,
		app_wdf_afull => app_wdf_afull,
		rd_data_valid => rd_data_valid,
		rd_data_fifo_out => rd_data_fifo_out,
		phy_init_done => phy_init_done,
		app_af_wren => app_af_wren,
		app_af_cmd => app_af_cmd,
		app_af_addr => app_af_addr,
		app_wdf_wren => app_wdf_wren,
		app_wdf_data => app_wdf_data,
		app_wdf_mask_data => app_wdf_mask_data
	);

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- GPIO, single ended
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	g_io : for i in 0 to 31 generate
	
		gpio_n(i) <= gpio_n_o(i) when gpio_n_t(i) = '1' else 'Z';
		gpio_p(i) <= gpio_p_o(i) when gpio_p_t(i) = '1' else 'Z';
	
	end generate;
	
	gpio_n_i <= gpio_n;
	gpio_p_i <= gpio_p;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Clocking
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

	u_clkControl: clkControlMem
	generic map (
		c_simulation => c_simulation,
		c_ddr2type => DDR2400,
		c_pcbrev => c_pcbrev
	)
	port map(
		mainclkp => mainclkp,
		mainclkn => mainclkn,
		lclkfb => lb_lclkfb,
		lclko(0) => lb_lclko_plx,
		lclko(1) => lb_lclko_loop,
		clk50 => clk50,
		clk100 => clk100,
		clk200 => clk200,
		clk200Locked => clk200Locked,
		pllClk => pllClk,
		pllLocked => pllLocked,
		allClkStable => allClkStable
	);
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- MGT
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
--SIM_PLL_PERDIV2
--The GTP_DUAL tile contains an analog PLL to generate the transmit and receive clocks
--out of a reference clock. Because HDL simulators do not fully model the analog PLL, the
--GTP_DUAL SmartModel includes an equivalent behavioral model to simulate the PLL
--output. The SIM_PLL_PERDIV2 attribute is used by the behavioral model to generate the
--PLL output as accurately as possible. It must be set to one-half the period of the shared
--PMA PLL. See ?Examples,? page 48 for how to calculate SIM_PLL_PERDIV2 for a given
--rate.
--
--
--pll speed = (refclk / pll_div_ref) * div * pll_divsel_fb
--pll speed = (100 mhz / 2 ) * 5 * 5
--pll speed = 1250 mhz
--
--sim_pll_deriv2 = (1/pll_speed) / 2
--sim_pll_deriv2 = 0.0004 = 0x190
--(PCIe example)

	u_mgt : entity work.mgt_tester 
	generic map
	(
		EXAMPLE_SIM_PLL_PERDIV2 => x"1f4", -- was x190
		c_v5type => c_v5type
	)
	PORT MAP
	(
		TILE0_REFCLK_PAD_N_IN => mgt114_refclkn,
		TILE0_REFCLK_PAD_P_IN => mgt114_refclkp,
		
		RXN_IN(0) => mgt114_rx0n,
		RXN_IN(1) => mgt114_rx1n,
		RXN_IN(2) => mgt112_rx0n,
		RXN_IN(3) => mgt112_rx1n,
		
		RXP_IN(0) => mgt114_rx0p,
		RXP_IN(1) => mgt114_rx1p,
		RXP_IN(2) => mgt112_rx0p,
		RXP_IN(3) => mgt112_rx1p,
			
		TXN_OUT(0) => mgt114_tx0n,
		TXN_OUT(1) => mgt114_tx1n,
		TXN_OUT(2) => mgt112_tx0n,
		TXN_OUT(3) => mgt112_tx1n,
		
		TXP_OUT(0) => mgt114_tx0p, 
		TXP_OUT(1) => mgt114_tx1p,
		TXP_OUT(2) => mgt112_tx0p,
		TXP_OUT(3) => mgt112_tx1p,
		
		gtp_rst						=> lb_rst,
		rx_rst 						=> gtp_rx_rst,
		tx_rst 						=> gtp_tx_rst,

		lb_clk						=> clk50,
		lb_we						=> ds0WrByte,
		lb_a						=> lb_la(8 downto 2),
		lb_en						=> gtp_ram_en,
		lb_di						=> lb_ld,
		lb_do						=> gtp_do,
			
		lb_tx_start					=> gtp_tx_start,
		lb_tx_done					=> gtp_tx_done,
		lb_tx_sz					=> gtp_tx_sz,
		
		lb_rx_done					=> gtp_rx_done,
		lb_rx_sz					=> gtp_rx_sz,
		lb_rx_ok					=> gtp_rx_ok,
		lb_rx_err_cnt				=> gtp_rx_err_cnt,
		
		lb_loopback					=> gtp_loopback,
		tile0_pll_ok				=> gtp_tile0_pll_ok,
		tile1_pll_ok				=> gtp_tile1_pll_ok
	);

end rtl;