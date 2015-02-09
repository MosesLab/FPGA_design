----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:17:21 10/01/2014 
-- Design Name: 
-- Module Name:    MOSES_DDR2_TestProject - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity MOSES_DDR2_TestProject is
	port(
		clk_in_p		: in 		std_logic;
		clk_in_n		: in 		std_logic;
		
		--DDR2 interface
		ddr2_a 		: out		std_logic_vector (12 downto 0);
		ddr2_dq		: inout  std_logic_vector (31 downto 0); --inout
		ddr2_dqs 	: inout  std_logic_vector (3 downto 0); --inout
		ddr2_dqs_n 	: inout  std_logic_vector (3 downto 0);--inout
		ddr2_ba 		: out  	std_logic_vector (1 downto 0);
		ddr2_odt 	: out  	std_logic_vector(0 downto 0);
		ddr2_we_n 	: out  	std_logic;
		ddr2_cas_n 	: out  	std_logic;
		ddr2_ras_n 	: out  	std_logic;
		ddr2_dm 		: out  	std_logic_vector (3 downto 0);
		ddr2_cs_n 	: out  	std_logic_vector(0 downto 0);
		ddr2_ck 		: out  	std_logic_vector(0 downto 0);
		ddr2_ck_n 	: out  	std_logic_vector(0 downto 0);
		ddr2_cke 	: out  	std_logic_vector(0 downto 0)
	);
end MOSES_DDR2_TestProject;

architecture Behavioral of MOSES_DDR2_TestProject is	

	component DDR2_ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 TRIG0 : IN STD_LOGIC_VECTOR(254 DOWNTO 0));
	end component;
	
	component ICON
	  PORT (
		 CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
	end component;

	component DDR2_DataGen_FSM
		port(
			-- Clock and Reset Signals
			clk					:in	std_logic;	-- 50-MHz data generation clock
			sys_rst_n         :in	std_logic;	-- Active-low reset		
			
			-- Input Control Signals
			phy_init_done     :in	std_logic;	-- Indicator that the memory interface is ready to get what's comin' to it
			start_flag			:in	std_logic;	-- Start flag for delaying the generation of fake data
			
			-- Data Signals
			data      			:out	std_logic_vector(63 downto 0);	-- This is the generated data
			data_rdy				:out	std_logic;
			mask					:out	std_logic_vector(7 downto 0);
			-- Address Signals
			addr       			:out	std_logic_vector(30 downto 0);	-- This is the address
			cmd					:out	std_logic_vector(2 downto 0);		-- This is the read/write command bus
			addr_rdy				:out	std_logic;
			
			-- Status Signals
			fsm_state					:out	std_logic_vector(3 downto 0)	-- This indicates the state of the FSM
			
		);
	end component;

	component DDR2_CORE
	 generic(
		  BANK_WIDTH               : integer := 2;    
											-- # of memory bank addr bits.
		  CKE_WIDTH                : integer := 1;    
											-- # of memory clock enable outputs.
		  CLK_WIDTH                : integer := 2;    
											-- # of clock outputs.
		  COL_WIDTH                : integer := 10;    
											-- # of memory column bits.
		  CS_NUM                   : integer := 1;    
											-- # of separate memory chip selects.
		  CS_WIDTH                 : integer := 2;    
											-- # of total memory chip selects.
		  CS_BITS                  : integer := 0;    
											-- set to log2(CS_NUM) (rounded up).
		  DM_WIDTH                 : integer := 4;    
											-- # of data mask bits.
		  DQ_WIDTH                 : integer := 32;    
											-- # of data width.
		  DQ_PER_DQS               : integer := 8;    
											-- # of DQ data bits per strobe.
		  DQS_WIDTH                : integer := 4;    
											-- # of DQS strobes.
		  DQ_BITS                  : integer := 5;    
											-- set to log2(DQS_WIDTH*DQ_PER_DQS).
		  DQS_BITS                 : integer := 2;    
											-- set to log2(DQS_WIDTH).
		  ODT_WIDTH                : integer := 2;    
											-- # of memory on-die term enables.
		  ROW_WIDTH                : integer := 13;    
											-- # of memory row and # of addr bits.
		  ADDITIVE_LAT             : integer := 0;    
											-- additive write latency.
		  BURST_LEN                : integer := 4;    
											-- burst length (in double words).
		  BURST_TYPE               : integer := 0;    
											-- burst type (=0 seq; =1 interleaved).
		  CAS_LAT                  : integer := 3;    
											-- CAS latency.
		  ECC_ENABLE               : integer := 0;    
											-- enable ECC (=1 enable).
		  APPDATA_WIDTH            : integer := 64;    
											-- # of usr read/write data bus bits.
		  MULTI_BANK_EN            : integer := 1;    
											-- Keeps multiple banks open. (= 1 enable).
		  TWO_T_TIME_EN            : integer := 0;    
											-- 2t timing for unbuffered dimms.
		  ODT_TYPE                 : integer := 0;    
											-- ODT (=0(none),=1(75),=2(150),=3(50)).
		  REDUCE_DRV               : integer := 0;    
											-- reduced strength mem I/O (=1 yes).
		  REG_ENABLE               : integer := 0;    
											-- registered addr/ctrl (=1 yes).
		  TREFI_NS                 : integer := 7800;    
											-- auto refresh interval (ns).
		  TRAS                     : integer := 40000;    
											-- active->precharge delay.
		  TRCD                     : integer := 12500;    
											-- active->read/write delay.
		  TRFC                     : integer := 105000;    
											-- refresh->refresh, refresh->active delay.
		  TRP                      : integer := 12500;    
											-- precharge->command delay.
		  TRTP                     : integer := 7500;    
											-- read->precharge delay.
		  TWR                      : integer := 15000;    
											-- used to determine write->precharge.
		  TWTR                     : integer := 7500;    
											-- write->read delay.
		  HIGH_PERFORMANCE_MODE    : boolean := TRUE;    
											-- # = TRUE, the IODELAY performance mode is set
											-- to high.
											-- # = FALSE, the IODELAY performance mode is set
											-- to low.
		  SIM_ONLY                 : integer := 0;    
											-- = 1 to skip SDRAM power up delay.
		  DEBUG_EN                 : integer := 0;    
											-- Enable debug signals/controls.
											-- When this parameter is changed from 0 to 1,
											-- make sure to uncomment the coregen commands
											-- in ise_flow.bat or create_ise.bat files in
											-- par folder.
		  CLK_PERIOD               : integer := 5000;    
											-- Core/Memory clock period (in ps).
		  RST_ACT_LOW              : integer := 1     
											-- =1 for active low reset, =0 for active high.
	);
		 port (
		ddr2_dq               : inout  std_logic_vector((DQ_WIDTH-1) downto 0);
		ddr2_a                : out   std_logic_vector((ROW_WIDTH-1) downto 0);
		ddr2_ba               : out   std_logic_vector((BANK_WIDTH-1) downto 0);
		ddr2_ras_n            : out   std_logic;
		ddr2_cas_n            : out   std_logic;
		ddr2_we_n             : out   std_logic;
		ddr2_cs_n             : out   std_logic_vector((CS_WIDTH-1) downto 0);
		ddr2_odt              : out   std_logic_vector((ODT_WIDTH-1) downto 0);
		ddr2_cke              : out   std_logic_vector((CKE_WIDTH-1) downto 0);
		ddr2_dm               : out   std_logic_vector((DM_WIDTH-1) downto 0);
		sys_rst_n             : in    std_logic;
		phy_init_done         : out   std_logic;
		locked                : in    std_logic;
		rst0_tb               : out   std_logic;
		clk0                  : in    std_logic;
		clk0_tb               : out   std_logic;
		clk90                 : in    std_logic;
		clkdiv0               : in    std_logic;
		clk200                : in    std_logic;
		app_wdf_afull         : out   std_logic;
		app_af_afull          : out   std_logic;
		rd_data_valid         : out   std_logic;
		app_wdf_wren          : in    std_logic;
		app_af_wren           : in    std_logic;
		app_af_addr           : in    std_logic_vector(30 downto 0);
		app_af_cmd            : in    std_logic_vector(2 downto 0);
		rd_data_fifo_out      : out   std_logic_vector((APPDATA_WIDTH-1) downto 0);
		app_wdf_data          : in    std_logic_vector((APPDATA_WIDTH-1) downto 0);
		app_wdf_mask_data     : in    std_logic_vector((APPDATA_WIDTH/8-1) downto 0);
		ddr2_dqs              : inout  std_logic_vector((DQS_WIDTH-1) downto 0);
		ddr2_dqs_n            : inout  std_logic_vector((DQS_WIDTH-1) downto 0);
		ddr2_ck               : out   std_logic_vector((CLK_WIDTH-1) downto 0);
		ddr2_ck_n             : out   std_logic_vector((CLK_WIDTH-1) downto 0)
	);
	end component;
	
	component clock_management
		port(
			-- This is the 100-MHz differential input clock
			clk100M		:in	std_logic;
			
			clk50			:out	std_logic;
			
			-- These are the clocks required to run the DDR2 interface
			ddr2_clk0		:out	std_logic;	-- 150-MHz clock for controller and interface logic
			ddr2_clk90		:out	std_logic;	-- 90-deg phase-shifted version of 50-MHz system clock
			ddr2_clkdv		:out	std_logic;	-- Divided-by-two, edge-aligned version of 50-MHz clock
			
			rst_n				:in	std_logic;
			pll_locked		:out	std_logic
		);
	end component;

	component DDR2_BurstController
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
			
			--DDR2 User Interface 
			-- Output Control Signals
			app_wdf_wren      :out	std_logic;
			app_af_wren       :out	std_logic;
			app_af_cmd        :out	std_logic_vector(2  downto 0); 
			app_wdf_mask_data :out	std_logic_vector(7  downto 0);
			
			-- Data Signals
			rd_data_fifo_out  :in	std_logic_vector(63 downto 0);
			rd_data_valid			:in	std_logic;
			app_wdf_data      :out	std_logic_vector(63 downto 0);	
			rdcount				:out	std_logic_vector(8 downto 0);

			read_data			:out	std_logic_vector(63 downto 0);
			read_data_empty	:out	std_logic;
			read_data_en		:in	std_logic;
			
			-- Address Signals
			app_af_addr       :out	std_logic_vector(30 downto 0)
		);
	end component;
	
	constant	BANK_WIDTH 					:integer	:= 2;
	constant	CKE_WIDTH 					:integer	:= 1;
	constant	CLK_WIDTH 					:integer	:= 1;
	constant	COL_WIDTH					:integer	:= 10;
	constant	CS_NUM 						:integer	:= 1;
	constant	CS_WIDTH 					:integer	:= 1;
	constant	CS_BITS 						:integer	:= 0;
	constant	DM_WIDTH 					:integer	:= 4;
	constant	DQ_WIDTH 					:integer	:= 32;
	constant	DQ_PER_DQS 					:integer	:= 8; -- Should this be 16?
	constant	DQS_WIDTH 					:integer	:= 4;
	constant	DQ_BITS 						:integer	:= 5;
	constant	DQS_BITS 					:integer	:= 2;
	constant	ODT_WIDTH 					:integer	:= 1;
	constant	ROW_WIDTH 					:integer	:= 13;
	constant	ADDITIVE_LAT 				:integer	:= 0;
	constant	BURST_LEN 					:integer	:= 4;
	constant	BURST_TYPE 					:integer	:= 0;
	constant	CAS_LAT 						:integer	:= 3;
	constant	ECC_ENABLE 					:integer	:= 0;
	constant	APPDATA_WIDTH 				:integer	:= 64;
	constant	MULTI_BANK_EN 				:integer	:= 1;
	constant	TWO_T_TIME_EN 				:integer	:= 0;
	constant	ODT_TYPE 					:integer	:= 3;
	constant	REDUCE_DRV 					:integer	:= 0;
	constant	REG_ENABLE 					:integer	:= 0;
	constant	TREFI_NS 					:integer	:= 7800;
	constant	TRAS 							:integer	:= 40000;
	constant	TRCD 							:integer	:= 10500;
	constant	TRFC 							:integer	:= 105000;
	constant	TRP 							:integer	:= 15000;
	constant	TRTP 							:integer	:= 7500;
	constant	TWR 							:integer	:= 15000;
	constant	TWTR 							:integer	:= 7500;
	constant	HIGH_PERFORMANCE_MODE	:boolean	:= TRUE;	 
	constant	SIM_ONLY						:integer	:= 0;	
	constant	DEBUG_EN 					:integer	:= 0;	
	constant	CLK_PERIOD 					:integer	:= 6667;	
	constant	RST_ACT_LOW 				:integer	:= 1;

	signal	ddr2_a_signal 		:std_logic_vector(12 downto 0);
	signal	ddr2_dq_signal		:std_logic_vector(31 downto 0);
	signal	ddr2_dqs_signal 	:std_logic_vector(3 downto 0);
	signal	ddr2_dqs_n_signal :std_logic_vector(3 downto 0);
	signal	ddr2_ba_signal 	:std_logic_vector(1 downto 0);
	signal	ddr2_odt_signal 	:std_logic_vector(0 downto 0);
	signal	ddr2_we_n_signal 	:std_logic;
	signal	ddr2_cas_n_signal :std_logic;
	signal	ddr2_ras_n_signal :std_logic;
	signal	ddr2_dm_signal 	:std_logic_vector(3 downto 0);
	signal	ddr2_cs_n_signal 	:std_logic_vector(0 downto 0);
	signal	ddr2_ck_signal 	:std_logic_vector(0 downto 0);
	signal	ddr2_ck_n_signal 	:std_logic_vector(0 downto 0);
	signal	ddr2_cke_signal 	:std_logic_vector(0 downto 0);
	
	signal	sys_rst_n         :std_logic;
	signal	phy_init_done     :std_logic;
	signal	locked            :std_logic;
	signal	rst0_tb           :std_logic;
	signal	clk0              :std_logic;
	signal	clk0_tb           :std_logic;
	signal	clk90             :std_logic;
	signal	clkdiv0           :std_logic;
	signal	clk150            :std_logic;
	signal	app_wdf_afull     :std_logic;
	signal	app_af_afull      :std_logic;
	signal	rd_data_valid     :std_logic;
	signal	app_wdf_wren      :std_logic;
	signal	app_af_wren       :std_logic;
	signal	app_af_addr       :std_logic_vector(30 downto 0);      
	signal	app_af_cmd        :std_logic_vector(2 downto 0);      
	signal	rd_data_fifo_out  :std_logic_vector(63 downto 0);      
	signal	app_wdf_data      :std_logic_vector(63 downto 0);      
	signal	app_wdf_mask_data :std_logic_vector(7 downto 0);   

	signal	clk100M				:std_logic;
	signal	clk150M_feedback	:std_logic;
	signal 	state					:std_logic_vector(3 downto 0);
	
	signal	count					:unsigned(31 downto 0);
	signal	start_flag			:std_logic;
	
	signal	ila_signal			:std_logic_vector(254 downto 0);
	signal	icon_signal			:std_logic_vector(35 downto 0);
	
	signal	clk50					:std_logic;
	signal	clk100				:std_logic;
	signal	clk100M_SE			:std_logic;
	
	signal	read_data_en		:std_logic;
	
	signal	read_data_signal	:std_logic_vector(63 downto 0);
	signal	read_data_empty_signal	:std_logic;

	signal data	:std_logic_vector(63 downto 0);
	signal data_rdy	:std_logic;
	signal addr	:std_logic_vector(30 downto 0);
	signal cmd	:std_logic_vector(2 downto 0);
	signal addr_rdy	:std_logic;
	signal mask	:std_logic_vector(7 downto 0);
	signal rdcount	:std_logic_vector(8 downto 0);
	
begin
	
	

	-- Top-level signal assignment
	ddr2_a 			<= ddr2_a_signal;
	ddr2_dq			<= ddr2_dq_signal;
	ddr2_dqs 		<= ddr2_dqs_signal;
	ddr2_dqs_n 		<= ddr2_dqs_n_signal;
	ddr2_ba 			<= ddr2_ba_signal;
	ddr2_odt 		<= ddr2_odt_signal;
	ddr2_we_n 		<= ddr2_we_n_signal;
	ddr2_cas_n 		<= ddr2_cas_n_signal;
	ddr2_ras_n 		<= ddr2_ras_n_signal;
	ddr2_dm 			<= ddr2_dm_signal;
	ddr2_cs_n 		<= ddr2_cs_n_signal;
	ddr2_ck 			<= ddr2_ck_signal;
	ddr2_ck_n 		<= ddr2_ck_n_signal;
	ddr2_cke 		<= ddr2_cke_signal;

	DDR2_FSM0	:	DDR2_DataGen_FSM
		port map(
			clk					=> clk50,
			sys_rst_n         => sys_rst_n,
			phy_init_done     => phy_init_done,
			start_flag			=> start_flag,
			data      			=> data,
			data_rdy				=> data_rdy,
			mask					=> mask,
			addr       			=> addr,
			cmd					=> cmd,
			addr_rdy				=> addr_rdy,
			fsm_state			=> state
		);

	ila_signal(0)	<=	'0';
	ila_signal(1)	<= sys_rst_n;
	ila_signal(2)	<= phy_init_done;
	ila_signal(3)	<= start_flag;
	ila_signal(67 downto 4)	<= data;
	ila_signal(68)	<=	data_rdy;
	ila_signal(99 downto 69)	<=	addr;
	ila_signal(102 downto 100)	<=	cmd;
	ila_signal(103)	<=	addr_rdy;
	ila_signal(107 downto 104)	<=	state;
	ila_signal(108)	<=	locked;
	ila_signal(172 downto 109) <= read_data_signal;
	ila_signal(173) <= read_data_empty_signal;
	ila_signal(182 downto 174) <= rdcount;
	ila_signal(183) <= read_data_en;
	ila_signal(254 downto 184)	<=	(others => '0');
	

	 u_DDR2_CORE : DDR2_CORE
		 generic map (
		  BANK_WIDTH => BANK_WIDTH,
		  CKE_WIDTH => CKE_WIDTH,
		  CLK_WIDTH => CLK_WIDTH,
		  COL_WIDTH => COL_WIDTH,
		  CS_NUM => CS_NUM,
		  CS_WIDTH => CS_WIDTH,
		  CS_BITS => CS_BITS,
		  DM_WIDTH => DM_WIDTH,
		  DQ_WIDTH => DQ_WIDTH,
		  DQ_PER_DQS => DQ_PER_DQS,
		  DQS_WIDTH => DQS_WIDTH,
		  DQ_BITS => DQ_BITS,
		  DQS_BITS => DQS_BITS,
		  ODT_WIDTH => ODT_WIDTH,
		  ROW_WIDTH => ROW_WIDTH,
		  ADDITIVE_LAT => ADDITIVE_LAT,
		  BURST_LEN => BURST_LEN,
		  BURST_TYPE => BURST_TYPE,
		  CAS_LAT => CAS_LAT,
		  ECC_ENABLE => ECC_ENABLE,
		  APPDATA_WIDTH => APPDATA_WIDTH,
		  MULTI_BANK_EN => MULTI_BANK_EN,
		  TWO_T_TIME_EN => TWO_T_TIME_EN,
		  ODT_TYPE => ODT_TYPE,
		  REDUCE_DRV => REDUCE_DRV,
		  REG_ENABLE => REG_ENABLE,
		  TREFI_NS => TREFI_NS,
		  TRAS => TRAS,
		  TRCD => TRCD,
		  TRFC => TRFC,
		  TRP => TRP,
		  TRTP => TRTP,
		  TWR => TWR,
		  TWTR => TWTR,
		  HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
		  SIM_ONLY => SIM_ONLY,
		  DEBUG_EN => DEBUG_EN,
		  CLK_PERIOD => CLK_PERIOD,
		  RST_ACT_LOW => RST_ACT_LOW
	)
		 port map (
		ddr2_dq                    => ddr2_dq_signal,
		ddr2_a                     => ddr2_a_signal,
		ddr2_ba                    => ddr2_ba_signal,
		ddr2_ras_n                 => ddr2_ras_n_signal,
		ddr2_cas_n                 => ddr2_cas_n_signal,
		ddr2_we_n                  => ddr2_we_n_signal,
		ddr2_cs_n                  => ddr2_cs_n_signal,
		ddr2_odt                   => ddr2_odt_signal,
		ddr2_cke                   => ddr2_cke_signal,
		ddr2_dm                    => ddr2_dm_signal,
		sys_rst_n             		=> sys_rst_n,
		phy_init_done         		=> phy_init_done,
		locked                		=> locked,
		rst0_tb               		=> rst0_tb,
		clk0                  		=> clk150,
		clk0_tb               		=> clk0_tb,
		clk90                 		=> clk90,
		clkdiv0               		=> clkdiv0,
		clk200                		=> clk150,
		app_wdf_afull              => app_wdf_afull, 
		app_af_afull               => app_af_afull,
		rd_data_valid              => rd_data_valid,	
		app_wdf_wren               => app_wdf_wren,
		app_af_wren                => app_af_wren,
		app_af_addr                => app_af_addr,
		app_af_cmd                 => app_af_cmd,	
		rd_data_fifo_out           => rd_data_fifo_out,
		app_wdf_data               => app_wdf_data,
		app_wdf_mask_data          => app_wdf_mask_data,
		ddr2_dqs                   => ddr2_dqs_signal,
		ddr2_dqs_n                 => ddr2_dqs_n_signal,
		ddr2_ck                    => ddr2_ck_signal,
		ddr2_ck_n                  => ddr2_ck_n_signal
	);
	
	DDR2_BC0	:	DDR2_BurstController
		port map(
			clk_usr		=> clk50,
			clk_ddr2		=> clk0_tb,
			rst_n			=> sys_rst_n,
			rst_mig		=> rst0_tb,
			
			--Instrument Interface
			data_in		=> data,
			addr_in		=> addr,
			cmd_in		=> cmd,
			data_rdy		=> data_rdy,
			addr_rdy		=> addr_rdy,
			mask_in		=> mask,
			
			--DDR2 User Interface 
			-- Output Control Signals
			app_wdf_wren      => app_wdf_wren,
			app_af_wren       => app_af_wren,
			app_af_cmd        => app_af_cmd,
			app_wdf_mask_data => app_wdf_mask_data,
			
			-- Data Signals
			rd_data_fifo_out  => rd_data_fifo_out,
			rd_data_valid		=> rd_data_valid,
			app_wdf_data      => app_wdf_data,
			
			read_data			=> read_data_signal,
			read_data_empty	=> read_data_empty_signal,
			read_data_en		=> read_data_en,
			rdcount				=> rdcount,
			
			-- Address Signals
			app_af_addr       => app_af_addr
		);
		
		read_data_en <= not read_data_empty_signal;
		
--	process(clk50,sys_rst_n) is
--	begin
--		if (sys_rst_n = '0') then
--			read_data_en <= '0';
--		elsif (clk50'event and clk50 = '1') then
--			read_data_en <= '0';
--			if (read_data_empty_signal = '0') then
--				read_data_en <= '1';
--			end if;
--		end if;
--	end process;
	
	
	
	ILA0 : DDR2_ILA
	  port map (
		 CONTROL => icon_signal,
		 CLK => clk50,
		 TRIG0 => ila_signal);
		 
	ICON0 : ICON
	  port map (
		 CONTROL0 => icon_signal);
	
	CM0	:	clock_management
		port map(
			-- This is the 100-MHz differential input clock
		clk100M		=> clk100M_SE,
		
		clk50			=> clk50,
		
		-- These are the clocks required to run the DDR2 interface
		ddr2_clk0		=> clk150,
		ddr2_clk90		=> clk90,
		ddr2_clkdv		=> clkdiv0,
		
		rst_n				=> sys_rst_n,
		pll_locked		=> locked
		);
		
	IBUFGDS_inst : IBUFGDS
		generic map (
			IOSTANDARD => "LVDS_25")
		port map (
			O => clk100M_SE,  -- Clock buffer output
			I => clk_in_p,  -- Diff_p clock buffer input
			IB => clk_in_n -- Diff_n clock buffer input
		);
		
	COUNT0	:	process(clk50,sys_rst_n) is
	begin
		if (sys_rst_n = '0') then
			count <= (others => '0');
			start_flag <= '0';
		elsif( clk50'event and clk50 = '1') then
			count <= count + 1;
			start_flag <= '0';
			if (count >= 150000000) then
				start_flag <= '1';
				count <= (others => '0');
			end if;
		end if;
	end process;
	
	sys_rst_n <= '1';
	
--	process(clk50) is
--		variable rst_count	:integer range 0 to 2**30 - 1 := 0;
--	begin
--		if (clk50'event and clk50 = '1') then
--			if (rst_count < 100) then
--				rst_count := rst_count + 1;
--				sys_rst_n <= '0';
--			else
--				sys_rst_n <= '1';
--				rst_count := 100;
--			end if;
--		end if;
--	end process;
	


end Behavioral;

