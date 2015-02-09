--********************************************************************************
-- Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary Information of Connect Tech, Inc
-- and should be treated as Confidential.
--********************************************************************************
-- Project: 	FreeForm/PCI-104
-- Module:		mgt_tester
-- Parent:		ref_design
-- Description: Connects gtp tiles to local bus register interface.
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-07-28	MF		Based on example_mgt_top.vhd 
-- 2008-11-20	MF		Redesign for using either gtp or gtx
--********************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ctiutil.all;


--***********************************Entity Declaration************************

entity mgt_tester is
generic
(
    --EXAMPLE_LANE_WITH_START_CHAR            : integer   := 0;
    EXAMPLE_SIM_GTPRESET_SPEEDUP            : integer   := 1;
    EXAMPLE_SIM_PLL_PERDIV2                 : bit_vector:= x"190";
    EXAMPLE_USE_CHIPSCOPE                   : integer   := 0;     -- Set to 1 to use Chipscope to drive resets
	c_numgtp								: integer := 4;
	c_v5type								: string(1 to 3) := "FXT"
);
port
(
    TILE0_REFCLK_PAD_N_IN                   : in   std_logic;
    TILE0_REFCLK_PAD_P_IN                   : in   std_logic;
	
    RXN_IN                                  : in   std_logic_vector(3 downto 0);
    RXP_IN                                  : in   std_logic_vector(3 downto 0);
    TXN_OUT                                 : out  std_logic_vector(3 downto 0);
    TXP_OUT                                 : out  std_logic_vector(3 downto 0);
	
	gtp_rst									: in std_logic;
	rx_rst 									: in std_logic;
	tx_rst 									: in std_logic;

	lb_clk									: in std_logic;
	lb_we									: in std_logic_vector(3 downto 0);
	lb_en									: in std_logic;
	lb_a									: in std_logic_vector(8 downto 2);
	lb_di									: in std_logic_vector(31 downto 0);
	lb_do									: out std_logic_vector(31 downto 0);
		
	lb_tx_start								: in std_logic_vector(3 downto 0);
	lb_tx_done								: out std_logic_vector(3 downto 0);
	lb_tx_sz								: in std_logic_matrix_08(3 downto 0);
	
	lb_rx_done								: out std_logic_vector(3 downto 0);
	lb_rx_sz								: out std_logic_matrix_08(3 downto 0);
	lb_rx_ok								: in std_logic_vector(3 downto 0);
	lb_rx_err_cnt							: out std_logic_vector(31 downto 0);
	
	lb_loopback								: in  std_logic_matrix_03(3 downto 0);
	tile0_pll_ok							: out std_logic;
	tile1_pll_ok							: out std_logic
);
end mgt_tester;
    
architecture RTL of mgt_tester is



--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;
    
--************************** Register Declarations ****************************

    --signal   tile_resetdone_r              : std_logic_vector(c_numgtp-1 downto 0);
    --signal   tile_resetdone_r2             : std_logic_vector(c_numgtp-1 downto 0);
	signal   tile_rx_resetdone_r              : std_logic_vector(c_numgtp-1 downto 0);
	signal   tile_tx_resetdone_r              : std_logic_vector(c_numgtp-1 downto 0);	
    signal   tile_rx_resetdone_r2             : std_logic_vector(c_numgtp-1 downto 0);
    signal   tile_tx_resetdone_r2             : std_logic_vector(c_numgtp-1 downto 0);	

--**************************** Wire Declarations ******************************

    -------------------------- MGT Wrapper Wires ------------------------------
    --________________________________________________________________________
    --________________________________________________________________________
    --TILE0   (X0Y1)

    ------------------------ Loopback and Powerdown Ports ----------------------
--	signal  tile_loopback               	: std_logic_matrix_03(c_numgtp-1 downto 0);
    --signal  tile0_loopback0_i               : std_logic_vector(2 downto 0);
    --signal  tile0_loopback1_i               : std_logic_vector(2 downto 0);
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    signal  tile0_rxchariscomma0_i          : std_logic;
    signal  tile0_rxchariscomma1_i          : std_logic;
    signal  tile0_rxcharisk0_i              : std_logic;
    signal  tile0_rxcharisk1_i              : std_logic;
    signal  tile0_rxdisperr0_i              : std_logic;
    signal  tile0_rxdisperr1_i              : std_logic;
    signal  tile0_rxnotintable0_i           : std_logic;
    signal  tile0_rxnotintable1_i           : std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    signal  tile0_rxclkcorcnt0_i            : std_logic_vector(2 downto 0);
    signal  tile0_rxclkcorcnt1_i            : std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    signal  tile0_rxbyteisaligned0_i        : std_logic;
    signal  tile0_rxbyteisaligned1_i        : std_logic;
    signal  tile0_rxbyterealign0_i          : std_logic;
    signal  tile0_rxbyterealign1_i          : std_logic;
    signal  tile0_rxcommadet0_i             : std_logic;
    signal  tile0_rxcommadet1_i             : std_logic;
	
	signal  tile_rxenmcommaalign        : std_logic_vector(c_numgtp-1 downto 0);
	 signal  tile_rxenpcommaalign        : std_logic_vector(c_numgtp-1 downto 0);
	 
--    signal  tile0_rxenmcommaalign0_i        : std_logic;
--    signal  tile0_rxenmcommaalign1_i        : std_logic;
--    signal  tile0_rxenpcommaalign0_i        : std_logic;
--    signal  tile0_rxenpcommaalign1_i        : std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
	signal tile_rxdata                 		: std_logic_matrix_08(c_numgtp-1 downto 0);
    --signal  tile0_rxdata0_i                 : std_logic_vector(7 downto 0);
    --signal  tile0_rxdata1_i                 : std_logic_vector(7 downto 0);
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
	signal  tile_rxbufreset             : std_logic_vector(3 downto 0);
    --signal  tile0_rxbufreset0_i             : std_logic;
    --signal  tile0_rxbufreset1_i             : std_logic;
    signal  tile0_rxbufstatus0_i            : std_logic_vector(2 downto 0);
    signal  tile0_rxbufstatus1_i            : std_logic_vector(2 downto 0);
    signal  tile0_rxstatus0_i               : std_logic_vector(2 downto 0);
    signal  tile0_rxstatus1_i               : std_logic_vector(2 downto 0);
    --------------- Receive Ports - RX Loss-of-sync State Machine --------------
    signal  tile0_rxlossofsync0_i           : std_logic_vector(1 downto 0);
    signal  tile0_rxlossofsync1_i           : std_logic_vector(1 downto 0);
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    signal  tile0_gtpreset_i                : std_logic;
    signal  tile0_plllkdet_i                : std_logic;
    signal  tile0_refclkout_i               : std_logic;
	signal 	tile_resetdone					: std_logic_vector(3 downto 0);
    --signal  tile0_resetdone0_i              : std_logic;
	--signal  tile0_resetdone1_i              : std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
	signal 	tile_txcharisk					: std_logic_vector(c_numgtp-1 downto 0);
    --signal  tile0_txcharisk0_i              : std_logic;
    --signal  tile0_txcharisk1_i              : std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
	signal 	tile_txdata						: std_logic_matrix_08(c_numgtp-1 downto 0);
    --signal  tile0_txdata0_i                 : std_logic_vector(7 downto 0);
    --signal  tile0_txdata1_i                 : std_logic_vector(7 downto 0);
    signal  tile0_txoutclk0_i               : std_logic;
    signal  tile0_txoutclk1_i               : std_logic;


    --________________________________________________________________________
    --________________________________________________________________________
    --TILE1   (X0Y2)

    ------------------------ Loopback and Powerdown Ports ----------------------
    --signal  tile1_loopback0_i               : std_logic_vector(2 downto 0);
    --signal  tile1_loopback1_i               : std_logic_vector(2 downto 0);
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    signal  tile1_rxchariscomma0_i          : std_logic;
    signal  tile1_rxchariscomma1_i          : std_logic;
    signal  tile1_rxcharisk0_i              : std_logic;
    signal  tile1_rxcharisk1_i              : std_logic;
    signal  tile1_rxdisperr0_i              : std_logic;
    signal  tile1_rxdisperr1_i              : std_logic;
    signal  tile1_rxnotintable0_i           : std_logic;
    signal  tile1_rxnotintable1_i           : std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    signal  tile1_rxclkcorcnt0_i            : std_logic_vector(2 downto 0);
    signal  tile1_rxclkcorcnt1_i            : std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    signal  tile1_rxbyteisaligned0_i        : std_logic;
    signal  tile1_rxbyteisaligned1_i        : std_logic;
    signal  tile1_rxbyterealign0_i          : std_logic;
    signal  tile1_rxbyterealign1_i          : std_logic;
    signal  tile1_rxcommadet0_i             : std_logic;
    signal  tile1_rxcommadet1_i             : std_logic;
--    signal  tile1_rxenmcommaalign0_i        : std_logic;
--    signal  tile1_rxenmcommaalign1_i        : std_logic;
--    signal  tile1_rxenpcommaalign0_i        : std_logic;
--    signal  tile1_rxenpcommaalign1_i        : std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
--    signal  tile1_rxdata0_i                 : std_logic_vector(7 downto 0);
--    signal  tile1_rxdata1_i                 : std_logic_vector(7 downto 0);
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    --signal  tile1_rxbufreset0_i             : std_logic;
    --signal  tile1_rxbufreset1_i             : std_logic;
    signal  tile1_rxbufstatus0_i            : std_logic_vector(2 downto 0);
    signal  tile1_rxbufstatus1_i            : std_logic_vector(2 downto 0);
    signal  tile1_rxstatus0_i               : std_logic_vector(2 downto 0);
    signal  tile1_rxstatus1_i               : std_logic_vector(2 downto 0);
    --------------- Receive Ports - RX Loss-of-sync State Machine --------------
    signal  tile1_rxlossofsync0_i           : std_logic_vector(1 downto 0);
    signal  tile1_rxlossofsync1_i           : std_logic_vector(1 downto 0);
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    signal  tile1_gtpreset_i                : std_logic;
    signal  tile1_plllkdet_i                : std_logic;
    signal  tile1_refclkout_i               : std_logic;
    --signal  tile1_resetdone0_i              : std_logic;
    --signal  tile1_resetdone1_i              : std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    --signal  tile1_txcharisk0_i              : std_logic;
    --signal  tile1_txcharisk1_i              : std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    --signal  tile1_txdata0_i                 : std_logic_vector(7 downto 0);
   -- signal  tile1_txdata1_i                 : std_logic_vector(7 downto 0);
    signal  tile1_txoutclk0_i               : std_logic;
    signal  tile1_txoutclk1_i               : std_logic;


    ------------------------------- Global Signals -----------------------------
	--signal  tx_system_reset_c               : std_logic;
	--signal  tile0_rx_system_reset0_c        : std_logic;

	signal tile_rxreset : std_logic_vector(3 downto 0);
	signal tile_txreset : std_logic_vector(3 downto 0);
	signal tile_rx_system_reset : std_logic_vector(3 downto 0);
	signal tile_tx_system_reset : std_logic_vector(3 downto 0);
	--  signal  tile0_rxreset0_i                : std_logic;
	--  signal  tile0_txreset0_i                : std_logic;
	--  signal  tile0_rx_system_reset1_c        : std_logic;
	--  signal  tile0_rxreset1_i                : std_logic;
	--  signal  tile0_txreset1_i                : std_logic;
	--  signal  tile1_rx_system_reset0_c        : std_logic;
	--  signal  tile1_rxreset0_i                : std_logic;
	--  signal  tile1_txreset0_i                : std_logic;
	--  signal  tile1_rx_system_reset1_c        : std_logic;
	--  signal  tile1_rxreset1_i                : std_logic;
	--  signal  tile1_txreset1_i                : std_logic;
	signal  tied_to_ground_i                : std_logic;
	signal  tied_to_ground_vec_i            : std_logic_vector(63 downto 0);
	signal  tied_to_vcc_i                   : std_logic;
	signal  tied_to_vcc_vec_i               : std_logic_vector(7 downto 0);
	signal  drp_clk_in_i                    : std_logic;

	signal  tile0_refclkout_bufg_i          : std_logic;
    
    ----------------------------- User Clocks ---------------------------------
    signal  tile0_txusrclk0_i               : std_logic;
	signal  tile0_txusrclk20_i               : std_logic;	

    ----------------------- Frame check/gen Module Signals --------------------
	signal  tile0_refclk_i                  : std_logic;

	signal  tile_matchn                 : std_logic_vector(3 downto 0);   
	signal  tile_frame_check_reset      	: std_logic_vector(3 downto 0);
	signal  tile_inc_in                 : std_logic_vector(3 downto 0);
	signal  tile_inc_out                : std_logic_vector(3 downto 0);

	-- signal  tile0_matchn0_i                 : std_logic;
	signal  tile_txcharisk_float        : std_logic_matrix_04(3 downto 0);
	signal  tile_txdata_float           : std_logic_matrix_32(3 downto 0);
	--signal  tile0_error_count0_i            : std_logic_vector(7 downto 0);
	--signal  tile0_frame_check0_reset_i      : std_logic; 
	--signal  tile0_inc_in0_i                 : std_logic;
	--signal  tile0_inc_out0_i                : std_logic;
	--signal  tile0_matchn1_i                 : std_logic;
	--signal  tile0_txcharisk1_float_i        : std_logic_vector(2 downto 0);
	--signal  tile0_txdata1_float_i           : std_logic_vector(23 downto 0);
	--signal  tile0_error_count1_i            : std_logic_vector(7 downto 0);
	--signal  tile0_frame_check1_reset_i      : std_logic;
	--signal  tile0_inc_in1_i                 : std_logic;
	--signal  tile0_inc_out1_i                : std_logic;

	--signal  tile1_matchn0_i                 : std_logic;
	--signal  tile1_txcharisk0_float_i        : std_logic_vector(2 downto 0);
	--signal  tile1_txdata0_float_i           : std_logic_vector(23 downto 0);
	--signal  tile1_error_count0_i            : std_logic_vector(7 downto 0);
	--signal  tile1_frame_check0_reset_i      : std_logic;
	--signal  tile1_inc_in0_i                 : std_logic;
	--signal  tile1_inc_out0_i                : std_logic;
	-- signal  tile1_matchn1_i                 : std_logic;
	-- signal  tile1_txcharisk1_float_i        : std_logic_vector(2 downto 0);
	-- signal  tile1_txdata1_float_i           : std_logic_vector(23 downto 0);
	--signal  tile1_error_count1_i            : std_logic_vector(7 downto 0);
	--signal  tile1_frame_check1_reset_i      : std_logic;
	--signal  tile1_inc_in1_i                 : std_logic;
	--signal  tile1_inc_out1_i                : std_logic;

	signal  reset_on_data_error_i           : std_logic;

    ------------------------- Sync Module Signals -----------------------------
    signal  tile0_rx_sync_done0_i           : std_logic;
    signal  tile0_reset_rxsync0_c           : std_logic;
    signal  tile0_rx_sync_done1_i           : std_logic;
    signal  tile0_reset_rxsync1_c           : std_logic;
    signal  tile1_rx_sync_done0_i           : std_logic;
    signal  tile1_reset_rxsync0_c           : std_logic;
    signal  tile1_rx_sync_done1_i           : std_logic;
    signal  tile1_reset_rxsync1_c           : std_logic;
    signal  tx_sync_done_i                  : std_logic;
    signal  reset_txsync_c                  : std_logic;

	signal tile0_refclkout_bufg : std_logic;
	
	----------------------------------------------------
	
	signal tile_error_count_r			: std_logic_vector(31 downto 0);
	alias  tile_error_count_r2			is lb_rx_err_cnt; --: std_logic_vector(7 downto 0);
	--signal tile0_error_count1_i_r		: std_logic_vector(7 downto 0);
	--alias  tile0_error_count1_i_r2	is tile0ch1_err_cnt; --: std_logic_vector(7 downto 0);
	--signal tile1_error_count0_i_r		: std_logic_vector(7 downto 0);
	--alias  tile1_error_count0_i_r2	is tile1ch0_err_cnt; --: std_logic_vector(7 downto 0);
	--signal tile1_error_count1_i_r		: std_logic_vector(7 downto 0);
	--alias  tile1_error_count1_i_r2	is tile1ch1_err_cnt; --: std_logic_vector(7 downto 0);
	signal	tile0_plllkdet_i_r			: std_logic;
	alias	tile0_plllkdet_i_r2         is tile0_pll_ok;
	signal	tile1_plllkdet_i_r			: std_logic;
	alias	tile1_plllkdet_i_r2         is tile1_pll_ok;
	signal user_tx_reset_i_r			: std_logic;
	signal user_tx_reset_i_r2			: std_logic;
	signal user_rx_reset_i_r			: std_logic;
	signal user_rx_reset_i_r2			: std_logic;
	signal commonUsrClk 				: std_logic;
	signal tile0_refclkout_to_cmt_i		: std_logic;	
	signal refclkout_pll0_reset_i		: std_logic;	
	signal refclkout_pll0_locked_i		: std_logic;		
	
	component gtp_frame_tx is
	port
	(
		-- User Interface
		TX_DATA				: out   std_logic_vector(7 downto 0);
		TX_CHARISK			: out   std_logic; 

		-- System Interface
		USER_CLK			: in    std_logic;      
		SYSTEM_RESET		: in    std_logic;

		lb_a				: in std_logic_vector(5 downto 2);
		lb_di				: in std_logic_vector(31 downto 0);
		lb_do				: out  std_logic_vector(31 downto 0);
		lb_we				: in std_logic_vector(3 downto 0); 
		lb_en				: in std_logic; 
		lb_clk				: in std_logic;  
		
		lb_start			: in std_logic;
		lb_sz				: in std_logic_vector(7 downto 0);
		lb_done				: out std_logic
	); 
	end component gtp_frame_tx;

	component gtp_frame_rx is
	generic
	(
		c_comma_char     : std_logic_vector(7 downto 0) := x"bc";
		c_start_char	:  std_logic_vector(7 downto 0) := x"ff"
	);
	port
	(
		-- GTP User Interface
		RX_DATA                  : in  std_logic_vector(7 downto 0); 
		RX_ENMCOMMA_ALIGN        : out std_logic;
		RX_ENPCOMMA_ALIGN        : out std_logic;
		RX_ENCHAN_SYNC           : out std_logic; 

		-- Control Interface, not used
		INC_IN                   : in std_logic;   -- MF: mapped to 0
		INC_OUT                  : out std_logic; 
		PATTERN_MATCH_N          : out std_logic;
		RESET_ON_ERROR           : in std_logic; 
		ERROR_COUNT              : out std_logic_vector(7 downto 0);

		-- System Interface
		USER_CLK                 : in std_logic;       
		SYSTEM_RESET             : in std_logic;
		
		-- local bus interface
		lb_a				: in std_logic_vector(5 downto 2);
		lb_di				: in std_logic_vector(31 downto 0);
		lb_do				: out  std_logic_vector(31 downto 0);
		lb_we				: in std_logic_vector(3 downto 0); 
		lb_en				: in std_logic; 
		lb_clk				: in std_logic;  
		
		lb_rx_ok			: in std_logic;
		lb_sz				: out std_logic_vector(7 downto 0);
		lb_done				: out std_logic	
	  
	);
end component gtp_frame_rx;

	signal tx_en : std_logic_vector(3 downto 0);
	signal rx_en : std_logic_vector(3 downto 0);
	
	signal tx_do : std_logic_matrix_32(3 downto 0);
	signal rx_do : std_logic_matrix_32(3 downto 0);
	
--**************************** Main Body of Code *******************************
begin

	-- Local bus muxing
	
	lb_do <=	tx_do(0) when lb_a(8 downto 6) = "000" else
				tx_do(1) when lb_a(8 downto 6) = "001" else
				tx_do(2) when lb_a(8 downto 6) = "010" else
				tx_do(3) when lb_a(8 downto 6) = "011" else
				rx_do(0) when lb_a(8 downto 6) = "100" else
				rx_do(1) when lb_a(8 downto 6) = "101" else
				rx_do(2) when lb_a(8 downto 6) = "110" else
				rx_do(3);
								
	-- local bus enables
	tx_en(0) <= '1' when ( lb_a(8 downto 6) = "000" ) and (lb_en = '1') else '0';
	tx_en(1) <= '1' when ( lb_a(8 downto 6) = "001" ) and (lb_en = '1') else '0';
	tx_en(2) <= '1' when ( lb_a(8 downto 6) = "010" ) and (lb_en = '1') else '0';
	tx_en(3) <= '1' when ( lb_a(8 downto 6) = "011" ) and (lb_en = '1') else '0';
	rx_en(0) <= '1' when ( lb_a(8 downto 6) = "100" ) and (lb_en = '1') else '0';
	rx_en(1) <= '1' when ( lb_a(8 downto 6) = "101" ) and (lb_en = '1') else '0';
	rx_en(2) <= '1' when ( lb_a(8 downto 6) = "110" ) and (lb_en = '1') else '0';
	rx_en(3) <= '1' when ( lb_a(8 downto 6) = "111" ) and (lb_en = '1') else '0';
				
--	lb_en_tx(0) <= '1' when lb_a(8) and lb_en;
--	lb_en_rx <=  lb_a(8) and lb_en;
	
    --  Static signal Assigments
    tied_to_ground_i                        <= '0';
    tied_to_ground_vec_i                    <= x"0000000000000000";
    tied_to_vcc_i                           <= '1';
    tied_to_vcc_vec_i                       <= x"ff";

    -----------------------Dedicated GTP Reference Clock Inputs ---------------
    -- The dedicated reference clock inputs you selected in the GUI are implemented using
    -- IBUFDS instances.
    --
    -- In the UCF file for this example design, you will see that each of
    -- these IBUFDS instances has been LOCed to a particular set of pins. By LOCing to these
    -- locations, we tell the tools to use the dedicated input buffers to the GTP reference
    -- clock network, rather than general purpose IOs. To select other pins, consult the 
    -- Implementation chapter of UG196, or rerun the wizard.
    --
    -- This network is the highest performace (lowest jitter) option for providing clocks
    -- to the GTP transceivers.
    
	-- Same for both GTX, GTP
    tile0_refclk_ibufds_i : IBUFDS
    port map
    (
        O                               =>      tile0_refclk_i,
        I                               =>      TILE0_REFCLK_PAD_P_IN,
        IB                              =>      TILE0_REFCLK_PAD_N_IN
    );

	--tile0_refclk_i <= altClkIn;

    ----------------------------------- User Clocks ---------------------------
    
    -- The clock resources in this section were added based on userclk source selections on
    -- the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    -- * The userclk and userclk2 for each GTP datapath (TX and RX) must be phase aligned to 
    --   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    -- * To minimize clock resources, you can share clocks between GTPs. GTPs using the same frequency
    --   or multiples of the same frequency can be accomadated using DCMs and PLLs. Use caution when
    --   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    --   the channels using the clock are receiving data from TX channels that share a reference clock 
    --   source with each other.
g_gtp_clk : if c_v5type /= "FXT" generate
    txoutclk_bufg0_i : BUFG
    port map
    (
		I => tile0_txoutclk0_i,
		O => tile0_txusrclk0_i
    );

	u_bufg : BUFG 
	port map
    (
		I => tile0_refclkout_i,
		O => tile0_refclkout_bufg
    );	
	
	commonUsrClk <= tile0_txusrclk0_i;	
end generate g_gtp_clk;

g_gtx_clk : if c_v5type = "FXT" generate
	refclkout_pll0_bufg_i : BUFG
    port map
    (
        I                               =>      tile0_refclkout_i,
        O                               =>      tile0_refclkout_to_cmt_i
    );

    refclkout_pll0_reset_i                  <= not tile0_plllkdet_i;
	
    refclkout_pll0_i : entity work.MGT_USRCLK_SOURCE_PLL
    generic map
    (
        MULT                            =>      5,
        DIVIDE                          =>      1,
        CLK_PERIOD                      =>      10.0,
        OUT0_DIVIDE                     =>      4,
        OUT1_DIVIDE                     =>      2,
        OUT2_DIVIDE                     =>      1,
        OUT3_DIVIDE                     =>      1,
        SIMULATION_P                    =>      EXAMPLE_USE_CHIPSCOPE,
        LOCK_WAIT_COUNT                 =>      "0010011100010000"
    )
    port map
    (
        CLK0_OUT                        =>      tile0_txusrclk0_i,
        CLK1_OUT                        =>      tile0_txusrclk20_i,
        CLK2_OUT                        =>      open,
        CLK3_OUT                        =>      open,
        CLK_IN                          =>      tile0_refclkout_to_cmt_i,
        PLL_LOCKED_OUT                  =>      refclkout_pll0_locked_i,
        PLL_RESET_IN                    =>      refclkout_pll0_reset_i
    );
	
	commonUsrClk <= tile0_txusrclk20_i;
end generate g_gtx_clk;	

    ----------------------------- The GTP Wrapper -----------------------------
    
    -- Use the instantiation template in the examples directory to add the GTP wrapper to your design.
    -- In this example, the wrapper is wired up for basic operation with a frame generator and frame 
    -- checker. The GTPs will reset, then attempt to align and transmit data. If channel bonding is 
    -- enabled, bonding should occur after alignment.

    -- Wire all PLLLKDET signals to the top level as output ports
    --TILE0_PLLLKDET_OUT                      <= tile0_plllkdet_i;
    --TILE1_PLLLKDET_OUT                      <= tile1_plllkdet_i;
g_gtp_rst : if c_v5type /= "FXT" generate
    -- Hold the TX in reset till the TX user clocks are stable
    tile_txreset(0)                    <= not tile0_plllkdet_i; 
    tile_txreset(1)                    <= not tile0_plllkdet_i;
    tile_txreset(2)                    <= not tile0_plllkdet_i;
    tile_txreset(3)                    <= not tile0_plllkdet_i;

    -- Hold the RX in reset till the RX user clocks are stable
    tile_rxreset(0)                    <= not tile0_plllkdet_i;
    tile_rxreset(1)                    <= not tile0_plllkdet_i;
    tile_rxreset(2)                    <= not tile0_plllkdet_i;
    tile_rxreset(3)                    <= not tile0_plllkdet_i;
end generate g_gtp_rst;	

g_gtx_rst : if c_v5type = "FXT" generate
	-- Hold the TX in reset till the TX user clocks are stable
    tile_txreset(0)                    <= not refclkout_pll0_locked_i;
    tile_txreset(1)                    <= not refclkout_pll0_locked_i;  
    tile_txreset(2)                    <= not refclkout_pll0_locked_i;  
    tile_txreset(3)                    <= not refclkout_pll0_locked_i;

    -- Hold the RX in reset till the RX user clocks are stable 
    tile_rxreset(0)                    <= not refclkout_pll0_locked_i;
    tile_rxreset(1)                    <= not refclkout_pll0_locked_i;
    tile_rxreset(2)                    <= not refclkout_pll0_locked_i;
    tile_rxreset(3)                    <= not refclkout_pll0_locked_i;
end generate g_gtx_rst;		

g_gtp : if c_v5type /= "FXT" generate
    pciegtp_wrapper_i : entity work.PCIEGTP_WRAPPER
    generic map
    (
        WRAPPER_SIM_GTPRESET_SPEEDUP    =>      EXAMPLE_SIM_GTPRESET_SPEEDUP,
        WRAPPER_SIM_PLL_PERDIV2         =>      EXAMPLE_SIM_PLL_PERDIV2
    )
    port map
    (
        --_____________________________________________________________________
        --_____________________________________________________________________
        --TILE0  (X0Y1)

        ------------------------ Loopback and Powerdown Ports ----------------------
        TILE0_LOOPBACK0_IN              =>      lb_loopback(0), --tile0_loopback0_i,
        TILE0_LOOPBACK1_IN              =>      lb_loopback(1), --tile0_loopback1_i,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        TILE0_RXCHARISCOMMA0_OUT        =>      tile0_rxchariscomma0_i,
        TILE0_RXCHARISCOMMA1_OUT        =>      tile0_rxchariscomma1_i,
        TILE0_RXCHARISK0_OUT            =>      tile0_rxcharisk0_i,
        TILE0_RXCHARISK1_OUT            =>      tile0_rxcharisk1_i,
        TILE0_RXDISPERR0_OUT            =>      tile0_rxdisperr0_i,
        TILE0_RXDISPERR1_OUT            =>      tile0_rxdisperr1_i,
        TILE0_RXNOTINTABLE0_OUT         =>      tile0_rxnotintable0_i,
        TILE0_RXNOTINTABLE1_OUT         =>      tile0_rxnotintable1_i,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        TILE0_RXCLKCORCNT0_OUT          =>      tile0_rxclkcorcnt0_i,
        TILE0_RXCLKCORCNT1_OUT          =>      tile0_rxclkcorcnt1_i,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        TILE0_RXBYTEISALIGNED0_OUT      =>      tile0_rxbyteisaligned0_i,
        TILE0_RXBYTEISALIGNED1_OUT      =>      tile0_rxbyteisaligned1_i,
        TILE0_RXBYTEREALIGN0_OUT        =>      tile0_rxbyterealign0_i,
        TILE0_RXBYTEREALIGN1_OUT        =>      tile0_rxbyterealign1_i,
        TILE0_RXCOMMADET0_OUT           =>      tile0_rxcommadet0_i,
        TILE0_RXCOMMADET1_OUT           =>      tile0_rxcommadet1_i,
        TILE0_RXENMCOMMAALIGN0_IN       =>      tile_rxenmcommaalign(0),--tile0_rxenmcommaalign0_i,
        TILE0_RXENMCOMMAALIGN1_IN       =>      tile_rxenmcommaalign(1),--tile0_rxenmcommaalign1_i,
        TILE0_RXENPCOMMAALIGN0_IN       =>      tile_rxenpcommaalign(0),--tile0_rxenpcommaalign0_i,
        TILE0_RXENPCOMMAALIGN1_IN       =>      tile_rxenpcommaalign(1),--tile0_rxenpcommaalign1_i,
        ------------------- Receive Ports - RX Data Path interface -----------------
        TILE0_RXDATA0_OUT               =>      tile_rxdata(0), --tile0_rxdata0_i,
        TILE0_RXDATA1_OUT               =>      tile_rxdata(1), --tile0_rxdata1_i,
        TILE0_RXRESET0_IN               =>      tile_rxreset(0),--tile1_rxreset0_i,
        TILE0_RXRESET1_IN               =>      tile_rxreset(1),--tile1_rxreset1_i,
        TILE0_RXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE0_RXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE0_RXUSRCLK20_IN             =>      tile0_txusrclk0_i,
        TILE0_RXUSRCLK21_IN             =>      tile0_txusrclk0_i,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        TILE0_RXN0_IN                   =>      RXN_IN(0),
        TILE0_RXN1_IN                   =>      RXN_IN(1),
        TILE0_RXP0_IN                   =>      RXP_IN(0),
        TILE0_RXP1_IN                   =>      RXP_IN(1),
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        TILE0_RXBUFRESET0_IN            =>      tile_rxbufreset(0),
        TILE0_RXBUFRESET1_IN            =>      tile_rxbufreset(1),
        TILE0_RXBUFSTATUS0_OUT          =>      tile0_rxbufstatus0_i,
        TILE0_RXBUFSTATUS1_OUT          =>      tile0_rxbufstatus1_i,
        TILE0_RXSTATUS0_OUT             =>      tile0_rxstatus0_i,
        TILE0_RXSTATUS1_OUT             =>      tile0_rxstatus1_i,
        --------------- Receive Ports - RX Loss-of-sync State Machine --------------
        TILE0_RXLOSSOFSYNC0_OUT         =>      tile0_rxlossofsync0_i,
        TILE0_RXLOSSOFSYNC1_OUT         =>      tile0_rxlossofsync1_i,
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        TILE0_CLKIN_IN                  =>      tile0_refclk_i,
        TILE0_GTPRESET_IN               =>      tile0_gtpreset_i,
        TILE0_PLLLKDET_OUT              =>      tile0_plllkdet_i,
        TILE0_REFCLKOUT_OUT             =>      tile0_refclkout_i,
        TILE0_RESETDONE0_OUT            =>      tile_resetdone(0),--tile0_resetdone0_i,
        TILE0_RESETDONE1_OUT            =>      tile_resetdone(1),--tile0_resetdone1_i,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TILE0_TXCHARISK0_IN             =>      tile_txcharisk(0), --tile0_txcharisk0_i,
        TILE0_TXCHARISK1_IN             =>      tile_txcharisk(1), --tile0_txcharisk1_i,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TILE0_TXDATA0_IN                =>      tile_txdata(0), --tile0_txdata0_i,
        TILE0_TXDATA1_IN                =>      tile_txdata(1), --tile0_txdata1_i,
        TILE0_TXOUTCLK0_OUT             =>      tile0_txoutclk0_i,
        TILE0_TXOUTCLK1_OUT             =>      tile0_txoutclk1_i,
        TILE0_TXRESET0_IN               =>      tile_txreset(0),--tile1_txreset0_i,
        TILE0_TXRESET1_IN               =>      tile_txreset(1),--tile1_txreset1_i,
        TILE0_TXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE0_TXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE0_TXUSRCLK20_IN             =>      tile0_txusrclk0_i,
        TILE0_TXUSRCLK21_IN             =>      tile0_txusrclk0_i,
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TILE0_TXN0_OUT                  =>      TXN_OUT(0),
        TILE0_TXN1_OUT                  =>      TXN_OUT(1),
        TILE0_TXP0_OUT                  =>      TXP_OUT(0),
        TILE0_TXP1_OUT                  =>      TXP_OUT(1),
		
        --_____________________________________________________________________
        --_____________________________________________________________________
        --TILE1  (X0Y2)

        ------------------------ Loopback and Powerdown Ports ----------------------
        TILE1_LOOPBACK0_IN              =>      lb_loopback(2), --tile1_loopback0_i,
        TILE1_LOOPBACK1_IN              =>      lb_loopback(3), --tile1_loopback1_i,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        TILE1_RXCHARISCOMMA0_OUT        =>      tile1_rxchariscomma0_i,
        TILE1_RXCHARISCOMMA1_OUT        =>      tile1_rxchariscomma1_i,
        TILE1_RXCHARISK0_OUT            =>      tile1_rxcharisk0_i,
        TILE1_RXCHARISK1_OUT            =>      tile1_rxcharisk1_i,
        TILE1_RXDISPERR0_OUT            =>      tile1_rxdisperr0_i,
        TILE1_RXDISPERR1_OUT            =>      tile1_rxdisperr1_i,
        TILE1_RXNOTINTABLE0_OUT         =>      tile1_rxnotintable0_i,
        TILE1_RXNOTINTABLE1_OUT         =>      tile1_rxnotintable1_i,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        TILE1_RXCLKCORCNT0_OUT          =>      tile1_rxclkcorcnt0_i,
        TILE1_RXCLKCORCNT1_OUT          =>      tile1_rxclkcorcnt1_i,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        TILE1_RXBYTEISALIGNED0_OUT      =>      tile1_rxbyteisaligned0_i,
        TILE1_RXBYTEISALIGNED1_OUT      =>      tile1_rxbyteisaligned1_i,
        TILE1_RXBYTEREALIGN0_OUT        =>      tile1_rxbyterealign0_i,
        TILE1_RXBYTEREALIGN1_OUT        =>      tile1_rxbyterealign1_i,
        TILE1_RXCOMMADET0_OUT           =>      tile1_rxcommadet0_i,
        TILE1_RXCOMMADET1_OUT           =>      tile1_rxcommadet1_i,
        TILE1_RXENMCOMMAALIGN0_IN       =>      tile_rxenmcommaalign(2), --tile1_rxenmcommaalign0_i,
        TILE1_RXENMCOMMAALIGN1_IN       =>      tile_rxenmcommaalign(3), --tile1_rxenmcommaalign1_i,
        TILE1_RXENPCOMMAALIGN0_IN       =>      tile_rxenpcommaalign(2),--tile1_rxenpcommaalign0_i,
        TILE1_RXENPCOMMAALIGN1_IN       =>      tile_rxenpcommaalign(3),--tile1_rxenpcommaalign1_i,
        ------------------- Receive Ports - RX Data Path interface -----------------
        TILE1_RXDATA0_OUT               =>      tile_rxdata(2), --tile1_rxdata0_i,
        TILE1_RXDATA1_OUT               =>      tile_rxdata(3), --tile1_rxdata1_i,
        TILE1_RXRESET0_IN               =>      tile_rxreset(2),--tile1_rxreset0_i,
        TILE1_RXRESET1_IN               =>      tile_rxreset(3), --tile1_rxreset1_i,
        TILE1_RXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE1_RXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE1_RXUSRCLK20_IN             =>      tile0_txusrclk0_i,
        TILE1_RXUSRCLK21_IN             =>      tile0_txusrclk0_i,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        TILE1_RXN0_IN                   =>      RXN_IN(2),
        TILE1_RXN1_IN                   =>      RXN_IN(3),
        TILE1_RXP0_IN                   =>      RXP_IN(2),
        TILE1_RXP1_IN                   =>      RXP_IN(3),
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        TILE1_RXBUFRESET0_IN            =>      tile_rxbufreset(2),
        TILE1_RXBUFRESET1_IN            =>      tile_rxbufreset(3),
        TILE1_RXBUFSTATUS0_OUT          =>      tile1_rxbufstatus0_i,
        TILE1_RXBUFSTATUS1_OUT          =>      tile1_rxbufstatus1_i,
        TILE1_RXSTATUS0_OUT             =>      tile1_rxstatus0_i,
        TILE1_RXSTATUS1_OUT             =>      tile1_rxstatus1_i,
        --------------- Receive Ports - RX Loss-of-sync State Machine --------------
        TILE1_RXLOSSOFSYNC0_OUT         =>      tile1_rxlossofsync0_i,
        TILE1_RXLOSSOFSYNC1_OUT         =>      tile1_rxlossofsync1_i,
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        TILE1_CLKIN_IN                  =>      tile0_refclk_i,
        TILE1_GTPRESET_IN               =>      tile1_gtpreset_i,
        TILE1_PLLLKDET_OUT              =>      tile1_plllkdet_i,
        TILE1_REFCLKOUT_OUT             =>      tile1_refclkout_i,
        TILE1_RESETDONE0_OUT            =>      tile_resetdone(2), --tile1_resetdone0_i,
        TILE1_RESETDONE1_OUT            =>      tile_resetdone(3), --tile1_resetdone1_i,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TILE1_TXCHARISK0_IN             =>      tile_txcharisk(2), --tile1_txcharisk0_i,
        TILE1_TXCHARISK1_IN             =>      tile_txcharisk(3), --tile1_txcharisk1_i,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TILE1_TXDATA0_IN                =>      tile_txdata(2), --tile1_txdata0_i,
        TILE1_TXDATA1_IN                =>      tile_txdata(3), --tile1_txdata1_i,
        TILE1_TXOUTCLK0_OUT             =>      tile1_txoutclk0_i,
        TILE1_TXOUTCLK1_OUT             =>      tile1_txoutclk1_i,
        TILE1_TXRESET0_IN               =>      tile_txreset(2),--tile1_txreset0_i,
        TILE1_TXRESET1_IN               =>      tile_txreset(3),--tile1_txreset1_i,
        TILE1_TXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE1_TXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE1_TXUSRCLK20_IN             =>      tile0_txusrclk0_i,
        TILE1_TXUSRCLK21_IN             =>      tile0_txusrclk0_i,
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TILE1_TXN0_OUT                  =>      TXN_OUT(2),
        TILE1_TXN1_OUT                  =>      TXN_OUT(3),
        TILE1_TXP0_OUT                  =>      TXP_OUT(2),
        TILE1_TXP1_OUT                  =>      TXP_OUT(3)
    );
end generate g_gtp;

g_gtx : if c_v5type = "FXT" generate
    pciegtp_wrapper_i : entity work.PCIEGTX_WRAPPER
    generic map
    (
        --WRAPPER_SIM_PLL_PERDIV2         =>      EXAMPLE_SIM_PLL_PERDIV2	
		WRAPPER_SIM_MODE                => "FAST",
		WRAPPER_SIM_GTXRESET_SPEEDUP    => EXAMPLE_SIM_GTPRESET_SPEEDUP,
		WRAPPER_SIM_PLL_PERDIV2         => x"0c8"
    )
    port map
    (
        --_____________________________________________________________________
        --_____________________________________________________________________
        --TILE0  (X0Y1)

        ------------------------ Loopback and Powerdown Ports ----------------------
        TILE0_LOOPBACK0_IN              =>      lb_loopback(0), --tile0_loopback0_i,
        TILE0_LOOPBACK1_IN              =>      lb_loopback(1), --tile0_loopback1_i,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        TILE0_RXCHARISCOMMA0_OUT        =>      tile0_rxchariscomma0_i,
        TILE0_RXCHARISCOMMA1_OUT        =>      tile0_rxchariscomma1_i,
        TILE0_RXCHARISK0_OUT            =>      tile0_rxcharisk0_i,
        TILE0_RXCHARISK1_OUT            =>      tile0_rxcharisk1_i,
        TILE0_RXDISPERR0_OUT            =>      tile0_rxdisperr0_i,
        TILE0_RXDISPERR1_OUT            =>      tile0_rxdisperr1_i,
        TILE0_RXNOTINTABLE0_OUT         =>      tile0_rxnotintable0_i,
        TILE0_RXNOTINTABLE1_OUT         =>      tile0_rxnotintable1_i,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        TILE0_RXCLKCORCNT0_OUT          =>      tile0_rxclkcorcnt0_i,
        TILE0_RXCLKCORCNT1_OUT          =>      tile0_rxclkcorcnt1_i,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        TILE0_RXBYTEISALIGNED0_OUT      =>      tile0_rxbyteisaligned0_i,
        TILE0_RXBYTEISALIGNED1_OUT      =>      tile0_rxbyteisaligned1_i,
        TILE0_RXBYTEREALIGN0_OUT        =>      tile0_rxbyterealign0_i,
        TILE0_RXBYTEREALIGN1_OUT        =>      tile0_rxbyterealign1_i,
        TILE0_RXCOMMADET0_OUT           =>      tile0_rxcommadet0_i,
        TILE0_RXCOMMADET1_OUT           =>      tile0_rxcommadet1_i,
        TILE0_RXENMCOMMAALIGN0_IN       =>      tile_rxenmcommaalign(0),--tile0_rxenmcommaalign0_i,
        TILE0_RXENMCOMMAALIGN1_IN       =>      tile_rxenmcommaalign(1),--tile0_rxenmcommaalign1_i,
        TILE0_RXENPCOMMAALIGN0_IN       =>      tile_rxenpcommaalign(0),--tile0_rxenpcommaalign0_i,
        TILE0_RXENPCOMMAALIGN1_IN       =>      tile_rxenpcommaalign(1),--tile0_rxenpcommaalign1_i,
        ------------------- Receive Ports - RX Data Path interface -----------------
        TILE0_RXDATA0_OUT               =>      tile_rxdata(0), --tile0_rxdata0_i,
        TILE0_RXDATA1_OUT               =>      tile_rxdata(1), --tile0_rxdata1_i,
        TILE0_RXRESET0_IN               =>      tile_rxreset(0),--tile1_rxreset0_i,
        TILE0_RXRESET1_IN               =>      tile_rxreset(1),--tile1_rxreset1_i,
        TILE0_RXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE0_RXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE0_RXUSRCLK20_IN             =>      tile0_txusrclk20_i,
        TILE0_RXUSRCLK21_IN             =>      tile0_txusrclk20_i,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        TILE0_RXN0_IN                   =>      RXN_IN(0),
        TILE0_RXN1_IN                   =>      RXN_IN(1),
        TILE0_RXP0_IN                   =>      RXP_IN(0),
        TILE0_RXP1_IN                   =>      RXP_IN(1),
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        TILE0_RXBUFRESET0_IN            =>      tile_rxbufreset(0),
        TILE0_RXBUFRESET1_IN            =>      tile_rxbufreset(1),
        TILE0_RXBUFSTATUS0_OUT          =>      tile0_rxbufstatus0_i,
        TILE0_RXBUFSTATUS1_OUT          =>      tile0_rxbufstatus1_i,
        TILE0_RXSTATUS0_OUT             =>      tile0_rxstatus0_i,
        TILE0_RXSTATUS1_OUT             =>      tile0_rxstatus1_i,
        --------------- Receive Ports - RX Loss-of-sync State Machine --------------
        TILE0_RXLOSSOFSYNC0_OUT         =>      tile0_rxlossofsync0_i,
        TILE0_RXLOSSOFSYNC1_OUT         =>      tile0_rxlossofsync1_i,
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        TILE0_CLKIN_IN                  =>      tile0_refclk_i,
        TILE0_GTxRESET_IN               =>      tile0_gtpreset_i,
        TILE0_PLLLKDET_OUT              =>      tile0_plllkdet_i,
        TILE0_REFCLKOUT_OUT             =>      tile0_refclkout_i,
        TILE0_RESETDONE0_OUT            =>      tile_resetdone(0),--tile0_resetdone0_i,
        TILE0_RESETDONE1_OUT            =>      tile_resetdone(1),--tile0_resetdone1_i,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TILE0_TXCHARISK0_IN             =>      tile_txcharisk(0), --tile0_txcharisk0_i,
        TILE0_TXCHARISK1_IN             =>      tile_txcharisk(1), --tile0_txcharisk1_i,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TILE0_TXDATA0_IN                =>      tile_txdata(0), --tile0_txdata0_i,
        TILE0_TXDATA1_IN                =>      tile_txdata(1), --tile0_txdata1_i,
        TILE0_TXOUTCLK0_OUT             =>      tile0_txoutclk0_i,
        TILE0_TXOUTCLK1_OUT             =>      tile0_txoutclk1_i,
        TILE0_TXRESET0_IN               =>      tile_txreset(0),--tile1_txreset0_i,
        TILE0_TXRESET1_IN               =>      tile_txreset(1),--tile1_txreset1_i,
        TILE0_TXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE0_TXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE0_TXUSRCLK20_IN             =>      tile0_txusrclk20_i,
        TILE0_TXUSRCLK21_IN             =>      tile0_txusrclk20_i,
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TILE0_TXN0_OUT                  =>      TXN_OUT(0),
        TILE0_TXN1_OUT                  =>      TXN_OUT(1),
        TILE0_TXP0_OUT                  =>      TXP_OUT(0),
        TILE0_TXP1_OUT                  =>      TXP_OUT(1),
		
        --_____________________________________________________________________
        --_____________________________________________________________________
        --TILE1  (X0Y2)

        ------------------------ Loopback and Powerdown Ports ----------------------
        TILE1_LOOPBACK0_IN              =>      lb_loopback(2), --tile1_loopback0_i,
        TILE1_LOOPBACK1_IN              =>      lb_loopback(3), --tile1_loopback1_i,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        TILE1_RXCHARISCOMMA0_OUT        =>      tile1_rxchariscomma0_i,
        TILE1_RXCHARISCOMMA1_OUT        =>      tile1_rxchariscomma1_i,
        TILE1_RXCHARISK0_OUT            =>      tile1_rxcharisk0_i,
        TILE1_RXCHARISK1_OUT            =>      tile1_rxcharisk1_i,
        TILE1_RXDISPERR0_OUT            =>      tile1_rxdisperr0_i,
        TILE1_RXDISPERR1_OUT            =>      tile1_rxdisperr1_i,
        TILE1_RXNOTINTABLE0_OUT         =>      tile1_rxnotintable0_i,
        TILE1_RXNOTINTABLE1_OUT         =>      tile1_rxnotintable1_i,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        TILE1_RXCLKCORCNT0_OUT          =>      tile1_rxclkcorcnt0_i,
        TILE1_RXCLKCORCNT1_OUT          =>      tile1_rxclkcorcnt1_i,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        TILE1_RXBYTEISALIGNED0_OUT      =>      tile1_rxbyteisaligned0_i,
        TILE1_RXBYTEISALIGNED1_OUT      =>      tile1_rxbyteisaligned1_i,
        TILE1_RXBYTEREALIGN0_OUT        =>      tile1_rxbyterealign0_i,
        TILE1_RXBYTEREALIGN1_OUT        =>      tile1_rxbyterealign1_i,
        TILE1_RXCOMMADET0_OUT           =>      tile1_rxcommadet0_i,
        TILE1_RXCOMMADET1_OUT           =>      tile1_rxcommadet1_i,
        TILE1_RXENMCOMMAALIGN0_IN       =>      tile_rxenmcommaalign(2), --tile1_rxenmcommaalign0_i,
        TILE1_RXENMCOMMAALIGN1_IN       =>      tile_rxenmcommaalign(3), --tile1_rxenmcommaalign1_i,
        TILE1_RXENPCOMMAALIGN0_IN       =>      tile_rxenpcommaalign(2),--tile1_rxenpcommaalign0_i,
        TILE1_RXENPCOMMAALIGN1_IN       =>      tile_rxenpcommaalign(3),--tile1_rxenpcommaalign1_i,
        ------------------- Receive Ports - RX Data Path interface -----------------
        TILE1_RXDATA0_OUT               =>      tile_rxdata(2), --tile1_rxdata0_i,
        TILE1_RXDATA1_OUT               =>      tile_rxdata(3), --tile1_rxdata1_i,
        TILE1_RXRESET0_IN               =>      tile_rxreset(2),--tile1_rxreset0_i,
        TILE1_RXRESET1_IN               =>      tile_rxreset(3), --tile1_rxreset1_i,
        TILE1_RXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE1_RXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE1_RXUSRCLK20_IN             =>      tile0_txusrclk20_i,
        TILE1_RXUSRCLK21_IN             =>      tile0_txusrclk20_i,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        TILE1_RXN0_IN                   =>      RXN_IN(2),
        TILE1_RXN1_IN                   =>      RXN_IN(3),
        TILE1_RXP0_IN                   =>      RXP_IN(2),
        TILE1_RXP1_IN                   =>      RXP_IN(3),
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        TILE1_RXBUFRESET0_IN            =>      tile_rxbufreset(2),
        TILE1_RXBUFRESET1_IN            =>      tile_rxbufreset(3),
        TILE1_RXBUFSTATUS0_OUT          =>      tile1_rxbufstatus0_i,
        TILE1_RXBUFSTATUS1_OUT          =>      tile1_rxbufstatus1_i,
        TILE1_RXSTATUS0_OUT             =>      tile1_rxstatus0_i,
        TILE1_RXSTATUS1_OUT             =>      tile1_rxstatus1_i,
        --------------- Receive Ports - RX Loss-of-sync State Machine --------------
        TILE1_RXLOSSOFSYNC0_OUT         =>      tile1_rxlossofsync0_i,
        TILE1_RXLOSSOFSYNC1_OUT         =>      tile1_rxlossofsync1_i,
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        TILE1_CLKIN_IN                  =>      tile0_refclk_i,
        TILE1_GTxRESET_IN               =>      tile1_gtpreset_i,
        TILE1_PLLLKDET_OUT              =>      tile1_plllkdet_i,
        TILE1_REFCLKOUT_OUT             =>      tile1_refclkout_i,
        TILE1_RESETDONE0_OUT            =>      tile_resetdone(2), --tile1_resetdone0_i,
        TILE1_RESETDONE1_OUT            =>      tile_resetdone(3), --tile1_resetdone1_i,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TILE1_TXCHARISK0_IN             =>      tile_txcharisk(2), --tile1_txcharisk0_i,
        TILE1_TXCHARISK1_IN             =>      tile_txcharisk(3), --tile1_txcharisk1_i,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TILE1_TXDATA0_IN                =>      tile_txdata(2), --tile1_txdata0_i,
        TILE1_TXDATA1_IN                =>      tile_txdata(3), --tile1_txdata1_i,
        TILE1_TXOUTCLK0_OUT             =>      tile1_txoutclk0_i,
        TILE1_TXOUTCLK1_OUT             =>      tile1_txoutclk1_i,
        TILE1_TXRESET0_IN               =>      tile_txreset(2),--tile1_txreset0_i,
        TILE1_TXRESET1_IN               =>      tile_txreset(3),--tile1_txreset1_i,
        TILE1_TXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE1_TXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE1_TXUSRCLK20_IN             =>      tile0_txusrclk20_i,
        TILE1_TXUSRCLK21_IN             =>      tile0_txusrclk20_i,
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TILE1_TXN0_OUT                  =>      TXN_OUT(2),
        TILE1_TXN1_OUT                  =>      TXN_OUT(3),
        TILE1_TXP0_OUT                  =>      TXP_OUT(2),
        TILE1_TXP1_OUT                  =>      TXP_OUT(3)
    );
end generate g_gtx;

    -------------------------- User Module Resets -----------------------------
    -- All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
    -- are held in reset till the RESETDONE goes high. 
    -- The RESETDONE is registered a couple of times on USRCLK2 and connected 
    -- to the reset of the modules
g_rst : for x in 0 to c_numgtp-1 generate    
    process( commonUsrClk,tile_resetdone(x))
    begin
        if(tile_resetdone(x) = '0') then
            --tile_resetdone_r(x)  <= '0'   after DLY;
            --tile_resetdone_r2(x) <= '0'   after DLY;
            tile_rx_resetdone_r(x)  <= '0'   after DLY;
            tile_rx_resetdone_r2(x) <= '0'   after DLY;			
            tile_tx_resetdone_r(x)  <= '0'   after DLY;
            tile_tx_resetdone_r2(x) <= '0'   after DLY;						
        elsif(commonUsrClk'event and commonUsrClk = '1') then
            -- from gtp
			--tile_resetdone_r(x)  <= tile_resetdone(x)   after DLY;
            --tile_resetdone_r2(x) <= tile_resetdone_r(x)   after DLY;
			
			-- from GTX
			--tile0_rx_resetdone0_r  <= tile0_resetdone0_i   after DLY;
            --tile0_rx_resetdone0_r2 <= tile0_rx_resetdone0_r   after DLY;			
			--tile0_tx_resetdone0_r  <= tile0_resetdone0_i   after DLY;
            --tile0_tx_resetdone0_r2 <= tile0_tx_resetdone0_r   after DLY;			
			
            tile_rx_resetdone_r(x)  <= tile_resetdone(x)   after DLY;
            tile_rx_resetdone_r2(x) <= tile_rx_resetdone_r(x)   after DLY;			
            tile_tx_resetdone_r(x)  <= tile_resetdone(x)   after DLY;
            tile_tx_resetdone_r2(x) <= tile_tx_resetdone_r(x)   after DLY;					
        end if;
    end process;
	
    -- assign resets for frame_gen and frame_check modules
    tile_tx_system_reset(x)	<= (not tile_tx_resetdone_r2(x)) or user_tx_reset_i_r2;
    tile_rx_system_reset(x)	<= (not tile_rx_resetdone_r2(x)) or user_rx_reset_i_r2;
    tile_rxbufreset(x)		<= tied_to_ground_i;
	
end generate g_rst;

    ------------------------------ Frame Generators ---------------------------

	
g_txrx : for x in 0 to c_numgtp-1 generate

    u_tx : gtp_frame_tx
    --generic map
    --(
    --)
    port map
    (
        -- User Interface
        TX_DATA(7 downto 0)             =>      tile_txdata(x),
        TX_CHARISK                   =>      tile_txcharisk(x),
		
        -- System Interface
        USER_CLK                        =>      commonUsrClk,
        SYSTEM_RESET                    =>      tile_rx_system_reset(x),
		
		-- Local bus interface
		lb_a							=> lb_a(5 downto 2),
		lb_di							=> lb_di,
		lb_do							=> tx_do(x),
		lb_we							=> lb_we,
		lb_en							=> tx_en(x),
		lb_clk							=> lb_clk,
		lb_start						=> lb_tx_start(x),
		lb_sz							=> lb_tx_sz(x),
		lb_done							=> lb_tx_done(x)
    );

    
    tile_frame_check_reset(x)              <= tile_matchn(x);
	
	-- this signal is meaning less since channels are independent.
    tile_inc_in(x)                         <= '0';

    u_rx : gtp_frame_rx
    --generic map
    --(
        -- except defaults
    --)
    port map
    (
        -- MGT Interface
        RX_DATA                         =>     tile_rxdata(x),--tile0_rxdata0_i,
        RX_ENMCOMMA_ALIGN               =>     tile_rxenmcommaalign(x),--tile0_rxenmcommaalign0_i,
        RX_ENPCOMMA_ALIGN               =>     tile_rxenpcommaalign(x),--tile0_rxenpcommaalign0_i,
        RX_ENCHAN_SYNC                  =>     open,
        -- Control Interface
        INC_IN                          =>     tile_inc_in(x),--tile0_inc_in0_i,
        INC_OUT                         =>     tile_inc_out(x),--tile0_inc_out0_i,
        PATTERN_MATCH_N                 =>     tile_matchn(x),--tile0_matchn0_i,
        RESET_ON_ERROR                  =>     tile_frame_check_reset(x),--tile0_frame_check0_reset_i,
        -- System Interface
        USER_CLK                        =>     commonUsrClk, --tile0_txusrclk0_i,
        SYSTEM_RESET                    =>     tile_rx_system_reset(x),--tile0_rx_system_reset0_c,
        ERROR_COUNT                     =>     lb_rx_err_cnt((7+8*x) downto (0+8*x)), --tile0_error_count0_i
		
		--
		lb_a							=> lb_a(5 downto 2),
		lb_di							=> lb_di,
		lb_do							=> rx_do(x),
		lb_we							=> lb_we,
		lb_en							=> rx_en(x),
		lb_clk							=> lb_clk,
		lb_rx_ok						=> lb_rx_ok(x),
		lb_sz							=> lb_rx_sz(x),
		lb_done							=> lb_rx_done(x)
    );
    
  
end generate g_txrx;

    -- If Chipscope is not being used, drive GTP reset signal
    -- from the top level ports
	  tile0_gtpreset_i                        <= gtp_rst;
      tile1_gtpreset_i                        <= gtp_rst;

	process (lb_clk)
	begin
		if rising_edge(lb_clk) then
	
			tile0_plllkdet_i_r          <= tile0_plllkdet_i;
			tile0_plllkdet_i_r2         <= tile0_plllkdet_i_r;

			tile1_plllkdet_i_r          <= tile1_plllkdet_i;
			tile1_plllkdet_i_r2         <= tile1_plllkdet_i_r;
			
		end if;
	end process;
	
	-- Clock domain crossing 
	process(commonUsrClk)
	begin
		if rising_edge(commonUsrClk) then
			user_rx_reset_i_r <= rx_rst;
			user_rx_reset_i_r2 <= user_rx_reset_i_r;
		
			user_tx_reset_i_r <= tx_rst;
			user_tx_reset_i_r2 <= user_tx_reset_i_r;
		end if;
	end process;
	
end RTL;

