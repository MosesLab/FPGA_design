--*****************************************************************************
-- Copyright (c) 2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, Inc.
-- All Rights Reserved
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: $Name: i+IP+131489 $
--  \   \         Application: MIG
--  /   /         Filename: mig20_ddr2_top_0.vhd
-- /___/   /\     Date Last Modified: $Date: 2007/09/21 15:23:31 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   System level module. This level contains just the memory controller.
--   This level will be intiantated when the user wants to remove the
--   synthesizable test bench, IDELAY control block and the clock
--   generation modules.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity mig20_ddr2_top_0 is
  generic (
    BANK_WIDTH    : integer := 2;      -- # of memory bank addr bits
    CKE_WIDTH     : integer := 1;      -- # of memory clock enable outputs
    CLK_WIDTH     : integer := 2;      -- # of clock outputs
    COL_WIDTH     : integer := 10;     -- # of memory column bits
    CS_NUM        : integer := 1;      -- # of separate memory chip selects
    CS_BITS       : integer := 0;      -- set to log2(CS_NUM) (rounded up)
    CS_WIDTH      : integer := 2;      -- # of total memory chip selects
    DM_WIDTH      : integer := 4;      -- # of data mask bits
    DQ_WIDTH      : integer := 32;    -- # of data width
    DQ_BITS       : integer := 5;      -- set to log2(DQS_WIDTH*DQ_PER_DQS)
    DQ_PER_DQS    : integer := 8;      -- # of DQ data bits per strobe
    DQS_WIDTH     : integer := 4;      -- # of DQS strobes
    DQS_BITS      : integer := 2;      -- set to log2(DQS_WIDTH)
    ODT_WIDTH     : integer := 2;      -- # of memory on-die term enables
    ROW_WIDTH     : integer := 13;     -- # of memory row & # of addr bits
    APPDATA_WIDTH : integer := 64;     -- # of read/write data bus bits
    ADDITIVE_LAT  : integer := 0;      -- additive write latency
    BURST_LEN     : integer := 4;      -- burst length (in double words)
    BURST_TYPE    : integer := 0;      -- burst type (=0 seq; =1 interlved)
    CAS_LAT       : integer := 3;      -- CAS latency
    ECC_ENABLE    : integer := 0;      -- enable ECC (=1 enable)
    ODT_TYPE      : integer := 3;      -- ODT (=0(none),=1(75),=2(150),=3(50))
    MULTI_BANK_EN : integer := 1;      -- enable bank management
    TWO_T_TIME_EN : integer := 0;       -- 2t timing for unbuffered dimms
    REDUCE_DRV    : integer := 0;      -- reduced strength mem I/O (=1 yes)
    REG_ENABLE    : integer := 0;      -- registered addr/ctrl (=1 yes)
    TREFI_NS      : integer := 7800;   -- auto refresh interval (ns)
    TRAS          : integer := 40000;  -- active->precharge delay
    TRCD          : integer := 15000;  -- active->read/write delay
    TRFC          : integer := 105000; -- ref->ref, ref->active delay
    TRP           : integer := 15000;  -- precharge->command delay
    TRTP          : integer := 7500;   -- read->precharge delay
    TWR           : integer := 15000;  -- used to determine wr->prech
    TWTR          : integer := 7500;  -- write->read delay
    CLK_PERIOD    : integer := 5000;   -- Core/Mem clk period (in ps)
    SIM_ONLY      : integer := 0;       -- = 1 to skip power up delay
    DEBUG_EN      : integer := 0;       -- Enable debug signals/controls
    DQS_IO_COL    : bit_vector := "0";  -- I/O column location of DQS groups
    DQ_IO_MS      : bit_vector := "0"   -- Master/Slave location of DQ I/O
    );
  port (
    clk0                   : in    std_logic;
    clk90                  : in    std_logic;
    clkdiv0                : in    std_logic;
    rst0                   : in    std_logic;
    rst90                  : in    std_logic;
    rstdiv0                : in    std_logic;
    app_af_cmd             : in    std_logic_vector(2 downto 0);
    app_af_addr            : in    std_logic_vector(30 downto 0);
    app_af_wren            : in    std_logic;
    app_wdf_wren           : in    std_logic;
    app_wdf_data           : in    std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data      : in    std_logic_vector((APPDATA_WIDTH/8)-1
                                                    downto 0);
    app_af_afull           : out   std_logic;
    app_wdf_afull          : out   std_logic;
    rd_data_valid          : out   std_logic;
    rd_data_fifo_out       : out   std_logic_vector(APPDATA_WIDTH-1 downto 0);
    rd_ecc_error           : out   std_logic_vector(1 downto 0);
    phy_init_done          : out   std_logic;
    ddr2_ck                : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr2_ck_n              : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr2_a                 : out   std_logic_vector(ROW_WIDTH-1 downto 0);
    ddr2_ba                : out   std_logic_vector(BANK_WIDTH-1 downto 0);
    ddr2_ras_n             : out   std_logic;
    ddr2_cas_n             : out   std_logic;
    ddr2_we_n              : out   std_logic;
    ddr2_cs_n              : out   std_logic_vector(CS_WIDTH-1 downto 0);
    ddr2_cke               : out   std_logic_vector(CKE_WIDTH-1 downto 0);
    ddr2_odt               : out   std_logic_vector(ODT_WIDTH-1 downto 0);
    ddr2_dm                : out   std_logic_vector(DM_WIDTH-1 downto 0);
    ddr2_dqs               : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr2_dqs_n             : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr2_dq                : inout std_logic_vector(DQ_WIDTH-1 downto 0);
    -- Debug signals (optional use)
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
    dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH-1 downto 0);
    dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0)
    );
end entity mig20_ddr2_top_0;

architecture syn of mig20_ddr2_top_0 is

  component mig20_mem_if_top_0
    generic (
      BANK_WIDTH    : integer;
      CKE_WIDTH     : integer;
      CLK_WIDTH     : integer;
      COL_WIDTH     : integer;
      CS_BITS       : integer;
      CS_NUM        : integer;
      CS_WIDTH      : integer;
      DM_WIDTH      : integer;
      DQ_WIDTH      : integer;
      DQ_BITS       : integer;
      DQ_PER_DQS    : integer;
      DQS_BITS      : integer;
      DQS_WIDTH     : integer;
      ODT_WIDTH     : integer;
      ROW_WIDTH     : integer;
      APPDATA_WIDTH : integer;
      ADDITIVE_LAT  : integer;
      BURST_LEN     : integer;
      BURST_TYPE    : integer;
      CAS_LAT       : integer;
      ECC_ENABLE    : integer;
      MULTI_BANK_EN : integer;
      TWO_T_TIME_EN : integer;
      ODT_TYPE      : integer;
      DDR_TYPE      : integer;
      REDUCE_DRV    : integer;
      REG_ENABLE    : integer;
      TREFI_NS      : integer;
      TRAS          : integer;
      TRCD          : integer;
      TRFC          : integer;
      TRP           : integer;
      TRTP          : integer;
      TWR           : integer;
      TWTR          : integer;
      CLK_PERIOD    : integer;
      SIM_ONLY      : integer;
      DEBUG_EN      : integer;
      DQS_IO_COL    : bit_vector;
      DQ_IO_MS      : bit_vector);
    port (
      clk0                   : in    std_logic;
      clk90                  : in    std_logic;
      clkdiv0                : in    std_logic;
      rst0                   : in    std_logic;
      rst90                  : in    std_logic;
      rstdiv0                : in    std_logic;
      app_af_cmd             : in    std_logic_vector(2 downto 0);
      app_af_addr            : in    std_logic_vector(30 downto 0);
      app_af_wren            : in    std_logic;
      app_wdf_wren           : in    std_logic;
      app_wdf_data           : in    std_logic_vector(APPDATA_WIDTH-1
                                                      downto 0);
      app_wdf_mask_data      : in    std_logic_vector((APPDATA_WIDTH/8)-1
                                                      downto 0);
      rd_ecc_error           : out   std_logic_vector(1 downto 0);
      app_af_afull           : out   std_logic;
      app_wdf_afull          : out   std_logic;
      rd_data_valid          : out   std_logic;
      rd_data_fifo_out       : out   std_logic_vector(APPDATA_WIDTH-1
                                                      downto 0);
      phy_init_done          : out   std_logic;
      ddr_ck                 : out   std_logic_vector(CLK_WIDTH-1 downto 0);
      ddr_ck_n               : out   std_logic_vector(CLK_WIDTH-1 downto 0);
      ddr_addr               : out   std_logic_vector(ROW_WIDTH-1 downto 0);
      ddr_ba                 : out   std_logic_vector(BANK_WIDTH-1 downto 0);
      ddr_ras_n              : out   std_logic;
      ddr_cas_n              : out   std_logic;
      ddr_we_n               : out   std_logic;
      ddr_cs_n               : out   std_logic_vector(CS_WIDTH-1 downto 0);
      ddr_cke                : out   std_logic_vector(CKE_WIDTH-1 downto 0);
      ddr_odt                : out   std_logic_vector(ODT_WIDTH-1 downto 0);
      ddr_dm                 : out   std_logic_vector(DM_WIDTH-1 downto 0);
      ddr_dqs                : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr_dqs_n              : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr_dq                 : inout std_logic_vector(DQ_WIDTH-1 downto 0);
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
                                                      downto 0));
  end component;

begin

  -- memory initialization/control logic
  u_mem_if_top_0 : mig20_mem_if_top_0
    generic map (
      BANK_WIDTH     => BANK_WIDTH,
      CKE_WIDTH      => CKE_WIDTH,
      CLK_WIDTH      => CLK_WIDTH,
      COL_WIDTH      => COL_WIDTH,
      CS_BITS        => CS_BITS,
      CS_NUM         => CS_NUM,
      CS_WIDTH       => CS_WIDTH,
      DM_WIDTH       => DM_WIDTH,
      DQ_WIDTH       => DQ_WIDTH,
      DQ_BITS        => DQ_BITS,
      DQ_PER_DQS     => DQ_PER_DQS,
      DQS_BITS       => DQS_BITS,
      DQS_WIDTH      => DQS_WIDTH,
      ODT_WIDTH      => ODT_WIDTH,
      ROW_WIDTH      => ROW_WIDTH,
      APPDATA_WIDTH  => APPDATA_WIDTH,
      ADDITIVE_LAT   => ADDITIVE_LAT,
      BURST_LEN      => BURST_LEN,
      BURST_TYPE     => BURST_TYPE,
      CAS_LAT        => CAS_LAT,
      ECC_ENABLE     => ECC_ENABLE,
      MULTI_BANK_EN  => MULTI_BANK_EN,
      TWO_T_TIME_EN  => TWO_T_TIME_EN,
      ODT_TYPE       => ODT_TYPE,
      DDR_TYPE       => 1,
      REDUCE_DRV     => REDUCE_DRV,
      REG_ENABLE     => REG_ENABLE,
      TREFI_NS       => TREFI_NS,
      TRAS           => TRAS,
      TRCD           => TRCD,
      TRFC           => TRFC,
      TRP            => TRP,
      TRTP           => TRTP,
      TWR            => TWR,
      TWTR           => TWTR,
      CLK_PERIOD     => CLK_PERIOD,
      SIM_ONLY       => SIM_ONLY,
      DEBUG_EN       => DEBUG_EN,
      DQS_IO_COL     => DQS_IO_COL,
      DQ_IO_MS       => DQ_IO_MS
      )
    port map (
      clk0                    => clk0,
      clk90                   => clk90,
      clkdiv0                 => clkdiv0,
      rst0                    => rst0,
      rst90                   => rst90,
      rstdiv0                 => rstdiv0,
      app_af_cmd              => app_af_cmd,
      app_af_addr             => app_af_addr,
      app_af_wren             => app_af_wren,
      app_wdf_wren            => app_wdf_wren,
      app_wdf_data            => app_wdf_data,
      app_wdf_mask_data       => app_wdf_mask_data,
      app_af_afull            => app_af_afull,
      app_wdf_afull           => app_wdf_afull,
      rd_data_valid           => rd_data_valid,
      rd_data_fifo_out        => rd_data_fifo_out,
      rd_ecc_error            => rd_ecc_error,
      phy_init_done           => phy_init_done,
      ddr_ck                  => ddr2_ck,
      ddr_ck_n                => ddr2_ck_n,
      ddr_addr                => ddr2_a,
      ddr_ba                  => ddr2_ba,
      ddr_ras_n               => ddr2_ras_n,
      ddr_cas_n               => ddr2_cas_n,
      ddr_we_n                => ddr2_we_n,
      ddr_cs_n                => ddr2_cs_n,
      ddr_cke                 => ddr2_cke,
      ddr_odt                 => ddr2_odt,
      ddr_dm                  => ddr2_dm,
      ddr_dqs                 => ddr2_dqs,
      ddr_dqs_n               => ddr2_dqs_n,
      ddr_dq                  => ddr2_dq,
      dbg_idel_up_all         => dbg_idel_up_all,
      dbg_idel_down_all       => dbg_idel_down_all,
      dbg_idel_up_dq          => dbg_idel_up_dq,
      dbg_idel_down_dq        => dbg_idel_down_dq,
      dbg_idel_up_dqs         => dbg_idel_up_dqs,
      dbg_idel_down_dqs       => dbg_idel_down_dqs,
      dbg_idel_up_gate        => dbg_idel_up_gate,
      dbg_idel_down_gate      => dbg_idel_down_gate,
      dbg_sel_idel_dq         => dbg_sel_idel_dq,
      dbg_sel_all_idel_dq     => dbg_sel_all_idel_dq,
      dbg_sel_idel_dqs        => dbg_sel_idel_dqs,
      dbg_sel_all_idel_dqs    => dbg_sel_all_idel_dqs,
      dbg_sel_idel_gate       => dbg_sel_idel_gate,
      dbg_sel_all_idel_gate   => dbg_sel_all_idel_gate,
      dbg_calib_done          => dbg_calib_done,
      dbg_calib_err           => dbg_calib_err,
      dbg_calib_dq_tap_cnt    => dbg_calib_dq_tap_cnt,
      dbg_calib_dqs_tap_cnt   => dbg_calib_dqs_tap_cnt,
      dbg_calib_gate_tap_cnt  => dbg_calib_gate_tap_cnt,
      dbg_calib_rd_data_sel   => dbg_calib_rd_data_sel,
      dbg_calib_rden_dly      => dbg_calib_rden_dly,
      dbg_calib_gate_dly      => dbg_calib_gate_dly
      );

end architecture syn;



