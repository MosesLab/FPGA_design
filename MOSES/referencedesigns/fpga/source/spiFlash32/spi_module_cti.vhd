-------------------------------------------------------------------------------
-- $Id: spi_module.vhd,v 1.1.2.8 2008/05/14 09:37:44 sanjayk Exp $
-------------------------------------------------------------------------------
--  SPI Module - entity/architecture pair
-------------------------------------------------------------------------------
--
--  ***************************************************************************
--  **  Copyright(C)  2008 Xilinx, Inc. All rights reserved.                 **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        spi_module.vhd
-- Version:         v2.00.b
-- Description:     Serial Peripheral Interface (SPI) Module for interfacing
--                  with a 32-bit PLBv46 Bus.
--
-------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to
--              improve readability.
--
--              spi_module.vhd
-------------------------------------------------------------------------------
-- Author:      MZC
-- History:
--  MZC      1/15/08      -- First version
-- ^^^^^^
--  SK       2/04/08
-- ~~~~~~
-- -- Update the version of the core.
-- -- Added logic to keep "_T" signals in IOB.
-- ^^^^^^
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.STD_LOGIC_ARITH.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- proc common library is used for log2 function from proc_common_pkg
-------------------------------------------------------------------------------


library unisim;
    use unisim.vcomponents.FD;

-------------------------------------------------------------------------------
--                     Definition of Generics
-------------------------------------------------------------------------------:

--  C_SCK_RATIO                 --      2, 4, 16, 32, , , , 1024, 2048 SPI
--                                      clock ratio
--  C_NUM_BITS_REG              --      Width of SPI Control register
--                                      in this module
--  C_NUM_SS_BITS               --      Total number of SS-bits
--  C_NUM_TRANSFER_BITS         --      SPI Serial transfer width.
--                                      Can be 8, 16 or 32 bit wide

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                  Definition of Ports
-------------------------------------------------------------------------------

-- SYSTEM

--  Bus2IP_Clk                  --      Bus to IP clock
--  Reset                       --      Reset Signal

-- OTHER INTERFACE

--  Slave_MODF_strobe           --      Slave mode fault strobe
--  MODF_strobe                 --      Mode fault strobe
--  SR_3_MODF                   --      Mode fault error flag
--  SR_5_Tx_Empty               --      Transmit Empty
--  Control_Reg                 --      Control Register
--  Slave_Select_Reg            --      Slave Select Register
--  Transmit_Data               --      Data Transmit Register Interface
--  Receive_Data                --      Data Receive Register Interface
--  SPIXfer_done                --      SPI transfer done flag
--  DTR_underrun                --      DTR underrun generation signal

-- SPI INTERFACE

--  SCK_I                       --      SPI Bus Clock Input
--  SCK_O                       --      SPI Bus Clock Output
--  SCK_T                       --      SPI Bus Clock 3-state Enable
--                                      (3-state when high)
--  MISO_I                      --      Master out,Slave in Input
--  MISO_O                      --      Master out,Slave in Output
--  MISO_T                      --      Master out,Slave in 3-state Enable
--  MOSI_I                      --      Master in,Slave out Input
--  MOSI_O                      --      Master in,Slave out Output
--  MOSI_T                      --      Master in,Slave out 3-state Enable
--  SPISEL                      --      Local SPI slave select active low input
--                                      has to be initialzed to VCC
--  SS_I                        --      Input of slave select vector
--                                      of length N input where there are
--                                      N SPI devices,but not connected
--  SS_O                        --      One-hot encoded,active low slave select
--                                      vector of length N ouput
--  SS_T                        --      Single 3-state control signal for
--                                      slave select vector of length N
--                                      (3-state when high)
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity spi_module_cti is
 generic
  (
    C_SCK_RATIO           : integer := 4; -- 50 Mhz divided by 4
    --C_NUM_BITS_REG        : integer := 10;
    C_NUM_SS_BITS         : integer := 1;
    C_NUM_TRANSFER_BITS   : integer := 8
  );
 port
  (
    Bus2IP_Clk          : in  std_logic;
    Reset               : in  std_logic;

    SR_3_MODF           : out  std_logic;	-- Mode-Fault Error Flag; from register.  Latched when
											-- modf high
    SR_5_Tx_Empty       : in  std_logic;	-- Transmit Empty
    --Slave_MODF_strobe   : out std_logic;
    --MODF_strobe         : out std_logic;
    --Control_Reg         : in  std_logic_vector(0 to C_NUM_BITS_REG-1);
	modf_Reset			: in std_logic;
	SPI_En				: in std_logic;
    Slave_Select_Reg    : in  std_logic_vector(0 to C_NUM_SS_BITS-1);
    Transmit_Data       : in  std_logic_vector(0 to C_NUM_TRANSFER_BITS-1);
    Receive_Data        : out std_logic_vector(0 to C_NUM_TRANSFER_BITS-1);
    SPIXfer_done        : out std_logic;
    DTR_underrun        : out std_logic;	-- only used in slave mode

  --SPI Interface
    SCK_I               : in  std_logic;
    SCK_O               : out std_logic;
    SCK_T               : out std_logic;

    MISO_I              : in  std_logic;
    MISO_O              : out std_logic;
    MISO_T              : out std_logic;

    MOSI_I              : in  std_logic;
    MOSI_O              : out std_logic;
    MOSI_T              : out std_logic;

    --SPISEL              : in  std_logic;

    SS_I                : in std_logic_vector(0 to C_NUM_SS_BITS-1);
    SS_O                : out std_logic_vector(0 to C_NUM_SS_BITS-1);
    SS_T                : out std_logic

    --control_bit_7_8     : in std_logic_vector(0 to 1)
);
end spi_module_cti;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture imp of spi_module_cti is

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------

function log2(x : natural) return integer is
  variable i  : integer := 0; 
  variable val: integer := 1;
begin 
  if x = 0 then return 0;
  else
    for j in 0 to 29 loop -- for loop for XST 
      if val >= x then null; 
      else
        i := i+1;
        val := val*2;
      end if;
    end loop;
    assert val >= x
      report "Function log2 received argument larger" &
             " than its capability of 2^30. "
      severity failure;
    return i;
  end if;  
end function log2; 

-------------------------------------------------------------------------------
-- spcl_log2 : Performs log2(x) function for value of C_SCK_RATIO > 2
--------------
function spcl_log2(x : natural) return integer is
    variable j  : integer := 0;
    variable k  : integer := 0;
begin
    if(C_SCK_RATIO /= 2) then
        for i in 0 to 11 loop
            if(2**i >= x) then
               if(k = 0) then
                  j := i;
               end if;
               k := 1;
            end if;
        end loop;
        return j;
    else
        return 2;
    end if;
end spcl_log2;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant RESET_ACTIVE : std_logic := '1';
constant COUNT_WIDTH  : INTEGER   := log2(C_NUM_TRANSFER_BITS)+1;

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
signal Ratio_Count               : std_logic_vector
                                   (0 to (spcl_log2(C_SCK_RATIO))-2);
signal Count                     : std_logic_vector
                                   (COUNT_WIDTH downto 0)
                                   := (others => '0');
signal LSB_first                 : std_logic;
signal Mst_Trans_inhibit         : std_logic;
signal Manual_SS_mode            : std_logic;
signal CPHA                      : std_logic;
signal CPOL                      : std_logic;
signal Mst_N_Slv                 : std_logic;
--signal SPI_En                    : std_logic;
signal Loop_mode                 : std_logic;
signal transfer_start            : std_logic;
signal transfer_start_d1         : std_logic;
signal transfer_start_pulse      : std_logic;
signal SPIXfer_done_int          : std_logic;
signal SPIXfer_done_int_d1       : std_logic;
signal SPIXfer_done_int_pulse    : std_logic;
signal SPIXfer_done_int_pulse_d1 : std_logic;
signal sck_o_int                 : std_logic;
signal sck_o_in                  : std_logic;
signal Count_trigger             : std_logic;
signal Count_trigger_d1          : std_logic;
signal Count_trigger_pulse       : std_logic;
signal Sync_Set                  : std_logic;
signal Sync_Reset                : std_logic;
signal Serial_Dout               : std_logic;
signal Serial_Din                : std_logic;
signal Shift_Reg                 : std_logic_vector
                                   (0 to C_NUM_TRANSFER_BITS-1);
signal SS_Asserted               : std_logic;
signal SS_Asserted_1dly          : std_logic;
signal Allow_Slave_MODF_Strobe   : std_logic;
signal Allow_MODF_Strobe         : std_logic;
signal Loading_SR_Reg_int        : std_logic;
signal sck_i_d1                  : std_logic;
signal spisel_d1                 : std_logic;
signal spisel_pulse              : std_logic;
signal rising_edge_sck_i         : std_logic;
signal falling_edge_sck_i        : std_logic;
signal edge_sck_i                : std_logic;

-- signal MODF_strobe_int           : std_logic; -- REDUNDANT
signal master_tri_state_en_control: std_logic;
signal slave_tri_state_en_control: std_logic;
signal Slave_MODF_strobe   :  std_logic;
signal MODF_strobe         :  std_logic;
signal control_bit_7_8     :  std_logic_vector(0 to 1);
signal SR_3_modf_i 					: std_logic;
signal SPISEL : std_logic;


attribute IOB                                   : string;
attribute IOB of SPI_TRISTATE_CONTROL_II        : label is "true";
attribute IOB of SPI_TRISTATE_CONTROL_III       : label is "true";
attribute IOB of SPI_TRISTATE_CONTROL_IV        : label is "true";
attribute IOB of SPI_TRISTATE_CONTROL_V         : label is "true";
attribute IOB of OTHER_RATIO_GENERATE           : label is "true";

-------------------------------------------------------------------------------
-- Architecture Starts
-------------------------------------------------------------------------------

begin
-------------------------------------------------------------------------------
-- Combinatorial operations, set for ST Micro flash
-------------------------------------------------------------------------------
SPIXfer_done                    <= SPIXfer_done_int_pulse_d1;
LSB_first                       <= '0'; -- MSB is first					Control_Reg(0);
Mst_Trans_inhibit               <= '0'; -- Master transactions on		Control_Reg(1);
Manual_SS_mode                  <= '1'; -- always manual, pb controls	Control_Reg(2);
CPHA                            <= '0'; -- Clock phase, 				Control_Reg(5);
CPOL                            <= '0'; -- Clock polarity, active high 	Control_Reg(6);
Mst_N_Slv                       <= '1'; -- fix to master 				Control_Reg(7);
--SPI_En                        <= 										Control_Reg(8);
Loop_mode                       <= '0'; -- disable use of loop moade Control_Reg(9);
MOSI_O                          <= Serial_Dout;
MISO_O                          <= Serial_Dout;

control_bit_7_8(0) <= Mst_N_Slv;  -- CTI: might not be correct
control_bit_7_8(1) <= SPI_En;
SPISEL <= '1';  -- slave select for when this module is slave, which does not happen

--* -------------------------------------------------------------------------------
--* -- MASTER_TRIST_EN_PROCESS : If not master make tristate enabled
--* ----------------------------
master_tri_state_en_control <= '0' when (
                                     (control_bit_7_8(0)='1') and -- decides master_n_slave mode
                                     (control_bit_7_8(1)='1') and -- decide the spi_en
                                     ((MODF_strobe or SR_3_modf_i)='0')
                                     ) else
                            '1';

SPI_TRISTATE_CONTROL_II: component FD
   generic map
        (
        INIT => '1'
        )
   port map
        (
        Q  => SCK_T,
        C  => Bus2IP_Clk,
        D  => master_tri_state_en_control
        );

SPI_TRISTATE_CONTROL_III: component FD
   generic map
        (
        INIT => '1'
        )
   port map
        (
        Q  => MOSI_T,
        C  => Bus2IP_Clk,
        D  => master_tri_state_en_control
        );

SPI_TRISTATE_CONTROL_IV: component FD
   generic map
        (
        INIT => '1'
        )
   port map
        (
        Q  => SS_T,
        C  => Bus2IP_Clk,
        D  => master_tri_state_en_control
        );
--* -------------------------------------------------------------------------------
--* -- SLAVE_TRIST_EN_PROCESS : If not slave make tristate enabled
--* ---------------------------
slave_tri_state_en_control <= '0' when (
                                     (control_bit_7_8(0)='0') and -- decides master_n_slave mode
                                     (control_bit_7_8(1)='1') and -- decide the spi_en
                                     (SPISEL = '0')
                                     ) else
                            '1';

SPI_TRISTATE_CONTROL_V: component FD
   generic map
        (
        INIT => '1'
        )
   port map
        (
        Q  => MISO_T,
        C  => Bus2IP_Clk,
        D  => slave_tri_state_en_control
        );
-------------------------------------------------------------------------------
-- DTR_UNDERRUN_PROCESS : For Generating DTR underrun error
-------------------------
DTR_UNDERRUN_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE or SPISEL = '1' or Mst_N_Slv = '1') then
            DTR_underrun <= '0';
        elsif(Mst_N_Slv = '0' and SPI_En = '1') then
            if (SR_5_Tx_Empty = '1') then
                if(SPIXfer_done_int_pulse_d1 = '1') then
                    DTR_underrun <= '1';
                end if;
            else
                DTR_underrun <= '0';
            end if;
        end if;
    end if;
end process DTR_UNDERRUN_PROCESS;

-------------------------------------------------------------------------------
-- SPISEL_DELAY_1CLK_PROCESS : Detect active SCK edge in slave mode
-----------------------------
SPISEL_DELAY_1CLK_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE) then
            spisel_d1 <= '0';
        else
            spisel_d1 <= SPISEL;
        end if;
    end if;
end process SPISEL_DELAY_1CLK_PROCESS;

-- spisel pulse generating logic
spisel_pulse <= (not SPISEL) and spisel_d1;
-------------------------------------------------------------------------------
-- SCK_I_DELAY_1CLK_PROCESS : Detect active SCK edge in slave mode
-----------------------------
SCK_I_DELAY_1CLK_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE) then
            sck_i_d1 <= '0';
        else
            sck_i_d1 <= SCK_I;
        end if;
    end if;
end process SCK_I_DELAY_1CLK_PROCESS;

-- generate a SCK control pulse for rising edge as well as falling edge
rising_edge_sck_i  <= SCK_I and (not(sck_i_d1)) and (not(SPISEL));
falling_edge_sck_i <= (not(SCK_I) and sck_i_d1) and (not(SPISEL));

-- combine rising edge as well as falling edge as a single signal
edge_sck_i         <= rising_edge_sck_i or falling_edge_sck_i;

-------------------------------------------------------------------------------
-- TRANSFER_START_PROCESS : Generate transfer start signal. When the transfer
--                          gets completed, SPI Transfer done strobe pulls
--                          transfer_start back to zero.
---------------------------
TRANSFER_START_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset             = RESET_ACTIVE or
            (
             Mst_N_Slv         = '1' and  -- If Master Mode
             (
              SPI_En            = '0' or  -- enable not asserted or
              SR_5_Tx_Empty     = '1' or  -- no data in Tx reg/FIFO or
              SR_3_modf_i         = '1' or  -- mode fault error
              Mst_Trans_inhibit = '1'     -- Do not start if Mst xfer inhibited
             )
            ) or
            (
             Mst_N_Slv         = '0' and  -- If Slave Mode
             (
              SPI_En            = '0'   -- enable not asserted or
             )
            )
          )then

            transfer_start <= '0';
        else
-- Delayed SPIXfer_done_int_pulse to work for synchronous design and to remove
-- asserting of loading_sr_reg in master mode after SR_5_Tx_Empty goes to 1
            if(SPIXfer_done_int_pulse = '1' or
               SPIXfer_done_int_pulse_d1 = '1') then
                transfer_start <= '0';     -- Set to 0 for at least 1 period
            else
                transfer_start <= '1';     -- Proceed with SPI Transfer
            end if;
        end if;
    end if;
end process TRANSFER_START_PROCESS;

-------------------------------------------------------------------------------
-- TRANSFER_START_1CLK_PROCESS : Delay transfer start by 1 clock cycle
--------------------------------
TRANSFER_START_1CLK_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE) then
            transfer_start_d1 <= '0';
        else
            transfer_start_d1 <= transfer_start;
        end if;
    end if;
end process TRANSFER_START_1CLK_PROCESS;

-- transfer start pulse generating logic
transfer_start_pulse <= transfer_start and (not(transfer_start_d1));

-------------------------------------------------------------------------------
-- TRANSFER_DONE_PROCESS : Generate SPI transfer done signal
--------------------------
TRANSFER_DONE_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE) then
            SPIXfer_done_int <= '0';
        elsif (transfer_start_pulse = '1') then
            SPIXfer_done_int <= '0';
        elsif (Count(COUNT_WIDTH) = '1') then
            SPIXfer_done_int <= '1';
        end if;
    end if;
end process TRANSFER_DONE_PROCESS;

-------------------------------------------------------------------------------
-- TRANSFER_DONE_1CLK_PROCESS : Delay SPI transfer done signal by 1 clock cycle
-------------------------------
TRANSFER_DONE_1CLK_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE) then
            SPIXfer_done_int_d1 <= '0';
        else
            SPIXfer_done_int_d1 <= SPIXfer_done_int;
        end if;
    end if;
end process TRANSFER_DONE_1CLK_PROCESS;

-- transfer done pulse generating logic
SPIXfer_done_int_pulse <= SPIXfer_done_int and (not(SPIXfer_done_int_d1));

-------------------------------------------------------------------------------
-- TRANSFER_DONE_PULSE_DLY_PROCESS : Delay SPI transfer done pulse by 1 and 2
--                                   clock cycles
------------------------------------
TRANSFER_DONE_PULSE_DLY_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE) then
            SPIXfer_done_int_pulse_d1 <= '0';
        else
            SPIXfer_done_int_pulse_d1 <= SPIXfer_done_int_pulse;
        end if;
    end if;
end process TRANSFER_DONE_PULSE_DLY_PROCESS;

-------------------------------------------------------------------------------
-- RECEIVE_DATA_STROBE_PROCESS : Strobe data from shift register to receive
--                               data register
--------------------------------
RECEIVE_DATA_STROBE_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(SPIXfer_done_int_pulse = '1') then
            if (LSB_first = '1') then
                for i in 0 to C_NUM_TRANSFER_BITS-1 loop
                    Receive_Data(i) <= Shift_Reg(C_NUM_TRANSFER_BITS-1-i);
                end loop;
            else
                Receive_Data <= Shift_Reg;
            end if;
        end if;
    end if;
end process RECEIVE_DATA_STROBE_PROCESS;

-------------------------------------------------------------------------------
-- OTHER_RATIO_GENERATE : Logic to be used when C_SCK_RATIO is not equal to 2
-------------------------
OTHER_RATIO_GENERATE: if(C_SCK_RATIO /= 2) generate
begin
-----
-------------------------------------------------------------------------------
-- EXTERNAL_INPUT_OR_LOOP_PROCESS : Select between external data input and
--                                  internal looped data (serial data out to
--                                  serial data in)
-----------------------------------
  EXTERNAL_INPUT_OR_LOOP_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(SPI_En = '0' or Reset = RESET_ACTIVE) then
              Serial_Din <= '0';      --Clear when disabled SPI device or reset
          elsif(Mst_N_Slv = '1' and Count (0) = '0') then
              if(Loop_mode = '1') then        --Loop mode
                  Serial_Din <= Serial_Dout;  --Loop data in shift register
              else
                  Serial_Din <= MISO_I;
              end if;
          elsif(Mst_N_Slv = '0') then
              Serial_Din <= MOSI_I;
          end if;
      end if;
  end process EXTERNAL_INPUT_OR_LOOP_PROCESS;

-------------------------------------------------------------------------------
-- RATIO_COUNT_PROCESS : Counter which counts from (C_SCK_RATIO/2)-1 down to 0
--                       Used for counting the time to control SCK_O generation
--                       depending on C_SCK_RATIO
------------------------
  RATIO_COUNT_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE or transfer_start = '0') then
              Ratio_Count <= CONV_STD_LOGIC_VECTOR(
                             (C_SCK_RATIO/2)-1,spcl_log2(C_SCK_RATIO)-1);
          else
              Ratio_Count <= Ratio_Count - 1;
              if (Ratio_Count = 0) then
                  Ratio_Count <= CONV_STD_LOGIC_VECTOR(
                                 (C_SCK_RATIO/2)-1,spcl_log2(C_SCK_RATIO)-1);
              end if;
          end if;
      end if;
  end process RATIO_COUNT_PROCESS;

-------------------------------------------------------------------------------
-- COUNT_TRIGGER_GEN_PROCESS : Generate a trigger whenever Ratio_Count reaches
--                             zero
------------------------------
  COUNT_TRIGGER_GEN_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE or transfer_start = '0') then
              Count_trigger <= '0';
          elsif(Ratio_Count = 0) then
              Count_trigger <= not Count_trigger;
          end if;
      end if;
  end process COUNT_TRIGGER_GEN_PROCESS;

-------------------------------------------------------------------------------
-- COUNT_TRIGGER_1CLK_PROCESS : Delay cnt_trigger signal by 1 clock cycle
-------------------------------
  COUNT_TRIGGER_1CLK_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE or transfer_start = '0') then
              Count_trigger_d1 <= '0';
          else
              Count_trigger_d1 <=  Count_trigger;
          end if;
      end if;
  end process COUNT_TRIGGER_1CLK_PROCESS;

 -- generate a trigger pulse for rising edge as well as falling edge
  Count_trigger_pulse <= (Count_trigger and (not(Count_trigger_d1))) or
                        ((not(Count_trigger)) and Count_trigger_d1);

-------------------------------------------------------------------------------
-- SCK_CYCLE_COUNT_PROCESS : Counts number of trigger pulses provided. Used for
--                           controlling the number of bits to be transfered
--                           based on generic C_NUM_TRANSFER_BITS
----------------------------
  SCK_CYCLE_COUNT_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE) then
              Count <= (others => '0');
          elsif (Mst_N_Slv = '1') then
              if (transfer_start = '0') then
                  Count <= (others => '0');
              elsif (Count_trigger_pulse = '1') then
                  Count <=  Count + 1;
                  if (Count(COUNT_WIDTH) = '1') then
                      Count <= (others => '0');
                  end if;
              end if;
          elsif (Mst_N_Slv = '0') then
              if (transfer_start = '0' or SPISEL = '1') then
                  Count <= (others => '0');
              elsif (edge_sck_i = '1') then
                  Count <=  Count + 1;
                  if (Count(COUNT_WIDTH) = '1') then
                      Count <= (others => '0');
                  end if;
              end if;
          end if;
      end if;
  end process SCK_CYCLE_COUNT_PROCESS;

-------------------------------------------------------------------------------
-- SCK_SET_RESET_PROCESS : Sync set/reset toggle flip flop controlled by
--                         transfer_start signal
--------------------------
  SCK_SET_RESET_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE or Sync_Reset = '1' or Mst_N_Slv='0') then
               sck_o_int <= '0';
          elsif(Sync_Set = '1') then
               sck_o_int <= '1';
          elsif (transfer_start = '1') then
                sck_o_int <= sck_o_int xor Count_trigger_pulse;
          end if;
      end if;
  end process SCK_SET_RESET_PROCESS;

-------------------------------------------------------------------------------
-- CAPTURE_AND_SHIFT_PROCESS : This logic essentially controls the entire
--                             capture and shift operation for serial data
------------------------------
  CAPTURE_AND_SHIFT_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE) then
              Shift_Reg(0) <= '0';
              Shift_Reg(1) <= '1';
              Shift_Reg(2 to C_NUM_TRANSFER_BITS -1) <= (others => '0');
              Serial_Dout <= '1';
          elsif(Mst_N_Slv = '1' and not(Count(COUNT_WIDTH) = '1')) then
              if(Loading_SR_Reg_int = '1') then
                  if(LSB_first = '1') then
                      for i in 0 to C_NUM_TRANSFER_BITS-1 loop
                          Shift_Reg(i) <= Transmit_Data
                                          (C_NUM_TRANSFER_BITS-1-i);
                      end loop;
                      Serial_Dout <= Transmit_Data(C_NUM_TRANSFER_BITS-1);
                  else
                      Shift_Reg   <= Transmit_Data;
                      Serial_Dout <= Transmit_Data(0);
                  end if;
              -- Capture Data on even Count
              elsif(transfer_start = '1' and Count(0) = '0' ) then
                  Serial_Dout <= Shift_Reg(0);
              -- Shift Data on odd Count
              elsif(transfer_start = '1' and Count(0) = '1' and
                      Count_trigger_pulse = '1') then
                  Shift_Reg   <= Shift_Reg
                                 (1 to C_NUM_TRANSFER_BITS -1) & Serial_Din;
              end if;
          elsif(Mst_N_Slv = '0') then
              if(Loading_SR_Reg_int = '1' or spisel_pulse = '1') then
                  if(LSB_first = '1') then
                      for i in 0 to C_NUM_TRANSFER_BITS-1 loop
                          Shift_Reg(i) <= Transmit_Data
                                          (C_NUM_TRANSFER_BITS-1-i);
                      end loop;
                      Serial_Dout <= Transmit_Data(C_NUM_TRANSFER_BITS-1);
                  else
                      Shift_Reg   <= Transmit_Data;
                      Serial_Dout <= Transmit_Data(0);
                  end if;
              elsif (transfer_start = '1') then
                  if((CPOL = '0' and CPHA = '0') or
                      (CPOL = '1' and CPHA = '1')) then
                      if(rising_edge_sck_i = '1') then
                          Shift_Reg   <= Shift_Reg(1 to
                                         C_NUM_TRANSFER_BITS -1) & Serial_Din;
                          Serial_Dout <= Shift_Reg(1);
                      end if;
                  elsif((CPOL = '0' and CPHA = '1') or
                        (CPOL = '1' and CPHA = '0')) then
                      if(falling_edge_sck_i = '1') then
                          Shift_Reg   <= Shift_Reg(1 to
                                         C_NUM_TRANSFER_BITS -1) & Serial_Din;
                          Serial_Dout <= Shift_Reg(1);
                      end if;
                  end if;
              end if;
          end if;
      end if;
  end process CAPTURE_AND_SHIFT_PROCESS;
-----
end generate OTHER_RATIO_GENERATE;

-------------------------------------------------------------------------------
-- RATIO_OF_2_GENERATE : Logic to be used when C_SCK_RATIO is equal to 2
------------------------
RATIO_OF_2_GENERATE: if(C_SCK_RATIO = 2) generate
begin
-----
-------------------------------------------------------------------------------
-- EXTERNAL_INPUT_OR_LOOP_PROCESS : Select between external data input and
--                                  internal looped data (serial data out to
--                                  serial data in)
-----------------------------------
  EXTERNAL_INPUT_OR_LOOP_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(SPI_En = '0' or Reset = RESET_ACTIVE) then
              Serial_Din <= '0';  --Clear when disabled SPI device or reset
          elsif(Mst_N_Slv = '1' and Count (0) = '0' and
              Count(COUNT_WIDTH) = '0') then
              if(Loop_mode = '1') then       --Loop mode
                  if ( Loading_SR_Reg_int = '1') then
                      if (LSB_first = '1') then
                          Serial_Din <= Transmit_Data(C_NUM_TRANSFER_BITS-1);
                      else
                          Serial_Din <= Transmit_Data(0); --Loop data
                      end if;
                  else
                      Serial_Din <= Shift_Reg(0);         --Loop data
                  end if;
              else
                  Serial_Din <= MISO_I;
              end if;
          elsif(Mst_N_Slv = '0') then
              Serial_Din <= MOSI_I;
          end if;
      end if;
  end process EXTERNAL_INPUT_OR_LOOP_PROCESS;

-------------------------------------------------------------------------------
-- SCK_CYCLE_COUNT_PROCESS : Counts number of trigger pulses provided. Used for
--                           controlling the number of bits to be transfered
--                           based on generic C_NUM_TRANSFER_BITS
----------------------------
  SCK_CYCLE_COUNT_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE or transfer_start_d1 = '0' or Mst_N_Slv = '0') then
              Count <= (others => '0');
          elsif (Count(COUNT_WIDTH) = '0') then
              Count <=  Count + 1;
          end if;
      end if;
  end process SCK_CYCLE_COUNT_PROCESS;

-------------------------------------------------------------------------------
-- SCK_SET_RESET_PROCESS : Sync set/reset toggle flip flop controlled by
--                         transfer_start signal
--------------------------
  SCK_SET_RESET_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE or Sync_Reset = '1') then
              sck_o_int <= '0';
          elsif(Sync_Set = '1') then
              sck_o_int <= '1';
          elsif (transfer_start = '1') then
              sck_o_int <= (not sck_o_int) xor Count(COUNT_WIDTH);
          end if;
      end if;
  end process SCK_SET_RESET_PROCESS;

-------------------------------------------------------------------------------
-- CAPTURE_AND_SHIFT_PROCESS : This logic essentially controls the entire
--                             capture and shift operation for serial data
------------------------------
  CAPTURE_AND_SHIFT_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          if(Reset = RESET_ACTIVE) then
              Shift_Reg(0) <= '0';
              Shift_Reg(1) <= '1';
              Shift_Reg(2 to C_NUM_TRANSFER_BITS -1) <= (others => '0');
              Serial_Dout  <= '1';
          elsif(Mst_N_Slv = '1') then
              if(Loading_SR_Reg_int = '1') then
                  if(LSB_first = '1') then
                      for i in 0 to C_NUM_TRANSFER_BITS-1 loop
                         Shift_Reg(i) <= Transmit_Data
                                         (C_NUM_TRANSFER_BITS-1-i);
                      end loop;
                      Serial_Dout <= Transmit_Data(C_NUM_TRANSFER_BITS-1);
                  else
                      Shift_Reg   <= Transmit_Data;
                      Serial_Dout <= Transmit_Data(0);
                  end if;
              elsif(transfer_start = '1' and Count(0) = '0' and
                  Count(COUNT_WIDTH) = '0') then -- Capture Data on even
                  Serial_Dout <= Shift_Reg(0);
              elsif(transfer_start = '1' and Count(0) = '1' and
                  Count(COUNT_WIDTH) = '0') then -- Shift Data on odd
                  if(Loop_mode = '1') then       --Loop mode
                      Shift_Reg   <= Shift_Reg(1 to
                                     C_NUM_TRANSFER_BITS -1) & Serial_Din;
                  else
                      Shift_Reg   <= Shift_Reg(1 to
                                     C_NUM_TRANSFER_BITS -1) & MISO_I;
                  end if;
              end if;
          elsif(Mst_N_Slv = '0') then
              -- Added to have consistent default value after reset
              if(Loading_SR_Reg_int = '1' or spisel_pulse = '1') then
                  Shift_Reg   <= (others => '0');
                  Serial_Dout <= '0';
              end if;
          end if;
      end if;
  end process CAPTURE_AND_SHIFT_PROCESS;
-----
end generate RATIO_OF_2_GENERATE;

-------------------------------------------------------------------------------
-- SCK_SET_GEN_PROCESS : Generate SET control for SCK_O
------------------------
SCK_SET_GEN_PROCESS: process(CPOL,CPHA,transfer_start_pulse)
begin
    if(transfer_start_pulse = '1') then
        Sync_Set <= (CPOL xor CPHA);
    else
        Sync_Set <= '0';
    end if;
end process SCK_SET_GEN_PROCESS;

-------------------------------------------------------------------------------
-- SCK_RESET_GEN_PROCESS : Generate SET control for SCK_O
--------------------------
SCK_RESET_GEN_PROCESS: process(CPOL,CPHA,transfer_start_pulse)
begin
    if(transfer_start_pulse = '1') then
        Sync_Reset <= not(CPOL xor CPHA);
    else
        Sync_Reset <= '0';
    end if;
end process SCK_RESET_GEN_PROCESS;

-------------------------------------------------------------------------------
-- RATIO_NOT_EQUAL_4_GENERATE : Logic to be used when C_SCK_RATIO is not equal
--                              to 4
-------------------------------
RATIO_NOT_EQUAL_4_GENERATE: if(C_SCK_RATIO /= 4) generate
begin
-----
-------------------------------------------------------------------------------
-- SCK_O_SELECT_PROCESS : Select the idle state (CPOL bit) when not transfering
--                        data else select the clock for slave device
-------------------------
  SCK_O_SELECT_PROCESS: process(sck_o_int,CPOL,transfer_start,
                                transfer_start_d1,Count(COUNT_WIDTH))
  begin
      if(transfer_start = '1' and transfer_start_d1 = '1' and
          Count(COUNT_WIDTH) = '0') then
          sck_o_in <= sck_o_int;
      else
          sck_o_in <= CPOL;
      end if;
  end process SCK_O_SELECT_PROCESS;

-------------------------------------------------------------------------------
-- SCK_O_FINAL_PROCESS : Register the final SCK_O
------------------------
  SCK_O_FINAL_PROCESS: process(Bus2IP_Clk)
  begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
          -- If Reset or slave Mode. Prevents SCK_O to be generated in slave
          if(Reset = RESET_ACTIVE or Mst_N_Slv = '0') then
              SCK_O <= '0';
          else
              SCK_O <= sck_o_in;
          end if;
      end if;
  end process SCK_O_FINAL_PROCESS;
-----
end generate RATIO_NOT_EQUAL_4_GENERATE;


-------------------------------------------------------------------------------
-- RATIO_OF_4_GENERATE : Logic to be used when C_SCK_RATIO is equal to 4
------------------------
RATIO_OF_4_GENERATE: if(C_SCK_RATIO = 4) generate
begin
-----
-------------------------------------------------------------------------------
-- SCK_O_FINAL_PROCESS : Select the idle state (CPOL bit) when not transfering
--                       data else select the clock for slave device
------------------------
-- A work around to reduce one clock cycle for sck_o generation. This would
-- allow for proper shifting of data bits into the slave device.
-- Removing the final stage F/F. Disadvantage of not registering final output
-------------------------------------------------------------------------------
   SCK_O_FINAL_PROCESS: process(Mst_N_Slv,sck_o_int,CPOL,transfer_start,
                                transfer_start_d1,Count(COUNT_WIDTH))
   begin
-----
    if(Mst_N_Slv = '1' and transfer_start = '1' and transfer_start_d1 = '1' and
         Count(COUNT_WIDTH) = '0') then
         SCK_O <= sck_o_int;
    else
         SCK_O <= CPOL and Mst_N_Slv;
    end if;
   end process SCK_O_FINAL_PROCESS;

end generate RATIO_OF_4_GENERATE;

-------------------------------------------------------------------------------
-- LOADING_FIRST_ELEMENT_PROCESS : Combinatorial process to generate flag
--                                 when loading first data element in shift
--                                 register from transmit register/fifo
----------------------------------
LOADING_FIRST_ELEMENT_PROCESS: process(Reset, SPI_En,Mst_N_Slv,
                                       SS_Asserted,SS_Asserted_1dly,
                                       SR_3_modf_i,transfer_start_pulse)
begin
    if(Reset = RESET_ACTIVE) then
        Loading_SR_Reg_int <= '0';              --Clear flag
    elsif(SPI_En                 = '1'   and    --Enabled
          (
           (Mst_N_Slv              = '1'   and  --Master configuration
            SS_Asserted            = '1'   and
            SS_Asserted_1dly       = '0'   and
            SR_3_modf_i              = '0'
           ) or
           (Mst_N_Slv              = '0'   and  --Slave configuration
            (transfer_start_pulse = '1')
           )
          )
         )then
        Loading_SR_Reg_int <= '1';               --Set flag
    else
        Loading_SR_Reg_int <= '0';               --Clear flag
    end if;
end process LOADING_FIRST_ELEMENT_PROCESS;

-------------------------------------------------------------------------------
-- SELECT_OUT_PROCESS : This process sets SS active-low, one-hot encoded select
--                      bit. Changing SS is premitted during a transfer by
--                      hardware, but is to be prevented by software. In Auto
--                      mode SS_O reflects value of Slave_Select_Reg only
--                      when transfer is in progress, otherwise is SS_O is held
--                      high
-----------------------
SELECT_OUT_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE) then
            SS_O                   <= (others => '1');
            SS_Asserted            <= '0';
            SS_Asserted_1dly       <= '0';
        elsif(transfer_start = '0') then    -- Tranfer not in progress
            if(Manual_SS_mode = '0') then   -- Auto SS assert
                SS_O   <= (others => '1');
            else
                for i in 0 to C_NUM_SS_BITS-1 loop
                    SS_O(i) <= Slave_Select_Reg(C_NUM_SS_BITS-1-i);
                end loop;
            end if;
            SS_Asserted       <= '0';
            SS_Asserted_1dly  <= '0';
        else
            for i in 0 to C_NUM_SS_BITS-1 loop
                SS_O(i) <= Slave_Select_Reg(C_NUM_SS_BITS-1-i);
            end loop;
            SS_Asserted       <= '1';
            SS_Asserted_1dly  <= SS_Asserted;
        end if;
    end if;
end process SELECT_OUT_PROCESS;

-------------------------------------------------------------------------------
-- MODF_STROBE_PROCESS : Strobe MODF signal when master is addressed as slave
------------------------
MODF_STROBE_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE or SPISEL = '1') then
            MODF_strobe       <= '0';
            --MODF_strobe_int   <= '0';
            Allow_MODF_Strobe <= '1';
        elsif(Mst_N_Slv = '1' and --In Master mode
              SPISEL = '0' and Allow_MODF_Strobe = '1') then
            MODF_strobe       <= '1';
            --MODF_strobe_int   <= '1';
            Allow_MODF_Strobe <= '0';
        else
            MODF_strobe       <= '0';
            --MODF_strobe_int   <= '0';
        end if;
    end if;
end process MODF_STROBE_PROCESS;

-------------------------------------------------------------------------------
-- SLAVE_MODF_STROBE_PROCESS : Strobe MODF signal when slave is addressed
--                             but not enabled.
------------------------------
SLAVE_MODF_STROBE_PROCESS: process(Bus2IP_Clk)
begin
    if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(Reset = RESET_ACTIVE or SPISEL = '1') then
            Slave_MODF_strobe      <= '0';
            Allow_Slave_MODF_Strobe<= '1';
        elsif(Mst_N_Slv   = '0' and    --In Slave mode
              SPI_En      = '0' and    --but not enabled
              SPISEL      = '0' and Allow_Slave_MODF_Strobe = '1') then
            Slave_MODF_strobe       <= '1';
            Allow_Slave_MODF_Strobe <= '0';
        else
            Slave_MODF_strobe       <= '0';
        end if;
    end if;
end process SLAVE_MODF_STROBE_PROCESS;


I_modf_REG_PROCESS:process(Bus2IP_Clk)
begin
    if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if (modf_Reset = '1' or Reset = '1') then
            SR_3_modf_i <= '0';
        elsif MODF_strobe = '1' then
            SR_3_modf_i <= '1';
        end if;
    end if;
end process I_modf_REG_PROCESS;

SR_3_modf <= SR_3_modf_i;


end imp;
