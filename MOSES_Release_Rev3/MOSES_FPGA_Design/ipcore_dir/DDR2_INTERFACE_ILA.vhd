-------------------------------------------------------------------------------
-- Copyright (c) 2014 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.4
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : DDR2_INTERFACE_ILA.vhd
-- /___/   /\     Timestamp  : Sun Sep 28 16:08:49 Mountain Daylight Time 2014
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY DDR2_INTERFACE_ILA IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    TRIG0: in std_logic_vector(148 downto 0));
END DDR2_INTERFACE_ILA;

ARCHITECTURE DDR2_INTERFACE_ILA_a OF DDR2_INTERFACE_ILA IS
BEGIN

END DDR2_INTERFACE_ILA_a;
