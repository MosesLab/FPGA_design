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
--  /   /         Filename: mig20_idelay_ctrl.vhd
-- /___/   /\     Date Last Modified: $Date: 2007/09/21 15:23:31 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   This module instantiates the IDELAYCTRL primitive of the Virtex-5 device
--   which continuously calibrates the IDELAY elements in the region in case of
--   varying operating conditions. It takes a 200MHz clock as an input
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity mig20_idelay_ctrl is
  port (
    clk200           : in std_logic;
    rst200           : in std_logic;
    idelay_ctrl_rdy  : out std_logic
  );
end entity mig20_idelay_ctrl;

architecture syn of mig20_idelay_ctrl is

begin

  u_idelayctrl : IDELAYCTRL
    port map (
      rdy     => idelay_ctrl_rdy,
      refclk  => clk200,
      rst     => rst200
    );

end architecture syn;
