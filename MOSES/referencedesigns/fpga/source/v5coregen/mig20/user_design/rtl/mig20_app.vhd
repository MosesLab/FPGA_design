--*****************************************************************************
-- Copyright (c) 2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, Inc.
-- All Rights Reserved
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: $Name: i+IP+131489 $
--  \   \         Filename: mig20.vhd
--  /   /         Date Last Modified: $Date: 2007/09/21 15:23:31 $
-- /___/   /\     Date Created: Wed Jan 10 2007
-- \   \  /  \
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   Top-level module. Simple model for what the user might use
--   Typically, the user will only instantiate MEM_INTERFACE_TOP in their
--   code, and generate all the other infrastructure and backend logic
--   separately. This module serves both as an example, and allows the user
--   to synthesize a self-contained design, which they can use to test their
--   hardware.
--   In addition to the memory controller, the module instantiates:
--     1. Clock generation/distribution, reset logic
--     2. IDELAY control block
--     3. Synthesizable testbench - used to model user's backend logic
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity mig20_app is
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
	dcmClkInLock	: in std_logic;   
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

--  attribute X_CORE_INFO : string;
--  attribute X_CORE_INFO of mig20 : ENTITY IS
--    "mig_v2_00_ddr2_v5, Coregen 9.2i_ip2";

end entity mig20_app;

architecture arc_mem_interface_top of mig20_app is

  component mig20_idelay_ctrl
    port (
      rst200               : in    std_logic;
      clk200               : in    std_logic;
      idelay_ctrl_rdy      : out   std_logic
      );
  end component;

  component mig20_infrastructure
    generic (
      CLK_PERIOD            : integer;
      RST_ACT_LOW           : integer;
      DLL_FREQ_MODE         : string
      );
    port (
      --sys_clk_p            : in std_logic;
      --sys_clk_n            : in std_logic;
      --clk200_p             : in std_logic;
      --clk200_n             : in std_logic;
		sys_clk_i			: in std_logic;
		clk200_i			: in std_logic;	  
		dcmClkInLock		: in std_logic;
      sys_rst_n            : in std_logic;
      rst0                 : out std_logic;
      rst90                : out std_logic;
      rst200               : out std_logic;
      rstdiv0              : out std_logic;
      clk0                 : out std_logic;
      clk90                : out std_logic;
      clk200               : out std_logic;
      clkdiv0              : out std_logic;
      idelay_ctrl_rdy      : in std_logic
      );
  end component;

component mig20_ddr2_top_0
    generic (
      BANK_WIDTH            : integer;
      CKE_WIDTH             : integer;
      CLK_WIDTH             : integer;
      COL_WIDTH             : integer;
      CS_NUM                : integer;
      CS_WIDTH              : integer;
      CS_BITS               : integer;
      DM_WIDTH              : integer;
      DQ_WIDTH              : integer;
      DQ_PER_DQS            : integer;
      DQS_WIDTH             : integer;
      DQ_BITS               : integer;
      DQS_BITS              : integer;
      ODT_WIDTH             : integer;
      ROW_WIDTH             : integer;
      ADDITIVE_LAT          : integer;
      BURST_LEN             : integer;
      BURST_TYPE            : integer;
      CAS_LAT               : integer;
      ECC_ENABLE            : integer;
      APPDATA_WIDTH         : integer;
      MULTI_BANK_EN         : integer;
      TWO_T_TIME_EN         : integer;
      ODT_TYPE              : integer;
      REDUCE_DRV            : integer;
      REG_ENABLE            : integer;
      TREFI_NS              : integer;
      TRAS                  : integer;
      TRCD                  : integer;
      TRFC                  : integer;
      TRP                   : integer;
      TRTP                  : integer;
      TWR                   : integer;
      TWTR                  : integer;
      SIM_ONLY              : integer;
      DEBUG_EN              : integer;
      DQS_IO_COL            : bit_vector;
      DQ_IO_MS              : bit_vector;
      CLK_PERIOD            : integer
      );
    port (
      ddr2_dq              : inout std_logic_vector((DQ_WIDTH-1) downto 0);
      ddr2_a               : out   std_logic_vector((ROW_WIDTH-1) downto 0);
      ddr2_ba              : out   std_logic_vector((BANK_WIDTH-1) downto 0);
      ddr2_ras_n           : out   std_logic;
      ddr2_cas_n           : out   std_logic;
      ddr2_we_n            : out   std_logic;
      ddr2_cs_n            : out   std_logic_vector((CS_WIDTH-1) downto 0);
      ddr2_odt             : out   std_logic_vector((ODT_WIDTH-1) downto 0);
      ddr2_cke             : out   std_logic_vector((CKE_WIDTH-1) downto 0);
      ddr2_dm              : out   std_logic_vector((DM_WIDTH-1) downto 0);
      phy_init_done        : out   std_logic;
      rst0                 : in    std_logic;
      rst90                : in    std_logic;
      rstdiv0              : in    std_logic;
      clk0                 : in    std_logic;
      clk90                : in    std_logic;
      clkdiv0              : in    std_logic;
      app_wdf_afull        : out   std_logic;
      app_af_afull         : out   std_logic;
      rd_data_valid        : out   std_logic;
      app_wdf_wren         : in    std_logic;
      app_af_wren          : in    std_logic;
      app_af_addr          : in    std_logic_vector(30 downto 0);
      app_af_cmd           : in    std_logic_vector(2 downto 0);
      rd_data_fifo_out     : out   std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_data         : in    std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_mask_data    : in    std_logic_vector((APPDATA_WIDTH/8-1) downto 0);
      ddr2_dqs             : inout std_logic_vector((DQS_WIDTH-1) downto 0);
      ddr2_dqs_n           : inout std_logic_vector((DQS_WIDTH-1) downto 0);
      ddr2_ck              : out   std_logic_vector((CLK_WIDTH-1) downto 0);
      rd_ecc_error         : out   std_logic_vector(1 downto 0);
      ddr2_ck_n            : out   std_logic_vector((CLK_WIDTH-1) downto 0);

      dbg_idel_up_all        : in    std_logic;
      dbg_idel_down_all      : in    std_logic;
      dbg_idel_up_dq         : in    std_logic;
      dbg_idel_down_dq       : in    std_logic;
      dbg_idel_up_dqs        : in    std_logic;
      dbg_idel_down_dqs      : in    std_logic;
      dbg_idel_up_gate       : in    std_logic;
      dbg_idel_down_gate     : in    std_logic;
      dbg_sel_idel_dq        : in    std_logic_vector(DQ_BITS-1 downto 0);
      dbg_sel_all_idel_dq    : in    std_logic;
      dbg_sel_idel_dqs       : in    std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_dqs   : in    std_logic;
      dbg_sel_idel_gate      : in    std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_gate  : in    std_logic;
      dbg_calib_done         : out   std_logic_vector(3 downto 0);
      dbg_calib_err          : out   std_logic_vector(3 downto 0);
      dbg_calib_dq_tap_cnt   : out   std_logic_vector((6*DQ_WIDTH)-1 downto 0);
      dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH-1 downto 0);
      dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1
                                                      downto 0)
      );
  end component;



  signal  rst0                 : std_logic;
  signal  rst90                : std_logic;
  signal  rst200               : std_logic;
  signal  rstdiv0              : std_logic;
  signal  clk0                 : std_logic;
  signal  clk90                : std_logic;
  signal  clk200               : std_logic;
  signal  clkdiv0              : std_logic;
  signal  idelay_ctrl_rdy      : std_logic;
  signal  i_phy_init_done      : std_logic;
  
signal app_wdf_afull_x			: std_logic;
signal app_af_afull_x			: std_logic;
signal rd_data_valid_x			: std_logic;
signal rd_data_fifo_out_x		: std_logic_vector((APPDATA_WIDTH-1) downto 0);

  -- Debug signals (optional use)
  signal dbg_idel_up_all        : std_logic;
  signal dbg_idel_down_all      : std_logic;
  signal dbg_idel_up_dq         : std_logic;
  signal dbg_idel_down_dq       : std_logic;
  signal dbg_idel_up_dqs        : std_logic;
  signal dbg_idel_down_dqs      : std_logic;
  signal dbg_idel_up_gate       : std_logic;
  signal dbg_idel_down_gate     : std_logic;
  signal dbg_sel_idel_dq        : std_logic_vector(DQ_BITS-1 downto 0);
  signal dbg_sel_all_idel_dq    : std_logic;
  signal dbg_sel_idel_dqs       : std_logic_vector(DQS_BITS downto 0);
  signal dbg_sel_all_idel_dqs   : std_logic;
  signal dbg_sel_idel_gate      : std_logic_vector(DQS_BITS downto 0);
  signal dbg_sel_all_idel_gate  : std_logic;
  signal dbg_calib_done         : std_logic_vector(3 downto 0);
  signal dbg_calib_err          : std_logic_vector(3 downto 0);
  signal dbg_calib_dq_tap_cnt   : std_logic_vector((6*DQ_WIDTH)-1 downto 0);
  signal dbg_calib_dqs_tap_cnt  : std_logic_vector((6*DQS_WIDTH)-1 downto 0);
  signal dbg_calib_gate_tap_cnt : std_logic_vector((6*DQS_WIDTH)-1 downto 0);
  signal dbg_calib_rd_data_sel  : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal dbg_calib_rden_dly     : std_logic_vector((5*DQS_WIDTH)-1 downto 0);
  signal dbg_calib_gate_dly     : std_logic_vector((5*DQS_WIDTH)-1 downto 0);

-- PHY Debug Port demo
  signal cs_control0: std_logic_vector(35 downto 0);
  signal cs_control1: std_logic_vector(35 downto 0);
  signal cs_control2: std_logic_vector(35 downto 0);
  signal cs_control3: std_logic_vector(35 downto 0);
  signal ila2_data: std_logic_vector(159 downto 0);
  signal ila2_trig: std_logic_vector(7 downto 0);
  signal vio0_in: std_logic_vector(255 downto 0);
  signal vio1_in: std_logic_vector(63 downto 0);
  signal vio3_out: std_logic_vector(31 downto 0);
  signal firstWr : std_logic;
  
		component icon4 
		port 
		(
			control0 : inout std_logic_vector(35 downto 0);
			control1 : inout std_logic_vector(35 downto 0);
			control2 : inout std_logic_vector(35 downto 0);
			control3 : inout std_logic_vector(35 downto 0) 
		);
		end component;
		
		
		component vio_async_in256 
		port 
		(
			control  : inout std_logic_vector(35 downto 0);
			async_in : in std_logic_vector(255 downto 0) 
		);
		end component;
		
		component vio_async_in64
		port 
		(
			control  : inout std_logic_vector(35 downto 0);
			async_in : in std_logic_vector(63 downto 0) 
		);
		end component;
		
		component ila160_8
		port 
		(
			control : inout std_logic_vector(35 downto 0);
			clk     : in std_logic;
			data    : in std_logic_vector(159 downto 0);
			trig0   : in std_logic_vector(7 downto 0) 
		);
		end component;
		
		component vio_sync_out32
		port 
		(
			control  : inout std_logic_vector(35 downto 0);
			clk      : in std_logic;
			sync_out : out std_logic_vector(31 downto 0) 
		);  
		end component;

begin

  --***************************************************************************
  rst0_tb <= rst0;
  clk0_tb <= clk0;
  phy_init_done   <= i_phy_init_done;

  u_idelay_ctrl : mig20_idelay_ctrl
    port map (
      rst200                => rst200,
      clk200                => clk200,
      idelay_ctrl_rdy       => idelay_ctrl_rdy
      );

  u_infrastructure : mig20_infrastructure
    generic map (
      CLK_PERIOD            => CLK_PERIOD,
      RST_ACT_LOW           => RST_ACT_LOW,
      DLL_FREQ_MODE         => DLL_FREQ_MODE
      )
    port map (
      --sys_clk_p             => sys_clk_p,
      --sys_clk_n             => sys_clk_n,
      --clk200_p              => clk200_p,
      --clk200_n              => clk200_n,
	  sys_clk_i				=> sys_clk_i,
	  clk200_i				=> clk200_i,
	  dcmClkInLock 			=> dcmClkInLock,
      sys_rst_n             => sys_rst_n,
      rst0                  => rst0,
      rst90                 => rst90,
      rst200                => rst200,
      rstdiv0               => rstdiv0,
      clk0                  => clk0,
      clk90                 => clk90,
      clk200                => clk200,
      clkdiv0               => clkdiv0,
      idelay_ctrl_rdy       => idelay_ctrl_rdy
      );

  u_ddr2_top_0 : mig20_ddr2_top_0
    generic map (
      BANK_WIDTH            => BANK_WIDTH,
      CKE_WIDTH             => CKE_WIDTH,
      CLK_WIDTH             => CLK_WIDTH,
      COL_WIDTH             => COL_WIDTH,
      CS_NUM                => CS_NUM,
      CS_WIDTH              => CS_WIDTH,
      CS_BITS               => CS_BITS,
      DM_WIDTH              => DM_WIDTH,
      DQ_WIDTH              => DQ_WIDTH,
      DQ_PER_DQS            => DQ_PER_DQS,
      DQS_WIDTH             => DQS_WIDTH,
      DQ_BITS               => DQ_BITS,
      DQS_BITS              => DQS_BITS,
      ODT_WIDTH             => ODT_WIDTH,
      ROW_WIDTH             => ROW_WIDTH,
      ADDITIVE_LAT          => ADDITIVE_LAT,
      BURST_LEN             => BURST_LEN,
      BURST_TYPE            => BURST_TYPE,
      CAS_LAT               => CAS_LAT,
      ECC_ENABLE            => ECC_ENABLE,
      APPDATA_WIDTH         => APPDATA_WIDTH,
      MULTI_BANK_EN         => MULTI_BANK_EN,
      TWO_T_TIME_EN         => TWO_T_TIME_EN,
      ODT_TYPE              => ODT_TYPE,
      REDUCE_DRV            => REDUCE_DRV,
      REG_ENABLE            => REG_ENABLE,
      TREFI_NS              => TREFI_NS,
      TRAS                  => TRAS,
      TRCD                  => TRCD,
      TRFC                  => TRFC,
      TRP                   => TRP,
      TRTP                  => TRTP,
      TWR                   => TWR,
      TWTR                  => TWTR,
      SIM_ONLY              => SIM_ONLY,
      DEBUG_EN              => DEBUG_EN,
      DQS_IO_COL            => DQS_IO_COL,
      DQ_IO_MS              => DQ_IO_MS,
      CLK_PERIOD            => CLK_PERIOD
      )
    port map (
      ddr2_dq               => ddr2_dq,
      ddr2_a                => ddr2_a,
      ddr2_ba               => ddr2_ba,
      ddr2_ras_n            => ddr2_ras_n,
      ddr2_cas_n            => ddr2_cas_n,
      ddr2_we_n             => ddr2_we_n,
      ddr2_cs_n             => ddr2_cs_n,
      ddr2_odt              => ddr2_odt,
      ddr2_cke              => ddr2_cke,
      ddr2_dm               => ddr2_dm,
      phy_init_done         => i_phy_init_done,
      rst0                  => rst0,
      rst90                 => rst90,
      rstdiv0               => rstdiv0,
      clk0                  => clk0,
      clk90                 => clk90,
      clkdiv0               => clkdiv0,
      app_wdf_afull         => app_wdf_afull_x,
      app_af_afull          => app_af_afull_x,
      rd_data_valid         => rd_data_valid_x,
      app_wdf_wren          => app_wdf_wren,
      app_af_wren           => app_af_wren,
      app_af_addr           => app_af_addr,
      app_af_cmd            => app_af_cmd,
      rd_data_fifo_out      => rd_data_fifo_out_x,
      app_wdf_data          => app_wdf_data,
      app_wdf_mask_data     => app_wdf_mask_data,
      ddr2_dqs              => ddr2_dqs,
      ddr2_dqs_n            => ddr2_dqs_n,
      ddr2_ck               => ddr2_ck,
      rd_ecc_error          => open,
      ddr2_ck_n             => ddr2_ck_n,

      dbg_idel_up_all        => dbg_idel_up_all,
      dbg_idel_down_all      => dbg_idel_down_all,
      dbg_idel_up_dq         => dbg_idel_up_dq,
      dbg_idel_down_dq       => dbg_idel_down_dq,
      dbg_idel_up_dqs        => dbg_idel_up_dqs,
      dbg_idel_down_dqs      => dbg_idel_down_dqs,
      dbg_idel_up_gate       => dbg_idel_up_gate,
      dbg_idel_down_gate     => dbg_idel_down_gate,
      dbg_sel_idel_dq        => dbg_sel_idel_dq,
      dbg_sel_all_idel_dq    => dbg_sel_all_idel_dq,
      dbg_sel_idel_dqs       => dbg_sel_idel_dqs,
      dbg_sel_all_idel_dqs   => dbg_sel_all_idel_dqs,
      dbg_sel_idel_gate      => dbg_sel_idel_gate,
      dbg_sel_all_idel_gate  => dbg_sel_all_idel_gate,
      dbg_calib_done         => dbg_calib_done,
      dbg_calib_err          => dbg_calib_err,
      dbg_calib_dq_tap_cnt   => dbg_calib_dq_tap_cnt,
      dbg_calib_dqs_tap_cnt  => dbg_calib_dqs_tap_cnt,
      dbg_calib_gate_tap_cnt => dbg_calib_gate_tap_cnt,
      dbg_calib_rd_data_sel  => dbg_calib_rd_data_sel,
      dbg_calib_rden_dly     => dbg_calib_rden_dly,
      dbg_calib_gate_dly     => dbg_calib_gate_dly
      );

app_wdf_afull <=   app_wdf_afull_x;
app_af_afull <=     app_af_afull_x;
rd_data_valid    <= rd_data_valid_x;
rd_data_fifo_out <= rd_data_fifo_out_x;


  --*****************************************************************
  -- Hooks to prevent sim/syn compilation errors (mainly for VHDL - but
  -- keep it also in Verilog version of code) w/ floating inputs if
  -- DEBUG_EN = 0.
  --*****************************************************************

  gen_dbg_tie_off: if (DEBUG_EN = 0) generate
    dbg_idel_up_all       <= '0';
    dbg_idel_down_all     <= '0';
    dbg_idel_up_dq        <= '0';
    dbg_idel_down_dq      <= '0';
    dbg_idel_up_dqs       <= '0';
    dbg_idel_down_dqs     <= '0';
    dbg_idel_up_gate      <= '0';
    dbg_idel_down_gate    <= '0';
    dbg_sel_idel_dq       <= (others => '0');
    dbg_sel_all_idel_dq   <= '0';
    dbg_sel_idel_dqs      <= (others => '0');
    dbg_sel_all_idel_dqs  <= '0';
    dbg_sel_idel_gate     <= (others => '0');
    dbg_sel_all_idel_gate <= '0';
  end generate;

 --*****************************************************************
  -- PHY Debug Port demo - see XAPP858 or Answer Record 29443
  -- NOTES:
  --   1. PHY Debug Port demo connects to 4 chipscope elements:
  --     - 2 VIO modules with only asynchronous inputs
  --      * Monitor IDELAY taps, calibration status
  --     - 1 VIO module with synchronous outputs
  --      * Allow dynamic adjustment of IDELAY taps
  --     - 1 ILA (technically not part of the PHY Debug Port, but
  --       included for illustrative purposes) monitoring User I/F
  --       bus (reads, writes, error)
  --*****************************************************************
	
	gen_dbg_cs : if (DEBUG_EN = 1) generate
	  
		u_icon : icon4 
		port map
		(
			control0 => cs_control0,
			control1 => cs_control1,
			control2 => cs_control2,
			control3 => cs_control3
		);
		
		-- VIO async inputs: Display all IDELAY taps ((32+4+4)x6 = 240 bits)
		u_vio0 : vio_async_in256 
		port map
		(
			control  => cs_control0,
			async_in => vio0_in
		);
		
		-- VIO async inputs: Display other calibration results/status, error signal
		u_vio1 : vio_async_in64
		port map
		(
			control  => cs_control1,
			async_in => vio1_in
		);
		
		-- Display User I/F bus
		u_ila2 : ila160_8
		port map
		(
			control => cs_control2,
			clk     => clk0,
			data    => ila2_data,
			trig0   => ila2_trig
		);
		
		-- VIO sync output: Change IDELAY taps
		u_vio3 : vio_sync_out32
		port map
		(
			control  => cs_control3,
			clk      => clkdiv0,
			sync_out => vio3_out
		);
	
	  --*****************************************************************
	  -- Bit assignments:
	  -- NOTE: Note all VIO, ILA inputs/outputs used  
	  --*****************************************************************
	
		vio0_in(191 downto 0)   <= dbg_calib_dq_tap_cnt(191 downto 0); -- 6 * 32
		vio0_in(215 downto 192) <= dbg_calib_dqs_tap_cnt(23 downto 0); -- 6 * 4
		vio0_in(239 downto 216) <= dbg_calib_gate_tap_cnt(23 downto 0); -- 6 * 4
--		vio0_in(255 downto 240)	<= (others => '0');
		
		vio1_in(3 downto 0)     <= dbg_calib_done;
			--Each bit is driven to a static 1 as each stage of calibration
			--is completed.
			--CALIB_DONE[0] corresponds to Stage 1.	  
			
		vio1_in(7 downto 4)     <= dbg_calib_err;
			--Asserted when an error detected during calibration during
			--stages 3 and/or 4. Note that this appears as a 4-bit bus in
			--the HDL; however, only bits [3:2] are used
			--(CALIB_ERR[2] corresponds to stage 3). Stages 1 and 2
			--do not have error signals.
--				vio1_in(14 downto 12) <= (others => '0');
		vio1_in(11 downto 8)    <= dbg_calib_rd_data_sel(3 downto 0);
		-- was 12 downto 8
--		vio1_in(14 downto 12) <= (others => '0');
		vio1_in(15)      <= '0';  
--		vio1_in(19 downto 16) <= (others => '0');
		vio1_in(39 downto 20)   <= dbg_calib_rden_dly(19 downto 0); -- 5 * 4
		vio1_in(59 downto 40)   <= dbg_calib_gate_dly(19 downto 0); -- 
--		vio1_in(63 downto 60) <= (others => '0');	
	
	  ila2_data(63 downto 0)   <= rd_data_fifo_out_x(63 downto 0);
	  ila2_data(127 downto 64)   <= app_wdf_data;
	  ila2_data(128)    <= rd_data_valid_x;
	  ila2_data(129)    <= '0';
	  ila2_data(130)    <= '0';
	  ila2_data(131)       <= app_wdf_afull_x;
       ila2_data(132)          <= app_af_afull_x;
       ila2_data(133)          <= app_wdf_wren;
       ila2_data(134)           <= app_af_wren;
	   ila2_data(137 downto 135)  <= app_af_cmd;
       ila2_data(158 downto 138)  <= app_af_addr(20 downto 0);
	   ila2_data(159) <= firstWr;
       


	  -- Trigger for ILA
	  ila2_trig(0)     <= '0';
	  ila2_trig(1)     <= '0';
	  ila2_trig(2)		<= firstWr;
	  ila2_trig(7 downto 3)   <= "00000";
	
	  dbg_idel_up_all           <= vio3_out(0);
	  dbg_idel_down_all         <= vio3_out(1);
	  dbg_idel_up_dq            <= vio3_out(2);
	  dbg_idel_down_dq          <= vio3_out(3);
	  dbg_idel_up_dqs           <= vio3_out(4);
	  dbg_idel_down_dqs         <= vio3_out(5);
	  dbg_idel_up_gate          <= vio3_out(6);
	  dbg_idel_down_gate        <= vio3_out(7);
	  dbg_sel_idel_dq(4 downto 0)      <= vio3_out(12 downto 8);
	  dbg_sel_all_idel_dq       <= vio3_out(15);
	  dbg_sel_idel_dqs(2 downto 0)     <= vio3_out(18 downto 16);
	  dbg_sel_all_idel_dqs      <= vio3_out(19);
	  dbg_sel_idel_gate(2 downto 0)    <= vio3_out(22 downto 20);
	  dbg_sel_all_idel_gate     <= vio3_out(23);
  end generate;

end architecture arc_mem_interface_top;
