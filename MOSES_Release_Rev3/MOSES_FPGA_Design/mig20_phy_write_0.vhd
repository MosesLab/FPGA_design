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
--  /   /         Filename: mig20_phy_write_0.vhd
-- /___/   /\     Date Last Modified: $Date: 2007/09/21 15:23:31 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--Reference:
--   Handles delaying various write control signals appropriately depending
--   on CAS latency, additive latency, etc. Also splits the data and mask in
--   rise and fall buses.
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mig20_phy_write_0 is
  generic (
    DQ_WIDTH       :     integer := 32;
    ADDITIVE_LAT   :     integer := 0;
    CAS_LAT        :     integer := 3;
    ECC_ENABLE     :     integer := 0;
    ODT_TYPE       :     integer := 3;
    REG_ENABLE     :     integer := 0;
    DDR_TYPE       :     integer := 1
    );
  port (
    clk0              : in  std_logic;
    clk90             : in  std_logic;
    rst90             : in  std_logic;
    wdf_data          : in  std_logic_vector((2*DQ_WIDTH)-1 downto 0);
    wdf_mask_data     : in  std_logic_vector((2*DQ_WIDTH/8)-1 downto 0);
    ctrl_wren         : in  std_logic;
    phy_init_wren     : in  std_logic;
    phy_init_data_sel : in  std_logic;
    dm_ce             : out std_logic;
    dq_oe_n           : out std_logic_vector(1 downto 0);
    dqs_oe_n          : out std_logic;
    dqs_rst_n         : out std_logic;
    wdf_rden          : out std_logic;
    odt               : out std_logic;
    wr_data_rise      : out std_logic_vector(DQ_WIDTH-1 downto 0);
    wr_data_fall      : out std_logic_vector(DQ_WIDTH-1 downto 0);
    mask_data_rise    : out std_logic_vector((DQ_WIDTH/8)-1 downto 0);
    mask_data_fall    : out std_logic_vector((DQ_WIDTH/8)-1 downto 0)
    );
end entity mig20_phy_write_0;

architecture syn of mig20_phy_write_0 is

  function and_br (val : std_logic_vector) return std_logic is
    variable rtn : std_logic := '1';
  begin
    for index in val'range loop
      rtn := rtn and val(index);
    end loop;
    return(rtn);
  end and_br;

  function or_br (val : std_logic_vector) return std_logic is
    variable rtn : std_logic := '0';
  begin
    for index in val'range loop
      rtn := rtn or val(index);
    end loop;
    return(rtn);
  end or_br;

  constant MASK_WIDTH : integer := DQ_WIDTH / 8;
  constant DDR1       : integer := 0;
  constant DDR2       : integer := 1;
  constant DDR3       : integer := 2;

  -- (MIN,MAX) value of WR_LATENCY for DDR1:
  --   REG_ENABLE   = (0,1)
  --   ECC_ENABLE   = (0,1)
  --   Write latency = 1
  --   Total: (1,3)
  -- (MIN,MAX) value of WR_LATENCY for DDR2:
  --   REG_ENABLE   = (0,1)
  --   ECC_ENABLE   = (0,1)
  --   Write latency = ADDITIVE_CAS + CAS_LAT - 1 = (0,4) + (3,5) - 1 = (2,8)
  --     ADDITIVE_LAT = (0,4) (JEDEC79-2B)
  --     CAS_LAT      = (3,5) (JEDEC79-2B)
  --   Total: (2,10)
  function CALC_WR_LAT return integer is
  begin
    if (DDR_TYPE = DDR3) then
      return (ADDITIVE_LAT + CAS_LAT + REG_ENABLE);
    elsif (DDR_TYPE = DDR2) then
      return (ADDITIVE_LAT + (CAS_LAT-1) + REG_ENABLE);
    else
      return (1 + REG_ENABLE);
    end if;
  end function CALC_WR_LAT;

  constant WR_LATENCY : integer := CALC_WR_LAT;

  -- NOTE that ODT timing does not need to be delayed for registered
  -- DIMM case, since like other control/address signals, it gets
  -- delayed by one clock cycle at the DIMM
  constant ODT_WR_LATENCY : integer := WR_LATENCY - REG_ENABLE;

  signal dm_ce_0            : std_logic;
  signal dm_ce_r            : std_logic;
  signal dq_oe_0            : std_logic_vector(1 downto 0);
  signal dq_oe_n_90_r1      : std_logic_vector(1 downto 0);
  signal dq_oe_270          : std_logic_vector(1 downto 0);
  signal dqs_oe_0           : std_logic;
  signal dqs_oe_270         : std_logic;
  signal dqs_oe_n_180_r1    : std_logic;
  signal dqs_rst_0          : std_logic;
  signal dqs_rst_n_180_r1   : std_logic;
  signal dqs_rst_270        : std_logic;
  signal ecc_dm_error_r     : std_logic;
  signal ecc_dm_error_r1    : std_logic;
  signal init_data_f        : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal init_data_r        : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal init_wdf_cnt_r     : unsigned(3 downto 0);
  signal odt_0              : std_logic;
  signal rst90_r            : std_logic;
  signal wr_stages          : std_logic_vector(10 downto 0);
  signal wdf_data_r         : std_logic_vector((2*DQ_WIDTH)-1 downto 0);
  signal wdf_mask_r         : std_logic_vector((2*DQ_WIDTH/8)-1 downto 0);
  signal wdf_mask_r1        : std_logic_vector((2*DQ_WIDTH/8)-1 downto 0);
  signal wdf_rden_0         : std_logic;
  signal calib_rden_90_r    : std_logic;
  signal wdf_rden_90_r      : std_logic;
  signal wdf_rden_90_r1     : std_logic;
  signal wdf_rden_270       : std_logic;

  attribute syn_maxfan : integer;
  attribute syn_maxfan of rst90_r : signal is 10;

begin

  process (clk90)
  begin
    if (rising_edge(clk90)) then
      rst90_r <= rst90;
    end if;
  end process;

  --***************************************************************************
  -- Analysis of additional pipeline delays:
  --   1. dq_oe (DQ 3-state): 1 CLK90 cyc in IOB 3-state FF
  --   2. dqs_oe (DQS 3-state): 1 CLK180 cyc in IOB 3-state FF
  --   3. dqs_rst (DQS output value reset): 1 CLK180 cyc in FF + 1 CLK180 cyc
  --      in IOB DDR
  --   4. odt (ODT control): 1 CLK0 cyc in IOB FF
  --   5. write data (output two cyc after wdf_rden - output of RAMB_FIFO w/
  --      output register enabled): 2 CLK90 cyc in OSERDES
  --***************************************************************************

  -- DQS 3-state must be asserted one extra clock cycle due b/c of write
  -- pre- and post-amble (extra half clock cycle for each)
  dqs_oe_0 <= wr_stages(WR_LATENCY-1) or wr_stages(WR_LATENCY-2);

  -- same goes for ODT, need to handle both pre- and post-amble (generate
  -- ODT only for DDR2)
  -- ODT generation for DDR2 based on write latency. The MIN write
  -- latency is 2. Based on the write latency ODT is asserted.
  gen_odt_ddr2_ddr3: if ((DDR_TYPE /= DDR1) and (ODT_TYPE > 0)) generate
    gen_odt_ddr2_ddr3_wl_gt2: if (ODT_WR_LATENCY > 2) generate
      odt_0 <= wr_stages(ODT_WR_LATENCY-1) or
               wr_stages(ODT_WR_LATENCY-2) or
               wr_stages(ODT_WR_LATENCY-3);
    end generate;
    gen_odt_ddr2_ddr3_wl_eq2: if (ODT_WR_LATENCY = 2) generate
      odt_0 <= wr_stages(ODT_WR_LATENCY) or
               wr_stages(ODT_WR_LATENCY-1) or
               wr_stages(ODT_WR_LATENCY-2);
    end generate;
  end generate;

  gen_odt_ddr1: if ((DDR_TYPE = DDR1) or (ODT_TYPE = 0)) generate
    odt_0 <= '0';
  end generate;

  dq_oe_0(0) <= wr_stages(WR_LATENCY-1) or wr_stages(WR_LATENCY);
  dq_oe_0(1) <= wr_stages(WR_LATENCY-1) or wr_stages(WR_LATENCY-2);
  dqs_rst_0  <= not(wr_stages(WR_LATENCY-2));
  dm_ce_0    <= wr_stages(WR_LATENCY) or wr_stages(WR_LATENCY-1) or
                wr_stages(WR_LATENCY-2);

  -- write data fifo, read flag assertion
  gen_wdf_ddr2: if (DDR_TYPE /= DDR1) generate
    gen_wdf_ddr2_wl_gt2: if (WR_LATENCY > 2) generate
      wdf_rden_0 <= wr_stages(WR_LATENCY-3);
    end generate;
    gen_wdf_ddr2_wl_eq2: if (WR_LATENCY = 2) generate
      wdf_rden_0 <= wr_stages(WR_LATENCY-2);
    end generate;
  end generate;

  gen_wdf_ddr1: if (DDR_TYPE = DDR1) generate
    wdf_rden_0 <= wr_stages(WR_LATENCY-2);
  end generate;

  -- first stage isn't registered
  process (ctrl_wren, phy_init_data_sel, phy_init_wren)
  begin
    -- synthesis attribute max_fanout of wr_stages[10:0] is 2
    if (phy_init_data_sel = '1') then
      wr_stages(0) <= ctrl_wren;
    else
      wr_stages(0) <= phy_init_wren;
    end if;
  end process;

  process (clk0)
  begin
    if (rising_edge(clk0)) then
      wr_stages(1)  <= wr_stages(0);
      wr_stages(2)  <= wr_stages(1);
      wr_stages(3)  <= wr_stages(2);
      wr_stages(4)  <= wr_stages(3);
      wr_stages(5)  <= wr_stages(4);
      wr_stages(6)  <= wr_stages(5);
      wr_stages(7)  <= wr_stages(6);
      wr_stages(8)  <= wr_stages(7);
      wr_stages(9)  <= wr_stages(8);
      wr_stages(10) <= wr_stages(9);
    end if;
  end process;

  -- intermediate synchronization to CLK270
  process (clk90)
  begin
    if (falling_edge(clk90)) then
      dq_oe_270    <= dq_oe_0;
      dqs_oe_270   <= dqs_oe_0;
      dqs_rst_270  <= dqs_rst_0;
      wdf_rden_270 <= wdf_rden_0;
    end if;
  end process;

  -- synchronize DQS signals to CLK180
  process (clk0)
  begin
    if (falling_edge(clk0)) then
      dqs_oe_n_180_r1  <= not(dqs_oe_270);
      dqs_rst_n_180_r1 <= not(dqs_rst_270);
    end if;
  end process;

  -- All write data-related signals synced to CLK90
  process (clk90)
  begin
    if (rising_edge(clk90)) then
      dq_oe_n_90_r1 <= not(dq_oe_270);
      wdf_rden_90_r <= wdf_rden_270;
    end if;
  end process;

  -- generate for wdf_rden and calib rden. These signals
  -- are asserted based on write latency. For write
  -- latency of 2, the extra register stage is taken out.

  gen_wdf_rden_0: if (WR_LATENCY > 2) generate
    process (clk90)
    begin
      if (rising_edge(clk90)) then
        -- assert wdf rden only for non calibration opertations
        wdf_rden_90_r1 <= wdf_rden_90_r and phy_init_data_sel;
        -- rden for calibration
        calib_rden_90_r <= wdf_rden_90_r;
      end if;
    end process;
  end generate;

  gen_wdf_rden_1: if (WR_LATENCY <= 2) generate
    process (phy_init_data_sel, wdf_rden_90_r)
    begin
      wdf_rden_90_r1 <= wdf_rden_90_r and phy_init_data_sel;
      calib_rden_90_r <= wdf_rden_90_r;
    end process;
  end generate;

  -- dm CE signal to stop dm oscilation
  process (clk90)
  begin
    if (falling_edge(clk90)) then
      dm_ce_r <= dm_ce_0;
      dm_ce   <= dm_ce_r;
    end if;
  end process;


  -- When in ECC mode the upper byte [71:64] will have the
  -- ECC parity. Mapping the bytes which have valid data
  -- to the upper byte in ecc mode. Also in ecc mode there
  -- is an extra register stage to account for timing.
  gen_ecc_reg_0: if (ECC_ENABLE /= 0) generate
    process (clk90)
    begin
      if (rising_edge(clk90)) then
        if (phy_init_data_sel = '1') then
          wdf_data_r <= wdf_data;
          wdf_mask_r <= (and_br(wdf_mask_data(16 downto 9)) &
                         wdf_mask_data(16 downto 9) &
                         and_br(wdf_mask_data(7 downto 0)) &
                         wdf_mask_data(7 downto 0));
        else
          wdf_data_r <= (init_data_f & init_data_r);
          wdf_mask_r <= (others => '0');
        end if;
      end if;
    end process;
  end generate;

  gen_ecc_reg_1: if (ECC_ENABLE = 0) generate
    process (clk90)
    begin
      if (rising_edge(clk90)) then
        if (phy_init_data_sel = '1') then
          wdf_data_r <= wdf_data;
          wdf_mask_r <= wdf_mask_data;
        else
          wdf_data_r <= (init_data_f & init_data_r);
          wdf_mask_r <= (others => '0');
        end if;
      end if;
    end process;
  end generate;

  -- Error generation block during simulation.
  -- Error will be displayed when all the DM
  -- bits are not zero. The error will be
  -- displayed only during the start of the sequence
  -- for errors that are continous over many cycles.
  gen_ecc_error: if (ECC_ENABLE /= 0) generate
    process (clk90)
    begin
      if (rising_edge(clk90)) then
        --synthesis translate_off
        wdf_mask_r1 <= wdf_mask_r;
        ecc_dm_error_r <= ((not(wdf_mask_r1(17)) and
                            (or_br(wdf_mask_r1(16 downto 9)))) or
                           (not(wdf_mask_r1(8)) and
                            (or_br(wdf_mask_r1(7 downto 0))))) and
                          phy_init_data_sel;
        ecc_dm_error_r1 <= ecc_dm_error_r;
        -- assert the error only once.
        assert (not((ecc_dm_error_r = '1') and (ecc_dm_error_r1 = '0')))
          report "ECC DM ERROR. ";
        -- synthesis translate_on
      end if;
    end process;
  end generate;

  --***************************************************************************
  -- State logic to write calibration training patterns
  --***************************************************************************

  process (clk90)
  begin
    if (rising_edge(clk90)) then
      if (rst90_r = '1') then
        init_wdf_cnt_r <= "0000";
        init_data_r <= (others => 'X');
        init_data_f <= (others => 'X');
      else
        if (calib_rden_90_r = '1') then
          init_wdf_cnt_r <= init_wdf_cnt_r + 1;
        end if;
        case (init_wdf_cnt_r) is
          -- First stage calibration. Pattern (rise/fall) = 1(r)->0(f)
          -- The rise data and fall data are already interleaved in the manner
          -- required for data into the WDF write FIFO
          when X"0" | X"1" | X"2" | X"3" =>
            init_data_r <= (others => '1');
            init_data_f <= (others => '0');
          -- Second stage calibration. Pattern = 1(r)->1(f)->0(r)->0(f)
          when X"4" | X"6" =>
            init_data_r <= (others => '1');
            init_data_f <= (others => '1');
          when X"5" | X"7" =>
            init_data_r <= (others => '0');
            init_data_f <= (others => '0');
          -- Third stage calibration patern = ee(r)->11(f)->ee(r)->11(f)-11(r)
          --                                ee(f)->ee(r)->11(f)->ee(r)
          when X"8" =>
            for i in 0 to (DQ_WIDTH/4)-1 loop
              init_data_r((4*i)+3 downto 4*i) <= X"1";
              init_data_f((4*i)+3 downto 4*i) <= X"E";
            end loop;
          when X"9" =>
            for i in 0 to (DQ_WIDTH/4)-1 loop
              init_data_r((4*i)+3 downto 4*i) <= X"1";
              init_data_f((4*i)+3 downto 4*i) <= X"1";
            end loop;
          when X"A" =>
            for i in 0 to (DQ_WIDTH/4)-1 loop
              init_data_r((4*i)+3 downto 4*i) <= X"E";
              init_data_f((4*i)+3 downto 4*i) <= X"E";
            end loop;
          when X"B" =>
            for i in 0 to (DQ_WIDTH/4)-1 loop
              init_data_r((4*i)+3 downto 4*i) <= X"1";
              init_data_f((4*i)+3 downto 4*i) <= X"E";
            end loop;
          when others =>
            init_data_r <= (others => 'X');
            init_data_f <= (others => 'X');
        end case;
      end if;
    end if;
  end process;

  --***************************************************************************

  process (clk90)
  begin
    if (rising_edge(clk90)) then
      dq_oe_n <= dq_oe_n_90_r1;
    end if;
  end process;

  process (clk0)
  begin
    if (falling_edge(clk0)) then
      dqs_oe_n <= dqs_oe_n_180_r1;
    end if;
  end process;

  -- generate for odt. odt is asserted based on
  --  write latency. For write latency of 2
  --  the extra register stage is taken out.
  process (clk0)
  begin
    if (falling_edge(clk0)) then
      dqs_rst_n <= dqs_rst_n_180_r1;
    end if;
  end process;

  gen_reg_odt_0: if (ODT_WR_LATENCY > 2) generate
    process (clk0)
    begin
      if (rising_edge(clk0)) then
        odt <= odt_0;
      end if;
    end process;
  end generate;

  gen_reg_odt_1: if (ODT_WR_LATENCY <= 2) generate
    process (odt_0)
    begin
      odt <= odt_0;
    end process;
  end generate;

  wdf_rden <= wdf_rden_90_r1;

  --***************************************************************************
  -- Format write data/mask: Data is in format: {fall, rise}
  --***************************************************************************

  wr_data_rise   <= wdf_data_r(DQ_WIDTH-1 downto 0);
  wr_data_fall   <= wdf_data_r((2*DQ_WIDTH)-1 downto DQ_WIDTH);
  mask_data_rise <= wdf_mask_r(MASK_WIDTH-1 downto 0);
  mask_data_fall <= wdf_mask_r((2*MASK_WIDTH)-1 downto MASK_WIDTH);

end architecture syn;


