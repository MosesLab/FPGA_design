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
--  /   /         Filename: mig20_infrastructure.vhd
-- /___/   /\     Date Last Modified: $Date: 2007/09/21 15:23:31 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   Clock generation/distribution and reset synchronization
--Reference:
--Revision History:
-- MF : change clock interface
--*****************************************************************************


library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity mig20_infrastructure is
  generic (
    CLK_PERIOD    : integer := 5000;
    DLL_FREQ_MODE : string  := "HIGH";
    RST_ACT_LOW   : integer := 1
    );
  port (
  	--sys_clk_p       : in std_logic;
    --sys_clk_n       : in std_logic;
    --clk200_p        : in std_logic;
    --clk200_n        : in std_logic;
	sys_clk_i		: in std_logic;
	clk200_i		: in std_logic;
	dcmClkInLock	: in std_logic;
    clk0            : out std_logic;
    clk90           : out std_logic;
    clk200          : out std_logic;
    clkdiv0         : out std_logic;

    sys_rst_n       : in  std_logic;
    idelay_ctrl_rdy : in  std_logic;
    rst0            : out std_logic;
    rst90           : out std_logic;
    rst200          : out std_logic;
    rstdiv0         : out std_logic
    );
end entity mig20_infrastructure;

architecture syn of mig20_infrastructure is

  -- # of clock cycles to delay deassertion of reset. Needs to be a fairly
  -- high number not so much for metastability protection, but to give time
  -- for reset (i.e. stable clock cycles) to propagate through all state
  -- machines and to all control signals (i.e. not all control signals have
  -- resets, instead they rely on base state logic being reset, and the effect
  -- of that reset propagating through the logic). Need this because we may not
  -- be getting stable clock cycles while reset asserted (i.e. since reset
  -- depends on DCM lock status)
  constant RST_SYNC_NUM  : integer := 25;

  constant CLK_PERIOD_NS : real := (real(CLK_PERIOD)) / 1000.0;

  signal clk0_bufg      : std_logic;
  signal clk90_bufg     : std_logic;
  signal clk200_bufg    : std_logic;
  signal clkdiv0_bufg   : std_logic;
  signal clk200_ibufg   : std_logic;
  signal dcm_clk0       : std_logic;
  signal dcm_clk90      : std_logic;
  signal dcm_clkdiv0    : std_logic;
  signal dcm_lock       : std_logic;
  signal rst0_sync_r    : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rst200_sync_r  : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rst90_sync_r   : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rstdiv0_sync_r : std_logic_vector((RST_SYNC_NUM/2)-1 downto 0);
  signal rst_tmp        : std_logic;
  signal sys_clk_ibufg  : std_logic;
  signal sys_rst        : std_logic;

  attribute max_fanout : string;
  attribute syn_maxfan : integer;
  attribute max_fanout of rst0_sync_r    : signal is "10";
  attribute syn_maxfan of rst0_sync_r    : signal is 10;
  attribute max_fanout of rst200_sync_r  : signal is "10";
  attribute syn_maxfan of rst200_sync_r  : signal is 10;
  attribute max_fanout of rst90_sync_r   : signal is "10";
  attribute syn_maxfan of rst90_sync_r   : signal is 10;
  attribute max_fanout of rstdiv0_sync_r : signal is "10";
  attribute syn_maxfan of rstdiv0_sync_r : signal is 10;

	signal dcmRst : std_logic;
begin

  sys_rst <= not(sys_rst_n) when (RST_ACT_LOW /= 0) else sys_rst_n;

dcmRst <= sys_rst or not(dcmClkInLock);

  clk0    <= clk0_bufg;
  clk90   <= clk90_bufg;
  clk200  <= clk200_bufg;
  clkdiv0 <= clkdiv0_bufg;

  --***************************************************************************
  -- Differential input clock input buffers
  --***************************************************************************

--  u_ibufg_sys_clk : IBUFGDS_LVPECL_25
--    port map (
--      I  => sys_clk_p,
--      IB => sys_clk_n,
--      O  => sys_clk_ibufg
--      );

--  u_ibufg_clk200 : IBUFGDS_LVPECL_25
--    port map (
--      I  => clk200_p,
--      IB => clk200_n,
--      O  => clk200_ibufg
--      );

--IBUFG_inst : IBUFG
--port map (
--O => sys_clk_ibufg,
--I => sys_clk_i
--);
--
--IBUFG_inst2 : IBUFG
--port map (
--O => clk200_ibufg,
--I => clk200_i
--);

	sys_clk_ibufg <= sys_clk_i;
	clk200_ibufg <= clk200_i;

  --***************************************************************************
  -- Global clock generation and distribution
  --***************************************************************************

  u_dcm_base : DCM_BASE
    generic map (
      CLKIN_PERIOD          => CLK_PERIOD_NS,
      CLKDV_DIVIDE          => 2.0,
      DLL_FREQUENCY_MODE    => DLL_FREQ_MODE,
      DUTY_CYCLE_CORRECTION => true,
      FACTORY_JF            => X"F0F0"
      )
    port map (
      CLK0                  => dcm_clk0,	--200-MHz
      CLK180                => open,	
      CLK270                => open,
      CLK2X                 => open,
      CLK2X180              => open,
      CLK90                 => dcm_clk90,	--200-MHz
      CLKDV                 => dcm_clkdiv0,	--100-MHz
      CLKFX                 => open,
      CLKFX180              => open,
      LOCKED                => dcm_lock,
      CLKFB                 => clk0_bufg,
      CLKIN                 => sys_clk_ibufg, --200-MHz
      RST                   => dcmRst
      );

  u_bufg_clk0 : BUFG
    port map (
      O => clk0_bufg,
      I => dcm_clk0
      );

  u_bufg_clk90 : BUFG
    port map (
      O => clk90_bufg,
      I => dcm_clk90
      );

  u_bufg_clk200 : BUFG
    port map (
      O => clk200_bufg,
      I => clk200_ibufg
      );

  u_bufg_clkdiv0 : BUFG
    port map (
      O  => clkdiv0_bufg,
      I  => dcm_clkdiv0
    );



  --***************************************************************************
  -- Reset synchronization
  -- NOTES:
  --   1. shut down the whole operation if the DCM hasn't yet locked (and by
  --      inference, this means that external SYS_RST_IN has been asserted -
  --      DCM deasserts DCM_LOCK as soon as SYS_RST_IN asserted)
  --   2. In the case of all resets except rst200, also assert reset if the
  --      IDELAY master controller is not yet ready
  --   3. asynchronously assert reset. This was we can assert reset even if
  --      there is no clock (needed for things like 3-stating output buffers).
  --      reset deassertion is synchronous.
  --***************************************************************************

  rst_tmp <= sys_rst or not(dcm_lock) or not(idelay_ctrl_rdy);

  process (clk0_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst0_sync_r <= (others => '1');
    elsif (rising_edge(clk0_bufg)) then
      -- logical left shift by one (pads with 0)
      rst0_sync_r <= rst0_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  process (clkdiv0_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rstdiv0_sync_r <= (others => '1');
    elsif (rising_edge(clkdiv0_bufg)) then
      -- logical left shift by one (pads with 0)
      rstdiv0_sync_r <= rstdiv0_sync_r((RST_SYNC_NUM/2)-2 downto 0) & '0';
    end if;
  end process;

  process (clk90_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst90_sync_r <= (others => '1');
    elsif (rising_edge(clk90_bufg)) then
      rst90_sync_r <= rst90_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  -- make sure CLK200 doesn't depend on IDELAY_CTRL_RDY, else chicken n' egg
  process (clk200_bufg, dcm_lock)
  begin
    if ((not(dcm_lock)) = '1') then
      rst200_sync_r <= (others => '1');
    elsif (rising_edge(clk200_bufg)) then
      rst200_sync_r <= rst200_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  rst0    <= rst0_sync_r(RST_SYNC_NUM-1);
  rst90   <= rst90_sync_r(RST_SYNC_NUM-1);
  rst200  <= rst200_sync_r(RST_SYNC_NUM-1);
  rstdiv0 <= rstdiv0_sync_r((RST_SYNC_NUM/2)-1);

end architecture syn;


