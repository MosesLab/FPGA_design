------------------------------------------------------------------------
-- Title      : Media Independent Interface (MII) Physical Interface
-- Project    : Virtex-5 Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : mii_if.vhd
------------------------------------------------------------------------
-- Copyright (c) 2004-2007 by Xilinx, Inc. All rights reserved.
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you 
-- a license to use this text/file solely for design, simulation, 
-- implementation and creation of design files limited 
-- to Xilinx devices or technologies. Use with non-Xilinx 
-- devices or technologies is expressly prohibited and 
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information 
-- "as is" solely for use in developing programs and 
-- solutions for Xilinx devices. By providing this design, 
-- code, or information as one possible implementation of 
-- this feature, application or standard, Xilinx is making no 
-- representation that this implementation is free from any 
-- claims of infringement. You are responsible for 
-- obtaining any rights you may require for your implementation. 
-- Xilinx expressly disclaims any warranty whatsoever with 
-- respect to the adequacy of the implementation, including 
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied 
-- warranties of merchantability or fitness for a particular 
-- purpose. 
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications are
-- expressly prohibited.
-- 
-- This copyright and support notice must be retained as part 
-- of this text at all times. (c) Copyright 2004-2007 Xilinx, Inc.
-- All rights reserved.

------------------------------------------------------------------------
-- Description:  This module creates a Media Independent Interface (MII)
--               by instantiating Input/Output buffers and Input/Output 
--               flip-flops as required.
--
--               This interface is used to connect the Ethernet MAC to
--               an external 10Mb/s and 100Mb/s Ethernet PHY.
------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------------
-- The entity declaration for the PHY IF design.
------------------------------------------------------------------------------
entity mii_if is
    port(
        RESET                         : in  std_logic;
        -- MII Interface
        MII_TXD                       : out std_logic_vector(3 downto 0);
        MII_TX_EN                     : out std_logic;
        MII_TX_ER                     : out std_logic;
        MII_RXD                       : in  std_logic_vector(3 downto 0);
        MII_RX_DV                     : in  std_logic;
        MII_RX_ER                     : in  std_logic;
        MII_COL                       : in  std_logic;
        MII_CRS                       : in  std_logic;
        -- MAC Interface
        TXD_FROM_MAC                  : in  std_logic_vector(3 downto 0);
        TX_EN_FROM_MAC                : in  std_logic;
        TX_ER_FROM_MAC                : in  std_logic;
        TX_CLK                        : in  std_logic;
        RXD_TO_MAC                    : out std_logic_vector(3 downto 0);
        RX_DV_TO_MAC                  : out std_logic;
        RX_ER_TO_MAC                  : out std_logic;
        RX_CLK                        : in  std_logic;
        MII_COL_TO_MAC                : out std_logic;
        MII_CRS_TO_MAC                : out std_logic);
end mii_if;

architecture PHY_IF of mii_if is

  signal vcc_i              : std_logic;
  signal gnd_i              : std_logic;

begin

  vcc_i <= '1';
  gnd_i <= '0';

  --------------------------------------------------------------------------
  -- MII Transmitter Logic : Drive TX signals through IOBs onto MII
  -- interface
  --------------------------------------------------------------------------
  -- Infer IOB Output flip-flops.
  mii_output_ffs : process (TX_CLK, RESET)
  begin
      if RESET = '1' then
          MII_TX_EN <= '0';
          MII_TX_ER <= '0';
          MII_TXD   <= (others => '0');
      elsif TX_CLK'event and TX_CLK = '1' then
          MII_TX_EN <= TX_EN_FROM_MAC;
          MII_TX_ER <= TX_ER_FROM_MAC;
          MII_TXD   <= TXD_FROM_MAC;
      end if;
  end process mii_output_ffs;

  --------------------------------------------------------------------------
  -- MII Receiver Logic : Receive RX signals through IOBs from MII
  -- interface
  --------------------------------------------------------------------------
  -- Infer IOB Input flip-flops
  mii_input_ffs : process (RX_CLK, RESET)
  begin
      if RESET = '1' then
          RX_DV_TO_MAC <= '0';
          RX_ER_TO_MAC <= '0';
          RXD_TO_MAC   <= (others => '0');
      elsif RX_CLK'event and RX_CLK = '1' then
          RX_DV_TO_MAC <= MII_RX_DV;
          RX_ER_TO_MAC <= MII_RX_ER;
          RXD_TO_MAC   <= MII_RXD;
      end if;
  end process mii_input_ffs;

  MII_COL_TO_MAC <= MII_COL;
  MII_CRS_TO_MAC <= MII_CRS;
 
end PHY_IF;
