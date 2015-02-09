-------------------------------------------------------------------------------
-- Title      : Virtex-5 Ethernet MAC Wrapper Top Level
-- Project    : Virtex-5 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v5_emac_v1_3_block.vhd
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Description:  This is the EMAC block level VHDL design for the Virtex-5 
--               Embedded Ethernet MAC Example Design.  It is intended that
--               this example design can be quickly adapted and downloaded onto
--               an FPGA to provide a real hardware test environment.
--
--               The block level:
--
--               * instantiates all clock management logic required (BUFGs, 
--                 DCMs) to operate the EMAC and its example design;
--
--               * instantiates appropriate PHY interface modules (GMII, MII,
--                 RGMII, SGMII or 1000BASE-X) as required based on the user
--                 configuration.
--
--
--               Please refer to the Datasheet, Getting Started Guide, and
--               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
-------------------------------------------------------------------------------


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;



-------------------------------------------------------------------------------
-- The entity declaration for the top level design.
-------------------------------------------------------------------------------
entity v5_emac_v1_3_block is
   port(
      -- EMAC0 Clocking
      -- TX Client Clock output from EMAC0
      TX_CLIENT_CLK_OUT_0             : out std_logic;
      -- RX Client Clock output from EMAC0
      RX_CLIENT_CLK_OUT_0             : out std_logic;
      -- TX PHY Clock output from EMAC0
      TX_PHY_CLK_OUT_0                : out std_logic;
      -- EMAC0 TX Client Clock input from BUFG
      TX_CLIENT_CLK_0                 : in  std_logic;
      -- EMAC0 RX Client Clock input from BUFG
      RX_CLIENT_CLK_0                 : in  std_logic;
      -- EMAC0 TX PHY Clock input from BUFG
      TX_PHY_CLK_0                    : in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXGOODFRAME          : out std_logic;
      EMAC0CLIENTRXBADFRAME           : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD                  : in  std_logic_vector(7 downto 0);
      CLIENTEMAC0TXDVLD               : in  std_logic;
      EMAC0CLIENTTXACK                : out std_logic;
      CLIENTEMAC0TXFIRSTBYTE          : in  std_logic;
      CLIENTEMAC0TXUNDERRUN           : in  std_logic;
      EMAC0CLIENTTXCOLLISION          : out std_logic;
      EMAC0CLIENTTXRETRANSMIT         : out std_logic;
      CLIENTEMAC0TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC0CLIENTTXSTATS              : out std_logic;
      EMAC0CLIENTTXSTATSVLD           : out std_logic;
      EMAC0CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             : in  std_logic;
      CLIENTEMAC0PAUSEVAL             : in  std_logic_vector(15 downto 0);

 
      -- Clock Signals - EMAC0
      -- MII Interface - EMAC0
      MII_COL_0                       : in  std_logic;
      MII_CRS_0                       : in  std_logic;
      MII_TXD_0                       : out std_logic_vector(3 downto 0);
      MII_TX_EN_0                     : out std_logic;
      MII_TX_ER_0                     : out std_logic;
      MII_TX_CLK_0                    : in  std_logic;
      MII_RXD_0                       : in  std_logic_vector(3 downto 0);
      MII_RX_DV_0                     : in  std_logic;
      MII_RX_ER_0                     : in  std_logic;
      MII_RX_CLK_0                    : in  std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                           : out std_logic;
      MDIO_0_I                        : in  std_logic;
      MDIO_0_O                        : out std_logic;
      MDIO_0_T                        : out std_logic;

      -- EMAC1 Clocking
      -- TX Client Clock output from EMAC1
      TX_CLIENT_CLK_OUT_1             : out std_logic;
      -- RX Client Clock output from EMAC1
      RX_CLIENT_CLK_OUT_1             : out std_logic;
      -- TX PHY Clock output from EMAC1
      TX_PHY_CLK_OUT_1                : out std_logic;
      -- EMAC1 TX Client Clock input from BUFG
      TX_CLIENT_CLK_1                 : in  std_logic;
      -- EMAC1 RX Client Clock input from BUFG
      RX_CLIENT_CLK_1                 : in  std_logic;
      -- EMAC1 TX PHY Clock input from BUFG
      TX_PHY_CLK_1                    : in  std_logic;

      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC1CLIENTRXDVLD               : out std_logic;
      EMAC1CLIENTRXGOODFRAME          : out std_logic;
      EMAC1CLIENTRXBADFRAME           : out std_logic;
      EMAC1CLIENTRXFRAMEDROP          : out std_logic;
      EMAC1CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC1CLIENTRXSTATSVLD           : out std_logic;
      EMAC1CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC1
      CLIENTEMAC1TXD                  : in  std_logic_vector(7 downto 0);
      CLIENTEMAC1TXDVLD               : in  std_logic;
      EMAC1CLIENTTXACK                : out std_logic;
      CLIENTEMAC1TXFIRSTBYTE          : in  std_logic;
      CLIENTEMAC1TXUNDERRUN           : in  std_logic;
      EMAC1CLIENTTXCOLLISION          : out std_logic;
      EMAC1CLIENTTXRETRANSMIT         : out std_logic;
      CLIENTEMAC1TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC1CLIENTTXSTATS              : out std_logic;
      EMAC1CLIENTTXSTATSVLD           : out std_logic;
      EMAC1CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ             : in  std_logic;
      CLIENTEMAC1PAUSEVAL             : in  std_logic_vector(15 downto 0);

           
      -- Clock Signals - EMAC1
      -- MII Interface - EMAC1
      MII_COL_1                       : in  std_logic;
      MII_CRS_1                       : in  std_logic;
      MII_TXD_1                       : out std_logic_vector(3 downto 0);
      MII_TX_EN_1                     : out std_logic;
      MII_TX_ER_1                     : out std_logic;
      MII_TX_CLK_1                    : in  std_logic;
      MII_RXD_1                       : in  std_logic_vector(3 downto 0);
      MII_RX_DV_1                     : in  std_logic;
      MII_RX_ER_1                     : in  std_logic;
      MII_RX_CLK_1                    : in  std_logic;

      -- Generic Host Interface
      HOSTCLK                         : in  std_logic;
      HOSTOPCODE                      : in  std_logic_vector(1 downto 0);
      HOSTREQ                         : in  std_logic;
      HOSTMIIMSEL                     : in  std_logic;
      HOSTADDR                        : in  std_logic_vector(9 downto 0);
      HOSTWRDATA                      : in  std_logic_vector(31 downto 0);
      HOSTMIIMRDY                     : out std_logic;
      HOSTRDDATA                      : out std_logic_vector(31 downto 0);
      HOSTEMAC1SEL                    : in  std_logic;
        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
end v5_emac_v1_3_block;


architecture TOP_LEVEL of v5_emac_v1_3_block is

-------------------------------------------------------------------------------
-- Component Declarations for lower hierarchial level entities
-------------------------------------------------------------------------------
  -- Component Declaration for the main EMAC wrapper
  component v5_emac_v1_3 is
    port(
      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXCLIENTCLKOUT       : out std_logic;
      CLIENTEMAC0RXCLIENTCLKIN        : in  std_logic;
      EMAC0CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXDVLDMSW            : out std_logic;
      EMAC0CLIENTRXGOODFRAME          : out std_logic;
      EMAC0CLIENTRXBADFRAME           : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
      EMAC0CLIENTTXCLIENTCLKOUT       : out std_logic;
      CLIENTEMAC0TXCLIENTCLKIN        : in  std_logic;
      CLIENTEMAC0TXD                  : in  std_logic_vector(7 downto 0);
      CLIENTEMAC0TXDVLD               : in  std_logic;
      CLIENTEMAC0TXDVLDMSW            : in  std_logic;
      EMAC0CLIENTTXACK                : out std_logic;
      CLIENTEMAC0TXFIRSTBYTE          : in  std_logic;
      CLIENTEMAC0TXUNDERRUN           : in  std_logic;
      EMAC0CLIENTTXCOLLISION          : out std_logic;
      EMAC0CLIENTTXRETRANSMIT         : out std_logic;
      CLIENTEMAC0TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC0CLIENTTXSTATS              : out std_logic;
      EMAC0CLIENTTXSTATSVLD           : out std_logic;
      EMAC0CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             : in  std_logic;
      CLIENTEMAC0PAUSEVAL             : in  std_logic_vector(15 downto 0);

      -- Clock Signals - EMAC0
      GTX_CLK_0                       : in  std_logic;
      PHYEMAC0TXGMIIMIICLKIN          : in  std_logic;
      EMAC0PHYTXGMIIMIICLKOUT         : out std_logic;

      -- MII Interface - EMAC0
      MII_COL_0                       : in  std_logic;
      MII_CRS_0                       : in  std_logic;
      MII_TXD_0                       : out std_logic_vector(3 downto 0);
      MII_TX_EN_0                     : out std_logic;
      MII_TX_ER_0                     : out std_logic;
      MII_TX_CLK_0                    : in  std_logic;
      MII_RXD_0                       : in  std_logic_vector(3 downto 0);
      MII_RX_DV_0                     : in  std_logic;
      MII_RX_ER_0                     : in  std_logic;
      MII_RX_CLK_0                    : in  std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                           : out std_logic;
      MDIO_0_I                        : in  std_logic;
      MDIO_0_O                        : out std_logic;
      MDIO_0_T                        : out std_logic;

      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXCLIENTCLKOUT       : out std_logic;
      CLIENTEMAC1RXCLIENTCLKIN        : in  std_logic;
      EMAC1CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC1CLIENTRXDVLD               : out std_logic;
      EMAC1CLIENTRXDVLDMSW            : out std_logic;
      EMAC1CLIENTRXGOODFRAME          : out std_logic;
      EMAC1CLIENTRXBADFRAME           : out std_logic;
      EMAC1CLIENTRXFRAMEDROP          : out std_logic;
      EMAC1CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC1CLIENTRXSTATSVLD           : out std_logic;
      EMAC1CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC1
      EMAC1CLIENTTXCLIENTCLKOUT       : out std_logic;
      CLIENTEMAC1TXCLIENTCLKIN        : in  std_logic;
      CLIENTEMAC1TXD                  : in  std_logic_vector(7 downto 0);
      CLIENTEMAC1TXDVLD               : in  std_logic;
      CLIENTEMAC1TXDVLDMSW            : in  std_logic;
      EMAC1CLIENTTXACK                : out std_logic;
      CLIENTEMAC1TXFIRSTBYTE          : in  std_logic;
      CLIENTEMAC1TXUNDERRUN           : in  std_logic;
      EMAC1CLIENTTXCOLLISION          : out std_logic;
      EMAC1CLIENTTXRETRANSMIT         : out std_logic;
      CLIENTEMAC1TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC1CLIENTTXSTATS              : out std_logic;
      EMAC1CLIENTTXSTATSVLD           : out std_logic;
      EMAC1CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ             : in  std_logic;
      CLIENTEMAC1PAUSEVAL             : in  std_logic_vector(15 downto 0);

      -- Clock Signals - EMAC1
      GTX_CLK_1                       : in  std_logic;
      PHYEMAC1TXGMIIMIICLKIN          : in  std_logic;
      EMAC1PHYTXGMIIMIICLKOUT         : out std_logic;

      -- MII Interface - EMAC1
      MII_COL_1                       : in  std_logic;
      MII_CRS_1                       : in  std_logic;
      MII_TXD_1                       : out std_logic_vector(3 downto 0);
      MII_TX_EN_1                     : out std_logic;
      MII_TX_ER_1                     : out std_logic;
      MII_TX_CLK_1                    : in  std_logic;
      MII_RXD_1                       : in  std_logic_vector(3 downto 0);
      MII_RX_DV_1                     : in  std_logic;
      MII_RX_ER_1                     : in  std_logic;
      MII_RX_CLK_1                    : in  std_logic;

      -- Generic Host Interface
      HOSTCLK                         : in  std_logic;
      HOSTOPCODE                      : in  std_logic_vector(1 downto 0);
      HOSTREQ                         : in  std_logic;
      HOSTMIIMSEL                     : in  std_logic;
      HOSTADDR                        : in  std_logic_vector(9 downto 0);
      HOSTWRDATA                      : in  std_logic_vector(31 downto 0);
      HOSTMIIMRDY                     : out std_logic;
      HOSTRDDATA                      : out std_logic_vector(31 downto 0);
      HOSTEMAC1SEL                    : in  std_logic;

      DCM_LOCKED_0                    : in  std_logic;
      DCM_LOCKED_1                    : in  std_logic;

      -- Asynchronous Reset
      RESET                           : in  std_logic
    );
  end component;


 
  -- Component Declaration for the MII Physcial Interface
  component mii_if is
   port(
      RESET                           : in  std_logic;
      -- GMII Interface
      MII_TXD                         : out std_logic_vector(3 downto 0);
      MII_TX_EN                       : out std_logic;
      MII_TX_ER                       : out std_logic;
      MII_RXD                         : in  std_logic_vector(3 downto 0);
      MII_RX_DV                       : in  std_logic;
      MII_RX_ER                       : in  std_logic;
      MII_COL                         : in  std_logic;
      MII_CRS                         : in  std_logic;
      -- MAC Interface
      TXD_FROM_MAC                    : in  std_logic_vector(3 downto 0);
      TX_EN_FROM_MAC                  : in  std_logic;
      TX_ER_FROM_MAC                  : in  std_logic;
      TX_CLK                          : in  std_logic;
      RXD_TO_MAC                      : out std_logic_vector(3 downto 0);
      RX_DV_TO_MAC                    : out std_logic;
      RX_ER_TO_MAC                    : out std_logic;
      RX_CLK                          : in  std_logic;
      MII_COL_TO_MAC                  : out std_logic;
      MII_CRS_TO_MAC                  : out std_logic);
  end component;



-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

    --  Power and ground signals
    signal gnd_i                          : std_logic;
    signal vcc_i                          : std_logic;

    -- Asynchronous reset signals
    signal reset_ibuf_i                   : std_logic;
    signal reset_i                        : std_logic;
    signal reset_r                        : std_logic_vector(3 downto 0);

    -- EMAC0 Client Clocking Signals
    signal rx_client_clk_out_0_i          : std_logic;
    signal rx_client_clk_in_0_i           : std_logic;
    signal tx_client_clk_out_0_i          : std_logic;
    signal tx_client_clk_in_0_i           : std_logic;
    -- EMAC0 Physical Interface Clocking Signals
    signal tx_gmii_mii_clk_out_0_i        : std_logic;
    signal tx_gmii_mii_clk_in_0_i         : std_logic;
    -- EMAC0 Physical Interface Signals
    signal mii_tx_clk_0_i                 : std_logic;
    signal mii_tx_en_0_i                  : std_logic;
    signal mii_tx_er_0_i                  : std_logic;
    signal mii_txd_0_i                    : std_logic_vector(3 downto 0);
    signal mii_col_0_i                    : std_logic;
    signal mii_crs_0_i                    : std_logic;
    signal mii_rx_clk_0_i                 : std_logic;
    signal mii_rx_dv_0_r                  : std_logic;
    signal mii_rx_er_0_r                  : std_logic;
    signal mii_rxd_0_r                    : std_logic_vector(3 downto 0);

    -- EMAC1 Client Clocking Signals
    signal rx_client_clk_out_1_i          : std_logic;
    signal rx_client_clk_in_1_i           : std_logic;
    signal tx_client_clk_out_1_i          : std_logic;
    signal tx_client_clk_in_1_i           : std_logic;
    -- EMAC1 Physical Interface Clocking Signals
    signal tx_gmii_mii_clk_out_1_i        : std_logic;
    signal tx_gmii_mii_clk_in_1_i         : std_logic;
    -- EMAC1 Physical Interface Signals
    signal mii_tx_clk_1_i                 : std_logic;
    signal mii_tx_en_1_i                  : std_logic;
    signal mii_tx_er_1_i                  : std_logic;
    signal mii_txd_1_i                    : std_logic_vector(3 downto 0);
    signal mii_col_1_i                    : std_logic;
    signal mii_crs_1_i                    : std_logic;
    signal mii_rx_clk_1_i                 : std_logic;
    signal mii_rx_dv_1_r                  : std_logic;
    signal mii_rx_er_1_r                  : std_logic;
    signal mii_rxd_1_r                    : std_logic_vector(3 downto 0);



    -- EMAC0 MDIO signals
    signal mdc_out_0_i                    : std_logic;
    signal mdio_in_0_i                    : std_logic;
    signal mdio_out_0_i                   : std_logic;
    signal mdio_tri_0_i                   : std_logic;


-------------------------------------------------------------------------------
-- Attribute Declarations 
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------

begin

    gnd_i     <= '0';
    vcc_i     <= '1';

    ---------------------------------------------------------------------------
    -- Main Reset Circuitry
    ---------------------------------------------------------------------------
    reset_ibuf_i <= RESET;

    reset_i <= reset_ibuf_i;

    ---------------------------------------------------------------------------
    -- MII circuitry for the Physical Interface of EMAC0
    ---------------------------------------------------------------------------

    mii0 : mii_if port map (
        RESET                         => reset_i,
        MII_TXD                       => MII_TXD_0,
        MII_TX_EN                     => MII_TX_EN_0,
        MII_TX_ER                     => MII_TX_ER_0,
        MII_RXD                       => MII_RXD_0,
        MII_RX_DV                     => MII_RX_DV_0,
        MII_RX_ER                     => MII_RX_ER_0,
        MII_COL                       => MII_COL_0,
        MII_CRS                       => MII_CRS_0,
        TXD_FROM_MAC                  => mii_txd_0_i,
        TX_EN_FROM_MAC                => mii_tx_en_0_i,
        TX_ER_FROM_MAC                => mii_tx_er_0_i,
        TX_CLK                        => tx_gmii_mii_clk_in_0_i,
        RXD_TO_MAC                    => mii_rxd_0_r,
        RX_DV_TO_MAC                  => mii_rx_dv_0_r,
        RX_ER_TO_MAC                  => mii_rx_er_0_r,
        RX_CLK                        => mii_rx_clk_0_i,
        MII_COL_TO_MAC                => mii_col_0_i,
        MII_CRS_TO_MAC                => mii_crs_0_i);


    ---------------------------------------------------------------------------
    -- MII circuitry for the Physical Interface of EMAC1
    ---------------------------------------------------------------------------

    mii1 : mii_if port map (
        RESET                         => reset_i,
        MII_TXD                       => MII_TXD_1,
        MII_TX_EN                     => MII_TX_EN_1,
        MII_TX_ER                     => MII_TX_ER_1,
        MII_RXD                       => MII_RXD_1,
        MII_RX_DV                     => MII_RX_DV_1,
        MII_RX_ER                     => MII_RX_ER_1,
        MII_COL                       => MII_COL_1,
        MII_CRS                       => MII_CRS_1,
        TXD_FROM_MAC                  => mii_txd_1_i,
        TX_EN_FROM_MAC                => mii_tx_en_1_i,
        TX_ER_FROM_MAC                => mii_tx_er_1_i,
        TX_CLK                        => tx_gmii_mii_clk_in_1_i,
        RXD_TO_MAC                    => mii_rxd_1_r,
        RX_DV_TO_MAC                  => mii_rx_dv_1_r,
        RX_ER_TO_MAC                  => mii_rx_er_1_r,
        RX_CLK                        => mii_rx_clk_1_i,
        MII_COL_TO_MAC                => mii_col_1_i,
        MII_CRS_TO_MAC                => mii_crs_1_i);


 


    ------------------------------------------------------------------------
    -- MII PHY side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_gmii_mii_clk_in_0_i <= TX_PHY_CLK_0;
 
    
    ------------------------------------------------------------------------
    -- MII PHY side Receiver Clock for EMAC0
    ------------------------------------------------------------------------
    mii_rx_clk_0_i <= MII_RX_CLK_0;    

    ------------------------------------------------------------------------
    -- MII PHY side transmit clock for EMAC1
    ------------------------------------------------------------------------
    tx_gmii_mii_clk_in_1_i <= TX_PHY_CLK_1;

    ------------------------------------------------------------------------
    -- MII PHY side Receiver Clock for EMAC1
    ------------------------------------------------------------------------
    mii_rx_clk_1_i <= MII_RX_CLK_1;


    ------------------------------------------------------------------------
    -- MII client side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_client_clk_in_0_i <= TX_CLIENT_CLK_0;

    ------------------------------------------------------------------------
    -- MII client side receive clock for EMAC0
    ------------------------------------------------------------------------
    rx_client_clk_in_0_i <= RX_CLIENT_CLK_0;

    ------------------------------------------------------------------------
    -- MII Transmitter Clock for EMAC0
    ------------------------------------------------------------------------
    mii_tx_clk_0_i <= MII_TX_CLK_0;

    ------------------------------------------------------------------------
    -- MII client side transmit clock for EMAC1
    ------------------------------------------------------------------------
    tx_client_clk_in_1_i <= TX_CLIENT_CLK_1;

    ------------------------------------------------------------------------
    -- MII client side receive clock for EMAC1
    ------------------------------------------------------------------------
    rx_client_clk_in_1_i <= RX_CLIENT_CLK_1;

    ------------------------------------------------------------------------
    -- MII Transmitter Clock for EMAC1
    ------------------------------------------------------------------------
    mii_tx_clk_1_i <= MII_TX_CLK_1;



    ------------------------------------------------------------------------
    -- Connect previously derived client clocks to example design output ports
    ------------------------------------------------------------------------
    -- EMAC0 Clocking
    -- TX Client Clock output from EMAC0
    TX_CLIENT_CLK_OUT_0       <= tx_client_clk_out_0_i;
    -- RX Client Clock output from EMAC0
    RX_CLIENT_CLK_OUT_0       <= rx_client_clk_out_0_i;
    -- TX PHY Clock output from EMAC0
    TX_PHY_CLK_OUT_0          <= tx_gmii_mii_clk_out_0_i;

    -- EMAC1 Clocking
    -- TX Client Clock output from EMAC1
    TX_CLIENT_CLK_OUT_1       <= tx_client_clk_out_1_i;
    -- RX Client Clock output from EMAC1
    RX_CLIENT_CLK_OUT_1       <= rx_client_clk_out_1_i;
    -- TX PHY Clock output from EMAC1
    TX_PHY_CLK_OUT_1          <= tx_gmii_mii_clk_out_1_i;

 

    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (v5_emac_v1_3.vhd)
    --------------------------------------------------------------------------
    v5_emac_wrapper : v5_emac_v1_3
    port map (
        -- Client Receiver Interface - EMAC0
        EMAC0CLIENTRXCLIENTCLKOUT       => rx_client_clk_out_0_i,
        CLIENTEMAC0RXCLIENTCLKIN        => rx_client_clk_in_0_i, 
        EMAC0CLIENTRXD                  => EMAC0CLIENTRXD,
        EMAC0CLIENTRXDVLD               => EMAC0CLIENTRXDVLD,
        EMAC0CLIENTRXDVLDMSW            => open,
        EMAC0CLIENTRXGOODFRAME          => EMAC0CLIENTRXGOODFRAME,
        EMAC0CLIENTRXBADFRAME           => EMAC0CLIENTRXBADFRAME,
        EMAC0CLIENTRXFRAMEDROP          => EMAC0CLIENTRXFRAMEDROP,
        EMAC0CLIENTRXSTATS              => EMAC0CLIENTRXSTATS,
        EMAC0CLIENTRXSTATSVLD           => EMAC0CLIENTRXSTATSVLD,
        EMAC0CLIENTRXSTATSBYTEVLD       => EMAC0CLIENTRXSTATSBYTEVLD,

        -- Client Transmitter Interface - EMAC0
        EMAC0CLIENTTXCLIENTCLKOUT       => tx_client_clk_out_0_i,
        CLIENTEMAC0TXCLIENTCLKIN        => tx_client_clk_in_0_i,
        CLIENTEMAC0TXD                  => CLIENTEMAC0TXD,
        CLIENTEMAC0TXDVLD               => CLIENTEMAC0TXDVLD,
        CLIENTEMAC0TXDVLDMSW            => gnd_i,
        EMAC0CLIENTTXACK                => EMAC0CLIENTTXACK,
        CLIENTEMAC0TXFIRSTBYTE          => CLIENTEMAC0TXFIRSTBYTE,
        CLIENTEMAC0TXUNDERRUN           => CLIENTEMAC0TXUNDERRUN,
        EMAC0CLIENTTXCOLLISION          => EMAC0CLIENTTXCOLLISION,
        EMAC0CLIENTTXRETRANSMIT         => EMAC0CLIENTTXRETRANSMIT,
        CLIENTEMAC0TXIFGDELAY           => CLIENTEMAC0TXIFGDELAY,
        EMAC0CLIENTTXSTATS              => EMAC0CLIENTTXSTATS,
        EMAC0CLIENTTXSTATSVLD           => EMAC0CLIENTTXSTATSVLD,
        EMAC0CLIENTTXSTATSBYTEVLD       => EMAC0CLIENTTXSTATSBYTEVLD,

        -- MAC Control Interface - EMAC0
        CLIENTEMAC0PAUSEREQ             => CLIENTEMAC0PAUSEREQ,
        CLIENTEMAC0PAUSEVAL             => CLIENTEMAC0PAUSEVAL,

        -- Clock Signals - EMAC0
        GTX_CLK_0                       => gnd_i,

        EMAC0PHYTXGMIIMIICLKOUT         => tx_gmii_mii_clk_out_0_i,
        PHYEMAC0TXGMIIMIICLKIN          => tx_gmii_mii_clk_in_0_i,

        -- MII Interface - EMAC0
        MII_COL_0                       => mii_col_0_i,
        MII_CRS_0                       => mii_crs_0_i,
        MII_TXD_0                       => mii_txd_0_i,
        MII_TX_EN_0                     => mii_tx_en_0_i,
        MII_TX_ER_0                     => mii_tx_er_0_i,
        MII_TX_CLK_0                    => mii_tx_clk_0_i,
        MII_RXD_0                       => mii_rxd_0_r,
        MII_RX_DV_0                     => mii_rx_dv_0_r,
        MII_RX_ER_0                     => mii_rx_er_0_r,
        MII_RX_CLK_0                    => mii_rx_clk_0_i,

        -- MDIO Interface - EMAC0
        MDC_0                           => mdc_out_0_i,
        MDIO_0_I                        => mdio_in_0_i,
        MDIO_0_O                        => mdio_out_0_i,
        MDIO_0_T                        => mdio_tri_0_i,

        -- Client Receiver Interface - EMAC1
        EMAC1CLIENTRXCLIENTCLKOUT       => rx_client_clk_out_1_i,
        CLIENTEMAC1RXCLIENTCLKIN        => rx_client_clk_in_1_i,
        EMAC1CLIENTRXD                  => EMAC1CLIENTRXD,
        EMAC1CLIENTRXDVLD               => EMAC1CLIENTRXDVLD,
        EMAC1CLIENTRXDVLDMSW            => open,
        EMAC1CLIENTRXGOODFRAME          => EMAC1CLIENTRXGOODFRAME,
        EMAC1CLIENTRXBADFRAME           => EMAC1CLIENTRXBADFRAME,
        EMAC1CLIENTRXFRAMEDROP          => EMAC1CLIENTRXFRAMEDROP,
        EMAC1CLIENTRXSTATS              => EMAC1CLIENTRXSTATS,
        EMAC1CLIENTRXSTATSVLD           => EMAC1CLIENTRXSTATSVLD,
        EMAC1CLIENTRXSTATSBYTEVLD       => EMAC1CLIENTRXSTATSBYTEVLD,

        -- Client Transmitter Interface - EMAC1
        EMAC1CLIENTTXCLIENTCLKOUT       => tx_client_clk_out_1_i,
        CLIENTEMAC1TXCLIENTCLKIN        => tx_client_clk_in_1_i,
        CLIENTEMAC1TXD                  => CLIENTEMAC1TXD,
        CLIENTEMAC1TXDVLD               => CLIENTEMAC1TXDVLD,
        CLIENTEMAC1TXDVLDMSW            => gnd_i,
        EMAC1CLIENTTXACK                => EMAC1CLIENTTXACK,
        CLIENTEMAC1TXFIRSTBYTE          => CLIENTEMAC1TXFIRSTBYTE,
        CLIENTEMAC1TXUNDERRUN           => CLIENTEMAC1TXUNDERRUN,
        EMAC1CLIENTTXCOLLISION          => EMAC1CLIENTTXCOLLISION,
        EMAC1CLIENTTXRETRANSMIT         => EMAC1CLIENTTXRETRANSMIT,
        CLIENTEMAC1TXIFGDELAY           => CLIENTEMAC1TXIFGDELAY,
        EMAC1CLIENTTXSTATS              => EMAC1CLIENTTXSTATS,
        EMAC1CLIENTTXSTATSVLD           => EMAC1CLIENTTXSTATSVLD,
        EMAC1CLIENTTXSTATSBYTEVLD       => EMAC1CLIENTTXSTATSBYTEVLD,

        -- MAC Control Interface - EMAC1
        CLIENTEMAC1PAUSEREQ             => CLIENTEMAC1PAUSEREQ,
        CLIENTEMAC1PAUSEVAL             => CLIENTEMAC1PAUSEVAL,

        -- Clock Signals - EMAC1
        GTX_CLK_1                       => gnd_i,

        EMAC1PHYTXGMIIMIICLKOUT         => tx_gmii_mii_clk_out_1_i,
        PHYEMAC1TXGMIIMIICLKIN          => tx_gmii_mii_clk_in_1_i,
        -- MII Interface - EMAC1
        MII_COL_1                       => mii_col_1_i,
        MII_CRS_1                       => mii_crs_1_i,
        MII_TXD_1                       => mii_txd_1_i,
        MII_TX_EN_1                     => mii_tx_en_1_i,
        MII_TX_ER_1                     => mii_tx_er_1_i,
        MII_TX_CLK_1                    => mii_tx_clk_1_i,
        MII_RXD_1                       => mii_rxd_1_r,
        MII_RX_DV_1                     => mii_rx_dv_1_r,
        MII_RX_ER_1                     => mii_rx_er_1_r,
        MII_RX_CLK_1                    => mii_rx_clk_1_i,

        -- Host Interface
        HOSTCLK                         => HOSTCLK,
        HOSTOPCODE                      => HOSTOPCODE,
        HOSTREQ                         => HOSTREQ,
        HOSTMIIMSEL                     => HOSTMIIMSEL,
        HOSTADDR                        => HOSTADDR,
        HOSTWRDATA                      => HOSTWRDATA,
        HOSTMIIMRDY                     => HOSTMIIMRDY,
        HOSTRDDATA                      => HOSTRDDATA,
        HOSTEMAC1SEL                    => HOSTEMAC1SEL,

        DCM_LOCKED_0                    => vcc_i,
        DCM_LOCKED_1                    => vcc_i,

        -- Asynchronous Reset
        RESET                           => reset_i
        );

  
  ----------------------------------------------------------------------
  -- MDIO interface for EMAC0 
  ----------------------------------------------------------------------  
  -- This example keeps the mdio_in, mdio_out, mdio_tri signals as
  -- separate connections: these could be connected to an external
  -- Tri-state buffer.  Alternatively they could be connected to a 
  -- Tri-state buffer in a Xilinx IOB and an appropriate SelectIO
  -- standard chosen.

  MDC_0       <= mdc_out_0_i;
  mdio_in_0_i <= MDIO_0_I;
  MDIO_0_O    <= mdio_out_0_i;
  MDIO_0_T    <= mdio_tri_0_i;


 


 
end TOP_LEVEL;
