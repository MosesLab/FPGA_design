--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-03-11	MF		Removed input buffer for hostclk and reset
-- 2008-03-18	MF		Add generics to choose between address swap module,
--						and cti ping module
--						Make sure client side ll clock matches app clock.
--********************************************************************************


-------------------------------------------------------------------------------
-- Title      : Virtex-5 Ethernet MAC Example Design Wrapper
-- Project    : Virtex-5 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v5_emac_v1_3_example_design.vhd
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
-- Description:  This is the VHDL example design for the Virtex-5 
--               Embedded Ethernet MAC.  It is intended that
--               this example design can be quickly adapted and downloaded onto
--               an FPGA to provide a real hardware test environment.
--
--               This level:
--
--               * instantiates the TEMAC local link file that instantiates 
--                 the TEMAC top level together with a RX and TX FIFO with a 
--                 local link interface;
--
--               * instantiates a simple client I/F side example design,
--                 providing an address swap and a simple
--                 loopback function;
--
--               * Instantiates IBUFs on the GTX_CLK, REFCLK and HOSTCLK inputs 
--                 if required;
--
--               Please refer to the Datasheet, Getting Started Guide, and
--               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
--
--
--
--    ---------------------------------------------------------------------
--    | EXAMPLE DESIGN WRAPPER                                            |
--    |           --------------------------------------------------------|
--    |           |LOCAL LINK WRAPPER                                     |
--    |           |              -----------------------------------------|
--    |           |              |BLOCK LEVEL WRAPPER                     |
--    |           |              |    ---------------------               |
--    | --------  |  ----------  |    | ETHERNET MAC      |               |
--    | |      |  |  |        |  |    | WRAPPER           |  ---------    |
--    | |      |->|->|        |--|--->| Tx            Tx  |--|       |--->|
--    | |      |  |  |        |  |    | client        PHY |  |       |    |
--    | | ADDR |  |  | LOCAL  |  |    | I/F           I/F |  |       |    |  
--    | | SWAP |  |  |  LINK  |  |    |                   |  | PHY   |    |
--    | |      |  |  |  FIFO  |  |    |                   |  | I/F   |    |
--    | |      |  |  |        |  |    |                   |  |       |    |
--    | |      |  |  |        |  |    | Rx            Rx  |  |       |    |
--    | |      |  |  |        |  |    | client        PHY |  |       |    |
--    | |      |<-|<-|        |<-|----| I/F           I/F |<-|       |<---|
--    | |      |  |  |        |  |    |                   |  ---------    |
--    | --------  |  ----------  |    ---------------------               |
--    |           |              -----------------------------------------|
--    |           --------------------------------------------------------|
--    ---------------------------------------------------------------------
--
-------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- The entity declaration for the example design.
-------------------------------------------------------------------------------
entity v5_emac_v1_3_example_design is
	generic (
		c_emac0swap : boolean := FALSE;
		c_emac1swap : boolean := FALSE 
	);
	port(
		clkApp : in std_logic;
	
		-- Client Receiver Interface - EMAC0
		EMAC0CLIENTRXDVLD               : out std_logic;
		EMAC0CLIENTRXFRAMEDROP          : out std_logic;
		EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
		EMAC0CLIENTRXSTATSVLD           : out std_logic;
		EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

		-- Client Transmitter Interface - EMAC0
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

		-- Client Receiver Interface - EMAC1
		EMAC1CLIENTRXDVLD               : out std_logic;
		EMAC1CLIENTRXFRAMEDROP          : out std_logic;
		EMAC1CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
		EMAC1CLIENTRXSTATSVLD           : out std_logic;
		EMAC1CLIENTRXSTATSBYTEVLD       : out std_logic;

		-- Client Transmitter Interface - EMAC1
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
end v5_emac_v1_3_example_design;


architecture TOP_LEVEL of v5_emac_v1_3_example_design is

-------------------------------------------------------------------------------
-- Component Declarations for lower hierarchial level entities
-------------------------------------------------------------------------------
  -- Component Declaration for the TEMAC wrapper with 
  -- Local Link FIFO.
  component v5_emac_v1_3_locallink is
   port(
      -- EMAC0 Clocking
      -- TX Client Clock output from EMAC0
      TX_CLIENT_CLK_OUT_0              : out std_logic;
      -- RX Client Clock output from EMAC0
      RX_CLIENT_CLK_OUT_0              : out std_logic;
      -- TX PHY Clock output from EMAC0
      TX_PHY_CLK_OUT_0                 : out std_logic;
      -- EMAC0 TX Client Clock input from BUFG
      TX_CLIENT_CLK_0                  : in  std_logic;
      -- EMAC0 RX Client Clock input from BUFG
      RX_CLIENT_CLK_0                  : in  std_logic;
      -- EMAC0 TX PHY Clock input from BUFG
      TX_PHY_CLK_0                     : in  std_logic;

      -- Local link Receiver Interface - EMAC0
      RX_LL_CLOCK_0                   : in  std_logic; 
      RX_LL_RESET_0                   : in  std_logic;
      RX_LL_DATA_0                    : out std_logic_vector(7 downto 0);
      RX_LL_SOF_N_0                   : out std_logic;
      RX_LL_EOF_N_0                   : out std_logic;
      RX_LL_SRC_RDY_N_0               : out std_logic;
      RX_LL_DST_RDY_N_0               : in  std_logic;
      RX_LL_FIFO_STATUS_0             : out std_logic_vector(3 downto 0);

      -- Local link Transmitter Interface - EMAC0
      TX_LL_CLOCK_0                   : in  std_logic;
      TX_LL_RESET_0                   : in  std_logic;
      TX_LL_DATA_0                    : in  std_logic_vector(7 downto 0);
      TX_LL_SOF_N_0                   : in  std_logic;
      TX_LL_EOF_N_0                   : in  std_logic;
      TX_LL_SRC_RDY_N_0               : in  std_logic;
      TX_LL_DST_RDY_N_0               : out std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
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

      -- Local link Receiver Interface - EMAC1
      RX_LL_CLOCK_1                   : in  std_logic; 
      RX_LL_RESET_1                   : in  std_logic;
      RX_LL_DATA_1                    : out std_logic_vector(7 downto 0);
      RX_LL_SOF_N_1                   : out std_logic;
      RX_LL_EOF_N_1                   : out std_logic;
      RX_LL_SRC_RDY_N_1               : out std_logic;
      RX_LL_DST_RDY_N_1               : in  std_logic;
      RX_LL_FIFO_STATUS_1             : out std_logic_vector(3 downto 0);

      -- Local link Transmitter Interface - EMAC1
      TX_LL_CLOCK_1                   : in  std_logic;
      TX_LL_RESET_1                   : in  std_logic;
      TX_LL_DATA_1                    : in  std_logic_vector(7 downto 0);
      TX_LL_SOF_N_1                   : in  std_logic;
      TX_LL_EOF_N_1                   : in  std_logic;
      TX_LL_SRC_RDY_N_1               : in  std_logic;
      TX_LL_DST_RDY_N_1               : out std_logic;

      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXDVLD               : out std_logic;
      EMAC1CLIENTRXFRAMEDROP          : out std_logic;
      EMAC1CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC1CLIENTRXSTATSVLD           : out std_logic;
      EMAC1CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC1
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
  end component;
 
   ---------------------------------------------------------------------
   --  Component Declaration for 8-bit address swapping module
   ---------------------------------------------------------------------
   component address_swap_module_8
   port (
      rx_ll_clock         : in  std_logic;                     -- Input CLK from MAC Reciever
      rx_ll_reset         : in  std_logic;                     -- Synchronous reset signal
      rx_ll_data_in       : in  std_logic_vector(7 downto 0);  -- Input data
      rx_ll_sof_in_n      : in  std_logic;                     -- Input start of frame
      rx_ll_eof_in_n      : in  std_logic;                     -- Input end of frame
      rx_ll_src_rdy_in_n  : in  std_logic;                     -- Input source ready
      rx_ll_data_out      : out std_logic_vector(7 downto 0);  -- Modified output data
      rx_ll_sof_out_n     : out std_logic;                     -- Output start of frame
      rx_ll_eof_out_n     : out std_logic;                     -- Output end of frame
      rx_ll_src_rdy_out_n : out std_logic;                     -- Output source ready
      rx_ll_dst_rdy_in_n  : in  std_logic                      -- Input destination ready
      );
   end component;
   
	component emacICMP is
	port
	(       
		ll_clk_i : in std_logic;
		ll_reset_i : in std_logic;  -- should by synchronous.
		
		rx_ll_data : in  std_logic_vector(7 downto 0);
		rx_ll_sof_n : in  std_logic;
		rx_ll_eof_n : in  std_logic; 
		rx_ll_src_rdy_n: in  std_logic;
		rx_ll_dst_rdy_n : out std_logic;
		
		tx_ll_data : out std_logic_vector(7 downto 0);
		tx_ll_sof_n : out std_logic;
		tx_ll_eof_n : out std_logic; 
		tx_ll_src_rdy_n : out std_logic;
		tx_ll_dst_rdy_n : in  std_logic
	);
	end component emacICMP;   

-----------------------------------------------------------------------
-- Signal Declarations
-----------------------------------------------------------------------

    -- Global asynchronous reset
    signal reset_i               : std_logic;

    -- client interface clocking signals - EMAC0
    signal ll_clk_0_i            : std_logic;

    -- address swap transmitter connections - EMAC0
    signal tx_ll_data_0_i      : std_logic_vector(7 downto 0);
    signal tx_ll_sof_n_0_i     : std_logic;
    signal tx_ll_eof_n_0_i     : std_logic;
    signal tx_ll_src_rdy_n_0_i : std_logic;
    signal tx_ll_dst_rdy_n_0_i : std_logic;

   -- address swap receiver connections - EMAC0
    signal rx_ll_data_0_i           : std_logic_vector(7 downto 0);
    signal rx_ll_sof_n_0_i          : std_logic;
    signal rx_ll_eof_n_0_i          : std_logic;
    signal rx_ll_src_rdy_n_0_i      : std_logic;
    signal rx_ll_dst_rdy_n_0_i      : std_logic;

    -- create a synchronous reset in the transmitter clock domain
    signal ll_pre_reset_0_i          : std_logic_vector(5 downto 0);
    signal ll_reset_0_i              : std_logic;

    attribute async_reg : string;
    attribute async_reg of ll_pre_reset_0_i : signal is "true";


    -- client interface clocking signals - EMAC1
    signal ll_clk_1_i            : std_logic;

    -- address swap transmitter connections - EMAC1
    signal tx_ll_data_1_i      : std_logic_vector(7 downto 0);
    signal tx_ll_sof_n_1_i     : std_logic;
    signal tx_ll_eof_n_1_i     : std_logic;
    signal tx_ll_src_rdy_n_1_i : std_logic;
    signal tx_ll_dst_rdy_n_1_i : std_logic;

    -- address swap receiver connections - EMAC1
    signal rx_ll_data_1_i           : std_logic_vector(7 downto 0);
    signal rx_ll_sof_n_1_i          : std_logic;
    signal rx_ll_eof_n_1_i          : std_logic;
    signal rx_ll_src_rdy_n_1_i      : std_logic;
    signal rx_ll_dst_rdy_n_1_i      : std_logic;

    -- create a synchronous reset in the transmitter clock domain
    signal ll_pre_reset_1_i          : std_logic_vector(5 downto 0);
    signal ll_reset_1_i              : std_logic;


    attribute async_reg of ll_pre_reset_1_i : signal is "true";

    -- HOSTCLK input to MAC
    signal host_clk_i                : std_logic;

    -- EMAC0 Clocking signals

    -- MII input clocks from PHY
    signal tx_phy_clk_0              : std_logic;
    signal rx_clk_0_i                : std_logic;
    -- Client clocks at 1.25/12.5MHz
    signal tx_client_clk_0           : std_logic;
    signal rx_client_clk_0           : std_logic;
    signal tx_client_clk_0_o         : std_logic;
    signal rx_client_clk_0_o         : std_logic;

    -- EMAC1 Clocking signals

    signal tx_phy_clk_1              : std_logic;
    signal rx_clk_1_i                : std_logic;
    signal tx_client_clk_1           : std_logic;
    signal rx_client_clk_1           : std_logic;
    signal tx_client_clk_1_o         : std_logic;
    signal rx_client_clk_1_o         : std_logic;

    --attribute buffer_type : string;
    --attribute buffer_type of host_clk_i  : signal is "none";



-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------


begin

    ---------------------------------------------------------------------------
    -- Reset Input Buffer
    ---------------------------------------------------------------------------
--    reset_ibuf : IBUF port map (I => RESET, O => reset_i);
reset_i <= RESET;

    -- EMAC0 Clocking

	-- Client clocks are looped back into emac wrapper
	-- Note that these clocks can be different
	
	-- TX_CLIENT_CLK_0 and TX_LL_CLOCK_0
	-- RX_CLIENT_CLK_0 and RX_LL_CLOCK_0
	
    -- Put the PHY clocks from the EMAC through BUFGs.
    -- Used to clock the PHY side of the EMAC wrappers.
    bufg_phy_tx_0 : BUFG port map (I => MII_TX_CLK_0, O => tx_phy_clk_0);
    bufg_phy_rx_0 : BUFG port map (I => MII_RX_CLK_0, O => rx_clk_0_i);

    -- Put the client clocks from the EMAC through BUFGs.
    -- Used to clock the client side of the EMAC wrappers.
    bufg_client_tx_0 : BUFG port map (I => tx_client_clk_0_o, O => tx_client_clk_0);
    bufg_client_rx_0 : BUFG port map (I => rx_client_clk_0_o, O => rx_client_clk_0);

    -- EMAC1 Clocking

    -- Put the PHY clocks from the EMAC through BUFGs.
    -- Used to clock the PHY side of the EMAC wrappers.
    bufg_phy_tx_1 : BUFG port map (I => MII_TX_CLK_1, O => tx_phy_clk_1);
    bufg_phy_rx_1 : BUFG port map (I => MII_RX_CLK_1, O => rx_clk_1_i);

    -- Put the client clocks from the EMAC through BUFGs.
    -- Used to clock the client side of the EMAC wrappers.
    bufg_client_tx_1 : BUFG port map (I => tx_client_clk_1_o, O => tx_client_clk_1);
    bufg_client_rx_1 : BUFG port map (I => rx_client_clk_1_o, O => rx_client_clk_1);



    ------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper with LL FIFO 
    -- (v5_emac_v1_3_locallink.v)
    ------------------------------------------------------------------------
    v5_emac_ll : v5_emac_v1_3_locallink
    port map (
      -- EMAC0 Clocking
      -- TX Client Clock output from EMAC0
      TX_CLIENT_CLK_OUT_0             => tx_client_clk_0_o,
      -- RX Client Clock output from EMAC0
      RX_CLIENT_CLK_OUT_0             => rx_client_clk_0_o,
      -- TX PHY Clock output from EMAC0
      TX_PHY_CLK_OUT_0                => open,
      -- EMAC0 TX Client Clock input from BUFG
      TX_CLIENT_CLK_0                 => tx_client_clk_0,
      -- EMAC0 RX Client Clock input from BUFG
      RX_CLIENT_CLK_0                 => rx_client_clk_0,
      -- EMAC0 TX PHY Clock input from BUFG
      TX_PHY_CLK_0                    => tx_phy_clk_0, 
      -- Local link Receiver Interface - EMAC0
      RX_LL_CLOCK_0                   => ll_clk_0_i,
      RX_LL_RESET_0                   => ll_reset_0_i,
      RX_LL_DATA_0                    => rx_ll_data_0_i,
      RX_LL_SOF_N_0                   => rx_ll_sof_n_0_i,
      RX_LL_EOF_N_0                   => rx_ll_eof_n_0_i,
      RX_LL_SRC_RDY_N_0               => rx_ll_src_rdy_n_0_i,
      RX_LL_DST_RDY_N_0               => rx_ll_dst_rdy_n_0_i,
      RX_LL_FIFO_STATUS_0             => open,

      -- Unused Receiver signals - EMAC0
      EMAC0CLIENTRXDVLD               => EMAC0CLIENTRXDVLD,
      EMAC0CLIENTRXFRAMEDROP          => EMAC0CLIENTRXFRAMEDROP,
      EMAC0CLIENTRXSTATS              => EMAC0CLIENTRXSTATS,
      EMAC0CLIENTRXSTATSVLD           => EMAC0CLIENTRXSTATSVLD,
      EMAC0CLIENTRXSTATSBYTEVLD       => EMAC0CLIENTRXSTATSBYTEVLD,

      -- Local link Transmitter Interface - EMAC0
      TX_LL_CLOCK_0                   => ll_clk_0_i,
      TX_LL_RESET_0                   => ll_reset_0_i,
      TX_LL_DATA_0                    => tx_ll_data_0_i,
      TX_LL_SOF_N_0                   => tx_ll_sof_n_0_i,
      TX_LL_EOF_N_0                   => tx_ll_eof_n_0_i,
      TX_LL_SRC_RDY_N_0               => tx_ll_src_rdy_n_0_i,
      TX_LL_DST_RDY_N_0               => tx_ll_dst_rdy_n_0_i,

      -- Unused Transmitter signals - EMAC0
      CLIENTEMAC0TXIFGDELAY           => CLIENTEMAC0TXIFGDELAY,
      EMAC0CLIENTTXSTATS              => EMAC0CLIENTTXSTATS,
      EMAC0CLIENTTXSTATSVLD           => EMAC0CLIENTTXSTATSVLD,
      EMAC0CLIENTTXSTATSBYTEVLD       => EMAC0CLIENTTXSTATSBYTEVLD,

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             => CLIENTEMAC0PAUSEREQ,
      CLIENTEMAC0PAUSEVAL             => CLIENTEMAC0PAUSEVAL,

 
      -- Clock Signals - EMAC0
      -- MII Interface - EMAC0
      MII_COL_0                       => MII_COL_0,
      MII_CRS_0                       => MII_CRS_0,
      MII_TXD_0                       => MII_TXD_0,
      MII_TX_EN_0                     => MII_TX_EN_0,
      MII_TX_ER_0                     => MII_TX_ER_0,
      MII_TX_CLK_0                    => tx_phy_clk_0,
      MII_RXD_0                       => MII_RXD_0,
      MII_RX_DV_0                     => MII_RX_DV_0,
      MII_RX_ER_0                     => MII_RX_ER_0,
      MII_RX_CLK_0                    => rx_clk_0_i,

      -- MDIO Interface - EMAC0
      MDC_0                           => MDC_0,
      MDIO_0_I                        => MDIO_0_I,
      MDIO_0_O                        => MDIO_0_O,
      MDIO_0_T                        => MDIO_0_T,

      -- EMAC1 Clocking
      -- TX Client Clock output from EMAC1
      TX_CLIENT_CLK_OUT_1             => tx_client_clk_1_o,
      -- RX Client Clock output from EMAC1
      RX_CLIENT_CLK_OUT_1             => rx_client_clk_1_o,
      -- TX PHY Clock output from EMAC1
      TX_PHY_CLK_OUT_1                => open,
      -- EMAC1 TX Client Clock input from BUFG
      TX_CLIENT_CLK_1                 => tx_client_clk_1,
      -- EMAC1 RX Client Clock input from BUFG
      RX_CLIENT_CLK_1                 => rx_client_clk_1,
      -- EMAC1 TX PHY Clock input from BUFG
      TX_PHY_CLK_1                    => tx_phy_clk_1, 
      -- Local link Receiver Interface - EMAC0
      RX_LL_CLOCK_1                   => ll_clk_1_i,
      RX_LL_RESET_1                   => ll_reset_1_i,
      RX_LL_DATA_1                    => rx_ll_data_1_i,
      RX_LL_SOF_N_1                   => rx_ll_sof_n_1_i,
      RX_LL_EOF_N_1                   => rx_ll_eof_n_1_i,
      RX_LL_SRC_RDY_N_1               => rx_ll_src_rdy_n_1_i,
      RX_LL_DST_RDY_N_1               => rx_ll_dst_rdy_n_1_i,
      RX_LL_FIFO_STATUS_1             => open,

      -- Unused Receiver signals - EMAC1
      EMAC1CLIENTRXDVLD               => EMAC1CLIENTRXDVLD,
      EMAC1CLIENTRXFRAMEDROP          => EMAC1CLIENTRXFRAMEDROP,
      EMAC1CLIENTRXSTATS              => EMAC1CLIENTRXSTATS,
      EMAC1CLIENTRXSTATSVLD           => EMAC1CLIENTRXSTATSVLD,
      EMAC1CLIENTRXSTATSBYTEVLD       => EMAC1CLIENTRXSTATSBYTEVLD,

      -- Local link Transmitter Interface - EMAC0
      TX_LL_CLOCK_1                   => ll_clk_1_i,
      TX_LL_RESET_1                   => ll_reset_1_i,
      TX_LL_DATA_1                    => tx_ll_data_1_i,
      TX_LL_SOF_N_1                   => tx_ll_sof_n_1_i,
      TX_LL_EOF_N_1                   => tx_ll_eof_n_1_i,
      TX_LL_SRC_RDY_N_1               => tx_ll_src_rdy_n_1_i,
      TX_LL_DST_RDY_N_1               => tx_ll_dst_rdy_n_1_i,

      -- Unused Transmitter signals - EMAC1
      CLIENTEMAC1TXIFGDELAY           => CLIENTEMAC1TXIFGDELAY,
      EMAC1CLIENTTXSTATS              => EMAC1CLIENTTXSTATS,
      EMAC1CLIENTTXSTATSVLD           => EMAC1CLIENTTXSTATSVLD,
      EMAC1CLIENTTXSTATSBYTEVLD       => EMAC1CLIENTTXSTATSBYTEVLD,

      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ             => CLIENTEMAC1PAUSEREQ,
      CLIENTEMAC1PAUSEVAL             => CLIENTEMAC1PAUSEVAL,

           
      -- Clock Signals - EMAC1
      -- MII Interface - EMAC1
      MII_COL_1                       => MII_COL_1,
      MII_CRS_1                       => MII_CRS_1,
      MII_TXD_1                       => MII_TXD_1,
      MII_TX_EN_1                     => MII_TX_EN_1,
      MII_TX_ER_1                     => MII_TX_ER_1,
      MII_TX_CLK_1                    => tx_phy_clk_1,
      MII_RXD_1                       => MII_RXD_1,
      MII_RX_DV_1                     => MII_RX_DV_1,
      MII_RX_ER_1                     => MII_RX_ER_1,
      MII_RX_CLK_1                    => rx_clk_1_i,

      -- Generic Host Interface
      HOSTCLK                         => host_clk_i,
      HOSTOPCODE                      => HOSTOPCODE,
      HOSTREQ                         => HOSTREQ,
      HOSTMIIMSEL                     => HOSTMIIMSEL,
      HOSTADDR                        => HOSTADDR,
      HOSTWRDATA                      => HOSTWRDATA,
      HOSTMIIMRDY                     => HOSTMIIMRDY,
      HOSTRDDATA                      => HOSTRDDATA,
      HOSTEMAC1SEL                    => HOSTEMAC1SEL,
        
        
      -- Asynchronous Reset
      RESET                           => reset_i
    );

    ---------------------------------------------------------------------
    --  Intantiate port 0 modules
    ---------------------------------------------------------------------
	g_emac0SwapY : if c_emac0swap = TRUE generate
	
		ll_clk_0_i <= tx_client_clk_0;
	
	    client_side_asm_emac0 : address_swap_module_8
	      port map (
	        rx_ll_clock         => ll_clk_0_i,
	        rx_ll_reset         => ll_reset_0_i,
	        rx_ll_data_in       => rx_ll_data_0_i,
	        rx_ll_sof_in_n      => rx_ll_sof_n_0_i,
	        rx_ll_eof_in_n      => rx_ll_eof_n_0_i,
	        rx_ll_src_rdy_in_n  => rx_ll_src_rdy_n_0_i,
	        rx_ll_data_out      => tx_ll_data_0_i,
	        rx_ll_sof_out_n     => tx_ll_sof_n_0_i,
	        rx_ll_eof_out_n     => tx_ll_eof_n_0_i,
	        rx_ll_src_rdy_out_n => tx_ll_src_rdy_n_0_i,
	        rx_ll_dst_rdy_in_n  => tx_ll_dst_rdy_n_0_i
	    );

	    rx_ll_dst_rdy_n_0_i     <= tx_ll_dst_rdy_n_0_i;
	end generate g_emac0SwapY;
	
	g_emac0SwapN : if c_emac0swap = FALSE generate
	
		ll_clk_0_i <= clkApp;
	
		u_icmp : emacICMP
		port map
		(       
			ll_clk_i => ll_clk_0_i,
			ll_reset_i => ll_reset_0_i,
			rx_ll_data => rx_ll_data_0_i,
			rx_ll_sof_n => rx_ll_sof_n_0_i,
			rx_ll_eof_n => rx_ll_eof_n_0_i,
			rx_ll_src_rdy_n => rx_ll_src_rdy_n_0_i,
			rx_ll_dst_rdy_n => rx_ll_dst_rdy_n_0_i,
			tx_ll_data => tx_ll_data_0_i,
			tx_ll_sof_n => tx_ll_sof_n_0_i,
			tx_ll_eof_n => tx_ll_eof_n_0_i,
			tx_ll_src_rdy_n => tx_ll_src_rdy_n_0_i,
			tx_ll_dst_rdy_n => tx_ll_dst_rdy_n_0_i
		);
	end generate g_emac0SwapN; 	


    -- Create synchronous reset in the transmitter clock domain.
    gen_ll_reset_emac0 : process (ll_clk_0_i, reset_i)
    begin
      if reset_i = '1' then
        ll_pre_reset_0_i <= (others => '1');
        ll_reset_0_i     <= '1';
      elsif ll_clk_0_i'event and ll_clk_0_i = '1' then
        ll_pre_reset_0_i(0)          <= '0';
        ll_pre_reset_0_i(5 downto 1) <= ll_pre_reset_0_i(4 downto 0);
        ll_reset_0_i                 <= ll_pre_reset_0_i(5);
      end if;
    end process gen_ll_reset_emac0;
 
    ---------------------------------------------------------------------
    --  Intantiate port 1 modules
    ---------------------------------------------------------------------
	
	g_emac1SwapY : if c_emac1swap = TRUE generate
	
	    ll_clk_1_i <= tx_client_clk_1;
	
		client_side_asm_emac1 : address_swap_module_8
		  port map (
			rx_ll_clock         => ll_clk_1_i,
			rx_ll_reset         => ll_reset_1_i,
			rx_ll_data_in       => rx_ll_data_1_i,
			rx_ll_sof_in_n      => rx_ll_sof_n_1_i,
			rx_ll_eof_in_n      => rx_ll_eof_n_1_i,
			rx_ll_src_rdy_in_n  => rx_ll_src_rdy_n_1_i,
			rx_ll_data_out      => tx_ll_data_1_i,
			rx_ll_sof_out_n     => tx_ll_sof_n_1_i,
			rx_ll_eof_out_n     => tx_ll_eof_n_1_i,
			rx_ll_src_rdy_out_n => tx_ll_src_rdy_n_1_i,
			rx_ll_dst_rdy_in_n  => tx_ll_dst_rdy_n_1_i
		);
	
		rx_ll_dst_rdy_n_1_i     <= tx_ll_dst_rdy_n_1_i;
		
	end generate g_emac1SwapY;

	g_emac1SwapN : if c_emac1swap = FALSE generate
	
		ll_clk_1_i <= clkApp;
	
		u_icmp : emacICMP
		port map
		(       
			ll_clk_i => ll_clk_1_i,
			ll_reset_i => ll_reset_1_i,
			rx_ll_data => rx_ll_data_1_i,
			rx_ll_sof_n => rx_ll_sof_n_1_i,
			rx_ll_eof_n => rx_ll_eof_n_1_i,
			rx_ll_src_rdy_n => rx_ll_src_rdy_n_1_i,
			rx_ll_dst_rdy_n => rx_ll_dst_rdy_n_1_i,
			tx_ll_data => tx_ll_data_1_i,
			tx_ll_sof_n => tx_ll_sof_n_1_i,
			tx_ll_eof_n => tx_ll_eof_n_1_i,
			tx_ll_src_rdy_n => tx_ll_src_rdy_n_1_i,
			tx_ll_dst_rdy_n => tx_ll_dst_rdy_n_1_i
		);
		
	end generate g_emac1SwapN; 	

    -- Create synchronous reset in the transmitter clock domain.
    gen_ll_reset_emac1 : process (ll_clk_1_i, reset_i)
    begin
      if reset_i = '1' then
        ll_pre_reset_1_i <= (others => '1');
        ll_reset_1_i     <= '1';
      elsif ll_clk_1_i'event and ll_clk_1_i = '1' then
        ll_pre_reset_1_i(0)          <= '0';
        ll_pre_reset_1_i(5 downto 1) <= ll_pre_reset_1_i(4 downto 0);
        ll_reset_1_i                 <= ll_pre_reset_1_i(5);
      end if;
    end process gen_ll_reset_emac1;
 
    ------------------------------------------------------------------------
    -- HOSTCLK Clock Management - Clock input for the generic management 
    -- interface. This clock could be tied to a 125MHz reference clock 
    -- to save on clocking resources
    ------------------------------------------------------------------------
	--    host_clk : IBUF port map(I => HOSTCLK, O => host_clk_i);
	host_clk_i <= HOSTCLK;


 
end TOP_LEVEL;
