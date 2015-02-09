-------------------------------------------------------------------------------
-- Copyright (c) 2014 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.4
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : Camera_Interface_ICON.vhd
-- /___/   /\     Timestamp  : Tue Oct 28 20:05:04 Mountain Daylight Time 2014
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY Camera_Interface_ICON IS
  port (
    CONTROL0: inout std_logic_vector(35 downto 0);
    CONTROL1: inout std_logic_vector(35 downto 0));
END Camera_Interface_ICON;

ARCHITECTURE Camera_Interface_ICON_a OF Camera_Interface_ICON IS
BEGIN

END Camera_Interface_ICON_a;
