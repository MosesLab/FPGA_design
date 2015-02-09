----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:17 10/08/2014 
-- Design Name: 
-- Module Name:    DDR2_BurstController - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity DDR2_BurstController is
	port(
		clk_usr		:in	std_logic;	-- Clock used for the user-logic interface
		clk_ddr2		:in	std_logic;	-- Clock used for the DDR2 interface
		rst_n			:in	std_logic;
		rst_mig		:in	std_logic;
		
		--Instrument Interface
		data_in		:in	std_logic_vector(63 downto 0);
		addr_in		:in	std_logic_vector(30 downto 0);
		cmd_in		:in	std_logic_vector(2 downto 0);
		data_rdy		:in	std_logic;
		addr_rdy		:in	std_logic;
		mask_in		:in	std_logic_vector(7 downto 0);
		
		-- DDR2 Output Control Signals
		app_wdf_wren      :out	std_logic;
		app_af_wren       :out	std_logic;
		app_af_cmd        :out	std_logic_vector(2  downto 0); 
		app_wdf_mask_data :out	std_logic_vector(7  downto 0);
		app_wdf_data      :out	std_logic_vector(63 downto 0);
		app_af_addr       :out	std_logic_vector(30 downto 0);
		rd_data_fifo_out  :in	std_logic_vector(63 downto 0);
		rd_data_valid		:in	std_logic;
		
		-- Data Signals
		read_fifo_data			:out	std_logic_vector(63 downto 0);
		read_fifo_data_empty	:out	std_logic;
		read_fifo_data_en		:in	std_logic;
		read_fifo_rdcount		:out	std_logic_vector(8 downto 0);
		write_data_fifo_empty	:out	std_logic;
		addr_fifo_empty		:out	std_logic;
		rst_rd_fifo				:in	std_logic;
		
		data_read_error	:out	std_logic;
		data_write_error	:out	std_logic;
		addr_write_error	:out	std_logic
	);
end DDR2_BurstController;

architecture Behavioral of DDR2_BurstController is

	signal	rst	:std_logic;
	
	-- ADDRESS CONTROL SIGNALS
	signal	addr_fifo_empty_signal			:std_logic;
	signal	data_fifo_empty_signal			:std_logic;
	signal	addr_in_signal				:std_logic_vector(63 downto 0);
	signal	addr_out_signal			:std_logic_vector(63 downto 0);
	signal	cmd							:std_logic_vector(2 downto 0);
	
	signal	app_wdf_wren_signal 		:std_logic;
	signal	app_af_wren_signal      :std_logic;
	signal	app_af_cmd_signal			:std_logic_vector(2 downto 0);
	
	-- FSM SIGNALS
	type	STATE is (AF_EMPTY, DECODE, READ_TXFR, WRITE_TXFR0, WRITE_TXFR1);
	signal	CurrentState	:STATE	:= AF_EMPTY;
	signal	NextState		:STATE	:= AF_EMPTY;

begin

	rst <= ((not rst_n) or rst_mig);
	
	-- 50-MHz Clock Domain (Inputs)
	addr_in_signal <= "0000000000000000000000" & mask_in & cmd_in & addr_in;
	
	-- 200-MHz Clock Domain (Outputs)
	app_af_addr <= addr_out_signal(30 downto 0);
	app_af_cmd_signal <= addr_out_signal(33 downto 31);
	app_wdf_mask_data <= addr_out_signal(41 downto 34);
	app_wdf_wren <= app_wdf_wren_signal;
	app_af_wren <= app_af_wren_signal;
	app_af_cmd <= app_af_cmd_signal;
	
	-- READ DATA FIFO
	FIFO36_72_READ_DATA : FIFO36_72
   generic map (
      ALMOST_FULL_OFFSET => X"0080",  -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET => X"0080", -- Sets the almost empty threshold
      DO_REG => 1,                    -- Enable output register (0 or 1)
                                      -- Must be 1 if EN_SYN = FALSE 
      EN_ECC_READ => FALSE,           -- Enable ECC decoder, TRUE or FALSE
      EN_ECC_WRITE => FALSE,          -- Enable ECC encoder, TRUE or FALSE
      EN_SYN => FALSE,                -- Specifies FIFO as Asynchronous (FALSE)
                                      -- or Synchronous (TRUE)
      FIRST_WORD_FALL_THROUGH => TRUE, -- Sets the FIFO FWFT to TRUE or FALSE
      SIM_MODE => "SAFE") -- Simulation: "SAFE" vs "FAST", see "Synthesis and Simulation
                          -- Design Guide" for details
   port map (
      ALMOSTEMPTY => open,   -- 1-bit almost empty output flag
      ALMOSTFULL => open,     -- 1-bit almost full output flag
      DBITERR => open,            -- 1-bit double bit error status output
      DO => read_fifo_data,              -- 64-bit data output
      DOP => open,                   -- 4-bit parity data output
      ECCPARITY => open,        -- 8-bit generated error correction parity
      EMPTY => read_fifo_data_empty,               -- 1-bit empty output flag
      FULL => open,                 -- 1-bit full output flag
      RDCOUNT => read_fifo_rdcount,           -- 9-bit read count output
      RDERR => data_read_error,               -- 1-bit read error output
      WRCOUNT => open,           -- 9-bit write count output
      WRERR => open,               -- 1-bit write error
      DI => rd_data_fifo_out,                     -- 64-bit data input
      DIP => (others => '0'),                   -- 4-bit parity input
      RDCLK => clk_usr,               -- 1-bit read clock input
      RDEN => read_fifo_data_en,                 -- 1-bit read enable input
      RST => rst,                   -- 1-bit reset input
      WRCLK => clk_ddr2,               -- 1-bit write clock input
      WREN => rd_data_valid                  -- 1-bit write enable input
   );
	

	-- WRITE DATA FIFO
	FIFO36_72_WRITE_DATA : FIFO36_72
   generic map (
      ALMOST_FULL_OFFSET => X"0080",  -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET => X"0080", -- Sets the almost empty threshold
      DO_REG => 1,                    -- Enable output register (0 or 1)
                                      -- Must be 1 if EN_SYN = FALSE 
      EN_ECC_READ => FALSE,           -- Enable ECC decoder, TRUE or FALSE
      EN_ECC_WRITE => FALSE,          -- Enable ECC encoder, TRUE or FALSE
      EN_SYN => FALSE,                -- Specifies FIFO as Asynchronous (FALSE)
                                      -- or Synchronous (TRUE)
      FIRST_WORD_FALL_THROUGH => TRUE, -- Sets the FIFO FWFT to TRUE or FALSE
      SIM_MODE => "SAFE") -- Simulation: "SAFE" vs "FAST", see "Synthesis and Simulation
                          -- Design Guide" for details
   port map (
      ALMOSTEMPTY => open,   -- 1-bit almost empty output flag
      ALMOSTFULL => open,     -- 1-bit almost full output flag
      DBITERR => open,            -- 1-bit double bit error status output
      DO => app_wdf_data,                     -- 64-bit data output
      DOP => open,                   -- 4-bit parity data output
      ECCPARITY => open,        -- 8-bit generated error correction parity
      EMPTY => data_fifo_empty_signal,               -- 1-bit empty output flag
      FULL => open,                 -- 1-bit full output flag
      RDCOUNT => open,           -- 9-bit read count output
      RDERR => open,               -- 1-bit read error output
      WRCOUNT => open,           -- 9-bit write count output
      WRERR => data_write_error,               -- 1-bit write error
      DI => data_in,                     -- 64-bit data input
      DIP => (others => '0'),                   -- 4-bit parity input
      RDCLK => clk_ddr2,               -- 1-bit read clock input
      RDEN => app_wdf_wren_signal,                 -- 1-bit read enable input
      RST => rst,                   -- 1-bit reset input
      WRCLK => clk_usr,               -- 1-bit write clock input
      WREN => data_rdy                 -- 1-bit write enable input
   );
	process(clk_ddr2) is
	begin
		app_wdf_wren_signal <= not data_fifo_empty_signal;
		write_data_fifo_empty <= data_fifo_empty_signal;
	end process;
	
	
	-- WRITE ADDR FIFO
	FIFO36_72_WRITE_ADDR : FIFO36_72
   generic map (
      ALMOST_FULL_OFFSET => X"0080",  -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET => X"0080", -- Sets the almost empty threshold
      DO_REG => 1,                    -- Enable output register (0 or 1)
                                      -- Must be 1 if EN_SYN = FALSE 
      EN_ECC_READ => FALSE,           -- Enable ECC decoder, TRUE or FALSE
      EN_ECC_WRITE => FALSE,          -- Enable ECC encoder, TRUE or FALSE
      EN_SYN => FALSE,                -- Specifies FIFO as Asynchronous (FALSE)
                                      -- or Synchronous (TRUE)
      FIRST_WORD_FALL_THROUGH => TRUE, -- Sets the FIFO FWFT to TRUE or FALSE
      SIM_MODE => "SAFE") -- Simulation: "SAFE" vs "FAST", see "Synthesis and Simulation
                          -- Design Guide" for details
   port map (
      ALMOSTEMPTY => open,   -- 1-bit almost empty output flag
      ALMOSTFULL => open,     -- 1-bit almost full output flag
      DBITERR => open,          -- 1-bit double bit error status output
      DO => addr_out_signal,                     -- 64-bit data output
      DOP => open,                   -- 4-bit parity data output
      ECCPARITY => open,       -- 8-bit generated error correction parity
      EMPTY => addr_fifo_empty_signal,               -- 1-bit empty output flag
      FULL => open,                 -- 1-bit full output flag
      RDCOUNT => open,           -- 9-bit read count output
      RDERR => open,               -- 1-bit read error output
      WRCOUNT => open,           -- 9-bit write count output
      WRERR => addr_write_error,               -- 1-bit write error
      DI => addr_in_signal,                     -- 64-bit data input
      DIP => (others => '0'),                   -- 4-bit parity input
      RDCLK => clk_ddr2,               -- 1-bit read clock input
      RDEN => app_af_wren_signal,       -- 1-bit read enable input
      RST => rst_rd_fifo,                   -- 1-bit reset input
      WRCLK => clk_usr,               -- 1-bit write clock input
      WREN => addr_rdy                -- 1-bit write enable input
   );
	
	process(clk_ddr2) is
	begin
		app_af_wren_signal <= not addr_fifo_empty_signal;
		addr_fifo_empty <= addr_fifo_empty_signal;
	end process;
	
	
	
end Behavioral;

