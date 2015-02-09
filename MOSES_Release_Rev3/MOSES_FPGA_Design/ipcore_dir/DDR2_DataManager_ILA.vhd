-------------------------------------------------------------------------------
-- Copyright (c) 2014 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.4
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : DDR2_DataManager_ILA.vhd
-- /___/   /\     Timestamp  : Thu Oct 23 11:08:09 Mountain Daylight Time 2014
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY DDR2_DataManager_ILA IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    TRIG0: in std_logic_vector(255 downto 0);
    TRIG1: in std_logic_vector(255 downto 0);
    TRIG2: in std_logic_vector(255 downto 0));
END DDR2_DataManager_ILA;

ARCHITECTURE DDR2_DataManager_ILA_a OF DDR2_DataManager_ILA IS
BEGIN

END DDR2_DataManager_ILA_a;
