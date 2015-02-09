--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2006 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- The following code must appear in the VHDL architecture header:

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG

component mig20
 generic(
     BANK_WIDTH           : BANK_WIDTH;    -- # of memory bank addr bits
     CKE_WIDTH            : CKE_WIDTH;    -- # of memory clock enable outputs
     CLK_WIDTH            : CLK_WIDTH;    -- # of clock outputs
     COL_WIDTH            : COL_WIDTH;    -- # of memory column bits
     CS_NUM               : CS_NUM;    -- # of separate memory chip selects
     CS_WIDTH             : CS_WIDTH;    -- # of total memory chip selects
     CS_BITS              : CS_BITS;    -- set to log2(CS_NUM) (rounded up)
     DM_WIDTH             : DM_WIDTH;    -- # of data mask bits
     DQ_WIDTH             : DQ_WIDTH;    -- # of data width
     DQ_PER_DQS           : DQ_PER_DQS;    -- # of DQ data bits per strobe
     DQS_WIDTH            : DQS_WIDTH;    -- # of DQS strobes
     DQ_BITS              : DQ_BITS;    -- set to log2(DQS_WIDTH*DQ_PER_DQS)
     DQS_BITS             : DQS_BITS;    -- set to log2(DQS_WIDTH)
     ODT_WIDTH            : ODT_WIDTH;    -- # of memory on-die term enables
     ROW_WIDTH            : ROW_WIDTH;    -- # of memory row and # of addr bits
     ADDITIVE_LAT         : ADDITIVE_LAT;    -- additive write latency 
     BURST_LEN            : BURST_LEN;    -- burst length (in double words)
     BURST_TYPE           : BURST_TYPE;    -- burst type (=0 seq; =1 interleaved)
     CAS_LAT              : CAS_LAT;    -- CAS latency
     ECC_ENABLE           : ECC_ENABLE;    -- enable ECC (=1 enable)
     APPDATA_WIDTH        : APPDATA_WIDTH;    -- # of usr read/write data bus bits
     MULTI_BANK_EN        : MULTI_BANK_EN;    -- Keeps multiple banks open. (= 1 enable)
     TWO_T_TIME_EN        : TWO_T_TIME_EN;    -- 2t timing for unbuffered dimms
     ODT_TYPE             : ODT_TYPE;    -- ODT (=0(none),=1(75),=2(150),=3(50))
     REDUCE_DRV           : REDUCE_DRV;    -- reduced strength mem I/O (=1 yes)
     REG_ENABLE           : REG_ENABLE;    -- registered addr/ctrl (=1 yes)
     TREFI_NS             : TREFI_NS;    -- auto refresh interval (ns)
     TRAS                 : TRAS;    -- active->precharge delay
     TRCD                 : TRCD;    -- active->read/write delay
     TRFC                 : TRFC;    -- refresh->refresh, refresh->active delay
     TRP                  : TRP;    -- precharge->command delay
     TRTP                 : TRTP;    -- read->precharge delay
     TWR                  : TWR;    -- used to determine write->precharge
     TWTR                 : TWTR;    -- write->read delay
     SIM_ONLY             : SIM_ONLY;    -- = 1 to skip SDRAM power up delay
     DEBUG_EN             : DEBUG_EN;    -- Enable debug signals/controls
     DQS_IO_COL           : DQS_IO_COL;    -- I/O column location of DQS groups (=0, left; =1 center, =2 right)
     DQ_IO_MS             : DQ_IO_MS;    -- Master/Slave location of DQ I/O (=0 slave) 
     CLK_PERIOD           : CLK_PERIOD;    -- Core/Memory clock period (in ps)
     RST_ACT_LOW          : RST_ACT_LOW;    -- =1 for active low reset, =0 for active high
     DLL_FREQ_MODE        : DLL_FREQ_MODE     -- DCM Frequency range
)
    port (
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
   sys_clk_p             : in    std_logic;
   sys_clk_n             : in    std_logic;
   clk200_p              : in    std_logic;
   clk200_n              : in    std_logic;
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
end component;

-- Synplicity black box declaration
attribute syn_black_box : boolean;
attribute syn_black_box of mig20: component is true;

-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
  u_mig20 : mig20
    generic map (
     BANK_WIDTH => 2,
     CKE_WIDTH => 1,
     CLK_WIDTH => 2,
     COL_WIDTH => 10,
     CS_NUM => 1,
     CS_WIDTH => 2,
     CS_BITS => 0,
     DM_WIDTH => 4,
     DQ_WIDTH => 32,
     DQ_PER_DQS => 8,
     DQS_WIDTH => 4,
     DQ_BITS => 5,
     DQS_BITS => 2,
     ODT_WIDTH => 2,
     ROW_WIDTH => 13,
     ADDITIVE_LAT => 0,
     BURST_LEN => 4,
     BURST_TYPE => 0,
     CAS_LAT => 3,
     ECC_ENABLE => 0,
     APPDATA_WIDTH => 64,
     MULTI_BANK_EN => 1,
     TWO_T_TIME_EN => 0,
     ODT_TYPE => 3,
     REDUCE_DRV => 0,
     REG_ENABLE => 0,
     TREFI_NS => 7800,
     TRAS => 40000,
     TRCD => 15000,
     TRFC => 105000,
     TRP => 15000,
     TRTP => 7500,
     TWR => 15000,
     TWTR => 7500,
     SIM_ONLY => 0,
     DEBUG_EN => 0,
     DQS_IO_COL => "10000000",
     DQ_IO_MS => "10100101101001011010010110100101",
     CLK_PERIOD => 5000,
     RST_ACT_LOW => 1,
     DLL_FREQ_MODE => "HIGH"
)
    port map (
   ddr2_dq => ddr2_dq,
   ddr2_a => ddr2_a,
   ddr2_ba => ddr2_ba,
   ddr2_ras_n => ddr2_ras_n,
   ddr2_cas_n => ddr2_cas_n,
   ddr2_we_n => ddr2_we_n,
   ddr2_cs_n => ddr2_cs_n,
   ddr2_odt => ddr2_odt,
   ddr2_cke => ddr2_cke,
   ddr2_dm => ddr2_dm,
   sys_clk_p => sys_clk_p,
   sys_clk_n => sys_clk_n,
   clk200_p => clk200_p,
   clk200_n => clk200_n,
   sys_rst_n => sys_rst_n,
   phy_init_done => phy_init_done,
   rst0_tb => rst0_tb,
   clk0_tb => clk0_tb,
   app_wdf_afull => app_wdf_afull,
   app_af_afull => app_af_afull,
   rd_data_valid => rd_data_valid,
   app_wdf_wren => app_wdf_wren,
   app_af_wren => app_af_wren,
   app_af_addr => app_af_addr,
   app_af_cmd => app_af_cmd,
   rd_data_fifo_out => rd_data_fifo_out,
   app_wdf_data => app_wdf_data,
   app_wdf_mask_data => app_wdf_mask_data,
   ddr2_dqs => ddr2_dqs,
   ddr2_dqs_n => ddr2_dqs_n,
   ddr2_ck => ddr2_ck,
   ddr2_ck_n => ddr2_ck_n
);

-- INST_TAG_END ------ End INSTANTIATION Template ------------

-- You must compile the wrapper file mig20.vhd when simulating
-- the core, mig20. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

