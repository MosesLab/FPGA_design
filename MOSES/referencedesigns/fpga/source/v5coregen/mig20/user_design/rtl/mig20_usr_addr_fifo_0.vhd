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
--  /   /         Filename: mig20_usr_addr_fifo_0.vhd
-- /___/   /\     Date Last Modified: $Date: 2007/09/21 15:23:31 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module instantiates the block RAM based FIFO to store the user
--   address and the command information. Also calculates potential bank/row
--   conflicts by comparing the new address with last address issued.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity mig20_usr_addr_fifo_0 is
  generic (
    BANK_WIDTH         : integer := 2;
    COL_WIDTH          : integer := 10;
    CS_BITS            : integer := 0;
    ROW_WIDTH          : integer := 13
  );
  port (
    clk0               : in std_logic;
    rst0               : in std_logic;
    app_af_cmd         : in std_logic_vector(2 downto 0);
    app_af_addr        : in std_logic_vector(30 downto 0);
    app_af_wren        : in std_logic;
    ctrl_af_rden       : in std_logic;
    af_cmd             : out std_logic_vector(2 downto 0);
    af_addr            : out std_logic_vector(30 downto 0);
    af_empty           : out std_logic;
    app_af_afull       : out std_logic
  );
end entity mig20_usr_addr_fifo_0;

architecture syn of mig20_usr_addr_fifo_0 is

  signal fifo_data_out : std_logic_vector(35 downto 0);
  signal rst_r         : std_logic;

  signal i_fifo_data_in : std_logic_vector(35 downto 0);

begin

  i_fifo_data_in(31 downto 0)  <= app_af_cmd(0) & app_af_addr;
  i_fifo_data_in(35 downto 32) <= "00" & app_af_cmd(2 downto 1);

  process (clk0)
  begin
    if (rising_edge(clk0)) then
      rst_r <= rst0;
    end if;
  end process;

  --***************************************************************************

  af_cmd  <= fifo_data_out(33 downto 31);
  af_addr <= fifo_data_out(30 downto 0);

  --***************************************************************************

  u_af : FIFO36
    generic map (
      ALMOST_EMPTY_OFFSET      => X"0007",
      ALMOST_FULL_OFFSET       => X"000F",
      DATA_WIDTH               => 36,
      DO_REG                   => 1,
      EN_SYN                   => true,
      FIRST_WORD_FALL_THROUGH  => false
    )
    port map (
      ALMOSTEMPTY  => open,
      ALMOSTFULL   => app_af_afull,
      DO           => fifo_data_out(31 downto 0),
      DOP          => fifo_data_out(35 downto 32),
      EMPTY        => af_empty,
      FULL         => open,
      RDCOUNT      => open,
      RDERR        => open,
      WRCOUNT      => open,
      WRERR        => open,
      DI           => i_fifo_data_in(31 downto 0),
      DIP          => i_fifo_data_in(35 downto 32),
      RDCLK        => clk0,
      RDEN         => ctrl_af_rden,
      RST          => rst_r,
      WRCLK        => clk0,
      WREN         => app_af_wren
    );

end architecture syn;


