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
--  /   /         Filename: mig20_usr_top_0.vhd
-- /___/   /\     Date Last Modified: $Date: 2007/09/21 15:23:31 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module interfaces with the user. The user should provide the data
--   and various commands.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity mig20_usr_top_0 is
  generic (
    BANK_WIDTH         :     integer := 2;
    CS_BITS            :     integer := 0;
    COL_WIDTH          :     integer := 10;
    DQ_WIDTH           :     integer := 32;
    DQ_PER_DQS         :     integer := 8;
    ECC_ENABLE         :     integer := 0;
    APPDATA_WIDTH      :     integer := 64;
    DQS_WIDTH          :     integer := 4;
    ROW_WIDTH          :     integer := 13
    );
  port (
    clk0               : in  std_logic;
    clk90              : in  std_logic;
    rst0               : in  std_logic;
    rd_data_in_rise    : in  std_logic_vector(DQ_WIDTH-1 downto 0);
    rd_data_in_fall    : in  std_logic_vector(DQ_WIDTH-1 downto 0);
    phy_calib_rden     : in  std_logic_vector(DQS_WIDTH-1 downto 0);
    phy_calib_rden_sel : in  std_logic_vector(DQS_WIDTH-1 downto 0);
    rd_data_valid      : out std_logic;
    rd_data_fifo_out   : out std_logic_vector((APPDATA_WIDTH)-1 downto 0);
    app_af_cmd         : in  std_logic_vector(2 downto 0);
    app_af_addr        : in  std_logic_vector(30 downto 0);
    app_af_wren        : in  std_logic;
    ctrl_af_rden       : in  std_logic;
    af_cmd             : out std_logic_vector(2 downto 0);
    af_addr            : out std_logic_vector(30 downto 0);
    af_empty           : out std_logic;
    app_af_afull       : out std_logic;
    rd_ecc_error       : out std_logic_vector(1 downto 0);
    app_wdf_wren       : in  std_logic;
    app_wdf_data       : in  std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data  : in  std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
    wdf_rden           : in  std_logic;
    app_wdf_afull      : out std_logic;
    wdf_data           : out std_logic_vector((2*DQ_WIDTH)-1 downto 0);
    wdf_mask_data      : out std_logic_vector(((2*DQ_WIDTH)/8)-1 downto 0)
    );
end entity mig20_usr_top_0;

architecture syn of mig20_usr_top_0 is

  component mig20_usr_addr_fifo_0
    generic (
      BANK_WIDTH    : integer;
      COL_WIDTH     : integer;
      CS_BITS       : integer;
      ROW_WIDTH     : integer);
    port (
      clk0         : in  std_logic;
      rst0         : in  std_logic;
      app_af_cmd   : in  std_logic_vector(2 downto 0);
      app_af_addr  : in  std_logic_vector(30 downto 0);
      app_af_wren  : in  std_logic;
      ctrl_af_rden : in  std_logic;
      af_cmd       : out std_logic_vector(2 downto 0);
      af_addr      : out std_logic_vector(30 downto 0);
      af_empty     : out std_logic;
      app_af_afull : out std_logic);
  end component;

  component mig20_usr_rd_0
    generic (
      DQ_PER_DQS     : integer;
      DQS_WIDTH      : integer;
      APPDATA_WIDTH  : integer;
      ECC_ENABLE     : integer);
    port (
      clk0             : in  std_logic;
      rst0             : in  std_logic;
      rd_data_in_rise  : in  std_logic_vector((DQS_WIDTH*DQ_PER_DQS)-1
                                              downto 0);
      rd_data_in_fall  : in  std_logic_vector((DQS_WIDTH*DQ_PER_DQS)-1
                                              downto 0);
      ctrl_rden        : in  std_logic_vector(DQS_WIDTH-1 downto 0);
      ctrl_rden_sel    : in  std_logic_vector(DQS_WIDTH-1 downto 0);
      rd_ecc_error     : out std_logic_vector(1 downto 0);
      rd_data_valid    : out std_logic;
      rd_data_out_rise : out std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
      rd_data_out_fall : out std_logic_vector((APPDATA_WIDTH/2)-1 downto 0));
  end component;

  component mig20_usr_wr_0
    generic (
      BANK_WIDTH     : integer;
      COL_WIDTH      : integer;
      CS_BITS        : integer;
      DQ_WIDTH       : integer;
      ECC_ENABLE     : integer;
      APPDATA_WIDTH  : integer;
      ROW_WIDTH      : integer);
    port (
      clk0              : in  std_logic;
      clk90             : in  std_logic;
      rst0              : in  std_logic;
      app_wdf_wren      : in  std_logic;
      app_wdf_data      : in  std_logic_vector(APPDATA_WIDTH-1 downto 0);
      app_wdf_mask_data : in  std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
      wdf_rden          : in  std_logic;
      app_wdf_afull     : out std_logic;
      wdf_data          : out std_logic_vector((2*DQ_WIDTH)-1 downto 0);
      wdf_mask_data     : out std_logic_vector(((2*DQ_WIDTH)/8)-1 downto 0));
  end component;

  signal i_rd_data_fifo_out_fall : std_logic_vector((APPDATA_WIDTH/2)-1
                                                    downto 0);
  signal i_rd_data_fifo_out_rise : std_logic_vector((APPDATA_WIDTH/2)-1
                                                    downto 0);

begin

  --***************************************************************************

  rd_data_fifo_out <= (i_rd_data_fifo_out_fall &
                       i_rd_data_fifo_out_rise);

  -- read data de-skew and ECC calculation
  u_usr_rd_0 : mig20_usr_rd_0
    generic map (
      DQ_PER_DQS       => DQ_PER_DQS,
      ECC_ENABLE       => ECC_ENABLE,
      APPDATA_WIDTH    => APPDATA_WIDTH,
      DQS_WIDTH        => DQS_WIDTH
      )
    port map (
      clk0             => clk0,
      rst0             => rst0,
      rd_data_in_rise  => rd_data_in_rise,
      rd_data_in_fall  => rd_data_in_fall,
      rd_ecc_error     => rd_ecc_error,
      ctrl_rden        => phy_calib_rden,
      ctrl_rden_sel    => phy_calib_rden_sel,
      rd_data_valid    => rd_data_valid,
      rd_data_out_rise => i_rd_data_fifo_out_rise,
      rd_data_out_fall => i_rd_data_fifo_out_fall
      );

  -- Command/Addres FIFO
  u_usr_addr_fifo_0 : mig20_usr_addr_fifo_0
    generic map (
      BANK_WIDTH   => BANK_WIDTH,
      COL_WIDTH    => COL_WIDTH,
      CS_BITS      => CS_BITS,
      ROW_WIDTH    => ROW_WIDTH
      )
    port map (
      clk0         => clk0,
      rst0         => rst0,
      app_af_cmd   => app_af_cmd,
      app_af_addr  => app_af_addr,
      app_af_wren  => app_af_wren,
      ctrl_af_rden => ctrl_af_rden,
      af_cmd       => af_cmd,
      af_addr      => af_addr,
      af_empty     => af_empty,
      app_af_afull => app_af_afull
      );

  u_usr_wr_0 : mig20_usr_wr_0
    generic map (
      BANK_WIDTH        => BANK_WIDTH,
      COL_WIDTH         => COL_WIDTH,
      CS_BITS           => CS_BITS,
      DQ_WIDTH          => DQ_WIDTH,
      ECC_ENABLE        => ECC_ENABLE,
      APPDATA_WIDTH     => APPDATA_WIDTH,
      ROW_WIDTH         => ROW_WIDTH
      )
    port map (
      clk0              => clk0,
      clk90             => clk90,
      rst0              => rst0,
      app_wdf_wren      => app_wdf_wren,
      app_wdf_data      => app_wdf_data,
      app_wdf_mask_data => app_wdf_mask_data,
      wdf_rden          => wdf_rden,
      app_wdf_afull     => app_wdf_afull,
      wdf_data          => wdf_data,
      wdf_mask_data     => wdf_mask_data
      );

end architecture syn;



