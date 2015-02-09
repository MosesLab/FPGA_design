----------------------------------------------------------------------------------
-- Company: 	Montana State University Electrical and Computer Engineering Department
-- Engineer: 	Justin A. Hogan, PhD
-- 
-- Create Date:    	16:39:15 06/26/2014 
-- Design Name: 		MOSES Camera Bridge
-- Module Name:    	MOSES_FPGA_Design - Behavioral 
-- Project Name:		Multi-Order Solar Extreme Ultraviolet Spectrograph (MOSES) 
-- Target Devices: 	XC5VLX50T
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
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
use work.ffpci104_pkg.all;  --- ensure correct package is added, contains definitions for product
use work.ctiUtil.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity MOSES_FPGA_Design is
	port(
		
		-- Main clock
		mainclkp : in  std_logic;
		mainclkn : in  std_logic;
		
		-- PCI 9056 is strapped to C-Mode operation on the FreeForm/PCI-104 Board
		-- PCI 9056 Interface Signals									-- ORIGINAL COMMENTS FROM MANF.--			## JAH COMMENTS
		lb_adsn 			: inout std_logic; 							-- asserted by lb master 						## Indicates the valid address and start of a new bus access.  Asserted for the first clock of a bus access
		lb_bigendn 		: out std_logic;								-- input to PLX									##	Can be asserted during the Local Bus Address phase of a Direct Master transfer or Config. Register access to specify Big Endian byte ordering
		lb_blastn 		: inout std_logic; 							-- asserted by lb master						##	9056 Input: asserted by bus master to indicate last data transfer of a bus access. 9056 Output: Asserted by 9056 to signal last data transfer
		lb_breqi 		: out std_logic;								--														##	Input to PLX, asserted to indicate a Local Bus Master requires the bus (details PCI 9056 Databook p.357)
		lb_breqo 		: in std_logic;								--														##	Output from PLX, asserted by PLX at expiry of Backoff Timer until PLX is given the Local Bus
		lb_btermn 		: out std_logic;								-- asserted by lb slave							##	Active-low bus terminate, causes 9056-Master to break a burst (typically) transfer
		lb_ccsn 			: out std_logic;								--														## PCI 9065 chip select signal, active-low, used to access local bus configuration registers
		lb_dackn 		: in std_logic_vector(1 downto 0);		--														##	Internal 9056 registers are selected when CCSN is asserted (active-low) during local bus accesses to the 9056. 
		lb_eotn 			: inout std_logic;							-- when DMPAF PLX out, when EOTN PLX in	##	End of Transfer for current DMA channel, also multiplexed with Direct Master Programmable Almost Full (DMPAF) to indicate DM write FIFO status
		lb_dp 			: out std_logic_vector(3 downto 0); 	-- inout												##	Even data parity bit for each of four byte lanes on the local bus.
		lb_dreqn 		: out std_logic_vector(1 downto 0);		--														##	DMA Channel 0 (lb_dreqn(0)) or 1 (lb_dreqn(1)) request (Demand Mode)	ASSUMED CHANNEL ASSIGNMENT
		lb_la 			: inout std_logic_vector(31 downto 2); -- asserted by master							##	Upper 30-bits of the physical address bus (local)
		lb_lben 			: inout std_logic_vector(3 downto 0); 	-- inout												##	Local bus byte enable signal, see PCI 9056 Databook p.359 for details
		lb_lclko_plx 	: out std_logic;								-- U5-B21 >> U4-D16								## This signal is assumed to be LCLK in PLX PCI 9xxx/PEX 8311 Local Bus Primer. Primary clock for the local bus.		
		lb_lclko_loop 	: out std_logic;								-- U5-A20 >> U5-Y21								## Loopback clock used for feedback to clock generation core
		lb_lclko_fb		: in std_logic;								-- this is y21										##	Feedback clock signal, connected externally to lb_lclko_loop
		lb_ld 			: inout std_logic_vector(31 downto 0);	--														##	Local Bus Data signals
		lb_lhold 		: in std_logic;								-- asserted by PLX								##	Asserted by the 9056 to request use of the local bus
		lb_lholda 		: out std_logic;								-- asserted by arbiter							##	Asstered by the bus arbiter to grant local bus to 9056
		lb_lintin 		: out std_logic;								--														##	Causes a PCI interrupt on INTA# (active-low)
		lb_linton 		: in std_logic;								--														##	Interrupt output that stays asserted while an enabled interrupt condition exists
		lb_lresetn 		: in std_logic;								--														##	'in' assignment implies 9056 running in Adapter Mode, used as a reset to logic on FPGA, asserted when 9056 is in reset.
		lb_lserrn 		: in std_logic;								-- was just in										##	Local system error interrupt output.
		lb_lw_rn 		: inout std_logic; 							-- asserted by master							##	Local write/read, Asserted low for reads and high for writes
		lb_pmereon 		: out std_logic;								--														##	Used in power management
		lb_readyn 		: inout std_logic; 							-- asserted by slave								##	Asserted by local slave to indicate read data on bus is valid, or that a write to the slave is complete. Not sampled (by 9056) until lb_waitn is asserted
		lb_useri 		: out std_logic;								--														##	GPIO input to 9056 that can be read in the configuration registers
		lb_usero 		: in std_logic;								--														## GPIO output from 9056 that can be set in configuration registers
		lb_waitn 		: in std_logic; 								-- asserted by master							##	9056 can be programmed to insert wait states to pause the local slave by asserting this signal for a predefined number of clock cycles during Direct Slave transfers
		plx_hostenn 	: in std_logic;								--														##	Unused in Reference Design, unknown driver external to FPGA.  9056 operates in Adapter mode when this signal is strapped high...
		
		--DDR2 interface
		ddr2_a : out  std_logic_vector (12 downto 0);
		ddr2_dq : inout  std_logic_vector (31 downto 0); --inout
		ddr2_dqs : inout  std_logic_vector (3 downto 0); --inout
		ddr2_dqs_n : inout  std_logic_vector (3 downto 0);--inout
		ddr2_ba : out  std_logic_vector (1 downto 0);
		ddr2_odt : out  std_logic_vector(0 downto 0);
		ddr2_we_n : out  std_logic;
		ddr2_cas_n : out  std_logic;
		ddr2_ras_n : out  std_logic;
		ddr2_dm : out  std_logic_vector (3 downto 0);
		ddr2_cs_n : out  std_logic_vector(0 downto 0);
		ddr2_ck : out  std_logic_vector(0 downto 0);
		ddr2_ck_n : out  std_logic_vector(0 downto 0);
		ddr2_cke : out  std_logic_vector(0 downto 0);
		
		-- GPIO Signals																
		gpio_in 	: in std_logic_vector(14 downto 0);				
		gpio_out : out std_logic_vector(11 downto 0);			
		
		-- User LEDs
		user_led : out std_logic_vector(3 downto 0);
		
		-- Camera Signals
		camera_data_in	:in std_logic_vector(15 downto 0);
		camera_pxl_clk_in	:in	std_logic;
		
		self_destruct	:out	std_logic
		
		);

end MOSES_FPGA_Design;

architecture Behavioral of MOSES_FPGA_Design is
	------------------------------
	--  COMPONENT DECLARATIONS  --
	------------------------------
	component DDR2_CORE_JAH
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
		  TRCD                     : integer := 15000;    
											-- active->read/write delay.
		  TRFC                     : integer := 105000;    
											-- refresh->refresh, refresh->active delay.
		  TRP                      : integer := 15000;    
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
		  DLL_FREQ_MODE            : string := "HIGH";    
											-- DCM Frequency range.
		  CLK_TYPE                 : string := "SINGLE_ENDED";    
											-- # = "DIFFERENTIAL " ->; Differential input clocks ,
											-- # = "SINGLE_ENDED" -> Single ended input clocks.
		  NOCLK200                 : boolean := FALSE;    
											-- clk200 enable and disable
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
		sys_clk               : in    std_logic;
		idly_clk_200          : in    std_logic;
		sys_rst_n             : in    std_logic;
		phy_init_done         : out   std_logic;
		rst0_tb               : out   std_logic;
		clk0_tb               : out   std_logic;
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
	
	
	component plxArb
		port (
			lresetn 			: in std_logic;
			lclk 				: in std_logic;
			dsReq 			: in std_logic; -- lb_lhold
			dsAck 			: out std_logic; -- lb_lholda
			dsReqForce 		: in std_logic; -- lb_breqo
			dmReq 			: in std_logic;
			dmAck 			: out std_logic;
			dmBackoff 		: out std_logic;
			allClkStable 	: in std_logic );
	end component;
	
	
	component plx32BitMaster
		 generic (	
			c_cfgRomSize : integer := 18;
			c_ramWidth : integer := 4;
			c_txfrCntWidth : natural :=6;
			c_enPlxCfg : boolean := TRUE
		);
		port (
			lclk				: in std_logic;							
			la					: out std_logic_vector(31 downto 2);		
			ld_dir			: out std_logic;
			lben				: out std_logic_vector(3 downto 0);		
			adsn				: out std_logic;							
			blastn			: out std_logic;							
			readyn			: in std_logic;						
			lw_rn				: out std_logic;							
			lresetn			: in std_logic;
			ccsn				: out std_logic;
			dmpaf				: in std_logic;
			req				: out std_logic;
			ack				: in std_logic;
			backoff			: in std_logic;
			txfrCtrl			: in std_logic_vector(1 downto 0);
			txfrAddr			: in std_logic_vector(31 downto 0);
			txfrCnt			: in std_logic_vector(c_txfrCntWidth-1 downto 0);
			int				: out std_logic;
			cfgComplete		: out std_logic;
			ramAddr 			: out std_logic_vector(c_ramWidth-1 downto 0);
			ramWr 			: out std_logic_vector( 3 downto 0);
			ramEn 			: out std_logic;
			cfgRomPtr 		: out unsigned(4 downto 0);
			cfgRomDout		: in std_logic_vector(47 downto 0);
			stateOut 		: out std_logic_vector(6 downto 0)
		);
	end component;
	
	component plxCfgRom
		generic( 
			c_romSize 		: integer := 20;
			c_ds0BaseAddr 	: std_logic_vector(31 downto 4) := x"0000000"; 
			c_ds0ByteSz		: natural := 128;
			c_ds0En			: std_logic := '1';				
			c_ds1BaseAddr 	: std_logic_vector(31 downto 4) := x"1000000"; 
			c_ds1ByteSz		: natural := 512;
			c_ds1En			: std_logic := '1'
		);
		port (
			clk 				: in  std_logic;
			addr 				: in  unsigned (4 downto 0);
			dout 				: out  std_logic_vector (47 downto 0)
		);
	end component;
	
	component plx32BitSlave
		port (
			lresetn			: in 	std_logic; 								-- Local bus reset
			lclk				: in 	std_logic;								-- Local clock input
			ld_dir			: out std_logic;								
			lben				: in 	std_logic_vector(3 downto 0);		-- Local Byte Enables
			adsn				: in 	std_logic;								-- Addres Strobe
			blastn			: in 	std_logic;								-- Burst last
			readyn			: out std_logic;								-- READY I/O
			lw_rn				: in 	std_logic;								-- Local Write/Read															
			ArbiterAck		: in 	std_logic;
			address_valid	: in 	std_logic
		);
	end component; 
	
	component reg32_ReadOnly
		 port ( 
			clk 				: in  std_logic;	-- System clock signal
			rst_n				: in  std_logic;	-- Active-low reset signal
			user_D	 		: in  std_logic_vector(31 downto 0);	-- This is the register bank input signals that can be mapped to logic in the user design
			user_Q	 		: out std_logic_vector(31 downto 0);	-- This is the register bank output signals that can be mapped to logic in the user design
			interrupt		: out	std_logic_vector(31 downto 0)
		);
	end component;

	component reg32_ReadWrite
		 port ( 
			clk 				: in  std_logic;	-- System clock signal
			rst_n				: in  std_logic;	-- Active-low reset signal
			wren	 			: in 	std_logic;	-- Register bank select signal
			lb_lben			: in	std_logic_vector(3 downto 0);
			user_D	 		: in  std_logic_vector(31 downto 0);	-- This is the register bank input signals that can be mapped to logic in the user design
			user_Q	 		: out std_logic_vector(31 downto 0)	-- This is the register bank output signals that can be mapped to logic in the user design
			
		);
	end component;
	
	component interrupt_logic
		port(
			clk				:in	std_logic;
			rst_n				:in	std_logic;
			set				:in	std_logic_vector(31 downto 0);
			clear				:in	std_logic_vector(31 downto 0);
			interrupt		:out	std_logic_vector(31 downto 0)
		);
	end component;
	
	component counter_peripheral
		port(
			clk	: in	std_logic;
			rst_n	: in	std_logic;
			count_overflow	:out	std_logic
		);
	end component;
	
	component camera_interface
		 Port ( 	clk 				: in  std_logic;
					rst_n 			: in  std_logic;					
					-- camera interface signals
					pxl_data_in 		: in  std_logic_vector(15 downto 0);
					pxl_clk_in 			: in  std_logic;			
					pxl_data_out		:	out	std_logic_vector(63 downto 0);
					pxl_data_ready		:	out	std_logic
					);
	end component;
	
	component DDR2_DataManager
		port (
			clk					:in	std_logic;
			rst_n					:in	std_logic;
			error_flag			:out	std_logic;
			
			-- User Data Interface
			-- Camera data for writing to DDR2
			pxl_data				:in	std_logic_vector(63 downto 0);
			pxl_data_ready		:in	std_logic;
			
			-- PLX signals for reading the data out of DDR2
			lb_adsn				:in	std_logic;
			lb_la					:in	std_logic_vector(29 downto 0);
			lb_readyn			:out	std_logic;
			lb_blastn			:in	std_logic;
			lb_ld					:out	std_logic_vector(31 downto 0);
			lb_btermn			:out	std_logic;
			lb_waitn				:in	std_logic;
			
			-- User Control Interface
			control				:in	std_logic_vector(7 downto 0);
			fsm_state			:out	std_logic_vector(3 downto 0);
			frame_ready			:out	std_logic;
			ddr2_readyn_sel	:out	std_logic;
			
			-- DDR2 Interface
			ddr2_clk				:in	std_logic;
			ddr2_rst				:in	std_logic;
			app_wdf_wren      :out	std_logic;
			app_af_wren       :out	std_logic;
			app_af_cmd        :out	std_logic_vector(2  downto 0); 
			app_wdf_mask_data :out	std_logic_vector(7  downto 0);
			app_wdf_data      :out	std_logic_vector(63 downto 0);
			app_af_addr       :out	std_logic_vector(30 downto 0);
			rd_data_fifo_out  :in	std_logic_vector(63 downto 0);
			rd_data_valid		:in	std_logic;
			
			buffer_addr_rst			:out	std_logic;
			
			ILA_CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
		);
	end component;

	component camera_sim
		port(
			clk		:in	std_logic;	-- system input clock
			rst_n		:in	std_logic;	-- system reset signal (active-low)
			trigger	:in	std_logic;	-- frame enable signal (trigger the start of a frame)
			
			pxl_clk	:out	std_logic; 
			pxl_data	:out	std_logic_vector(15 downto 0)		
		);
	end component;
	
	component Camera_Interface_ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 TRIG0 : IN STD_LOGIC_VECTOR(83 DOWNTO 0));

	end component;
	
	component LOCAL_BUS_ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 TRIG0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0));

	end component;
	
	component Camera_Interface_ICON
	  PORT (
		 CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));

	end component;
	
	component DDR2_ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 TRIG0 : IN STD_LOGIC_VECTOR(172 DOWNTO 0));
	end component;
	
	component DDR2_INTERFACE_ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 TRIG0 : IN STD_LOGIC_VECTOR(148 DOWNTO 0));

	end component;
	
	component DDR2_DataManager_ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 TRIG0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0));
	end component;
	
	component POWER_DOWN_TIMER is
		port(
			clk		:in	std_logic;
			rst_n		:in	std_logic;
			initiate_destruct_sequence		:in	std_logic;
			self_destruct	:out	std_logic
		);
	end component;	
	
	component clkControlMem_JAH is
		 port ( 
			clk100M_SE		: in	std_logic;
			lb_lclko			: out std_logic;
			lb_lclko_loop	: out	std_logic;
			lb_lclko_fb		: in  std_logic;
			clk50 			: out std_logic;
			ddr2_clk200		: out std_logic;
			locked			: out	std_logic
		);
	end component;

	---------------------------
	--  SIGNAL DECLARATIONS  --
	---------------------------
	signal dm_adsn 			:  std_logic;		-- Master active-low address strobe
	signal dm_blastn 			:  std_logic;		-- Local Master last byte signal
	signal dm_la 				:  std_logic_vector(31 downto 2);		--	Direct Master local address signal
	signal dm_lben 			:  std_logic_vector(3 downto 0);			-- Direct Master
	signal dsAck 				: 	std_logic;
	signal dm_lw_rn 			:  std_logic;
	signal ds_readyn 			:  std_logic;
	signal ds_ld_dir 			:	std_logic;
	signal dm_ld_dir 			: 	std_logic;
	signal dmReq 				: 	std_logic;
	signal dmBackoff 			: 	std_logic;	
	signal dmAck 				: 	std_logic;
	signal cfgRomAddr			: unsigned(4 downto 0);
	signal cfgRomDout			: std_logic_vector(47 downto 0);	-- 47:36 holds PCI9056 configuration register address value, 
	
	signal clk50 				: 	std_logic;
	signal allClkStable 		: 	std_logic;
	signal rstn 				: 	std_logic;
	
	signal fsm_state_signal	:	std_logic_vector(3 downto 0);

	signal reg_bank_en		:	std_logic;
	signal input_gpio_register	:	std_logic_vector(31 downto 0);
	signal output_gpio_registers	:std_logic_matrix_32 (((2**5)-1) downto 0);
	signal user_Q				:	std_logic_matrix_32 (((2**5)-1) downto 0);
	signal local_bus_gpio	:	std_logic_vector(((2**5)-1) downto 0);
	signal ld_out_signal		:	std_logic_vector(31 downto 0);
	signal address_valid		:	std_logic;
	signal gpio_address_valid	:	std_logic;
	signal ddr_address_valid	:	std_logic;
	signal cfgComplete		:	std_logic;
	
	signal	lb_adsn_signal 			:	std_logic;  
	signal	lb_bigendn_signal 		:	std_logic;
	signal	lb_blastn_signal 			:	std_logic;
	signal	lb_breqi_signal 			:	std_logic;
	signal	lb_btermn_signal 			:	std_logic;
	signal	lb_ccsn_signal 			:	std_logic; 
	signal	lb_eotn_signal 			:	std_logic;
	signal	lb_dp_signal 				:	std_logic_vector(3 downto 0);
	signal	lb_dreqn_signal 			:	std_logic_vector(1 downto 0);	
	signal	lb_la_signal 				:	std_logic_vector(31 downto 2); 
	signal	lb_lben_signal 			:	std_logic_vector(3 downto 0);
	signal	lb_ld_signal 				:	std_logic_vector(31 downto 0);
	signal	lb_lholda_signal 			:	std_logic;
	signal	lb_lintin_signal 			:	std_logic;						
	signal	lb_lw_rn_signal			:	std_logic;
	signal	lb_pmereon_signal 		:	std_logic;
	signal	lb_readyn_signal 			:	std_logic;
	signal	lb_useri_signal 			:	std_logic;
	
	signal output_gpio_wren				:	std_logic;
	signal rden								:	std_logic;
	
	signal ddr2_lb_adsn_signal			:	std_logic;
	
	signal input_gpio_en								:	std_logic;
	signal input_gpio_interrupt_register_en	:	std_logic;
	signal input_gpio_interrupt_enable			:	std_logic_vector(31 downto 0);
	signal input_gpio_interrupt_signal			:	std_logic_vector(31 downto 0);
	signal input_gpio_interrupt_ack				:	std_logic_vector(31 downto 0);
	signal input_gpio_interrupt_enabled_signal:	std_logic_vector(31 downto 0);
	signal input_gpio_interrupt_ack_en			:	std_logic;
	signal input_gpio_interrupt_reduced			:	std_logic;
	signal input_gpio_interrupt_enable_en		:	std_logic;
	signal input_gpio_interrupt_enable_wren	:	std_logic;
	signal input_gpio_interrupt					:	std_logic_vector(31 downto 0);
	signal input_gpio_interrupt_ack_wren		:	std_logic;
	
	signal output_gpio_register					:	std_logic_vector(31 downto 0);
	
	
	signal output_gpio_en				:	std_logic;
	signal interrupt_ack_en				:	std_logic;
	signal interrupt_en					:	std_logic_vector(31 downto 0):= (others => '0');
	signal gpio_output_register		:	std_logic_vector(31 downto 0):= (others => '0');
	signal gpio_input_signal			:	std_logic_vector(31 downto 0) := (others => '0');
	signal gpio_input_register			:	std_logic_vector(31 downto 0):= (others => '0');
	signal gpio_input_interrupt		:	std_logic_vector(31 downto 0):= (others => '0');
	signal local_interrupts				:	std_logic_vector(31 downto 0):= (others => '0');
	signal interrupt_ack					:	std_logic_vector(31 downto 0):= (others => '0');
	signal interrupt_signal				:	std_logic_vector(31 downto 0):= (others => '0');
	
	signal counter_overflow				:	std_logic;
	signal count_1Hz						:	unsigned(31 downto 0);
	signal frame_trigger					:	std_logic;
	signal counter_peripheral_en		:	std_logic;
	signal pxl_data_mux					:	std_logic_vector(15 downto 0);
	signal pxl_clk_mux					:	std_logic;
	
	signal pxl_clk_sim					:	std_logic;
	signal pxl_data_sim					:	std_logic_vector(15 downto 0);
	
	signal count_frame_trigger			:integer range 0 to (2**26) - 1 := 0;
	
	signal locked							:	std_logic;
	signal clk0_tb            			:	std_logic;
	signal rst0_tb            			: 	std_logic;
	signal app_af_afull       			: 	std_logic;
	signal app_wdf_afull      			: 	std_logic;
	signal rd_data_valid      			: 	std_logic;
	signal rd_data_fifo_out   			: 	std_logic_vector(64-1 downto 0);
	signal app_af_wren        			: 	std_logic;
	signal app_af_cmd         			: 	std_logic_vector(2 downto 0);
	signal app_af_addr        			: 	std_logic_vector(30 downto 0);
	signal app_wdf_wren       			: 	std_logic;
	signal app_wdf_data       			: 	std_logic_vector(64-1 downto 0);
	signal app_wdf_mask_data			: 	std_logic_vector((64/8)-1 downto 0);
	signal phy_init_done 				: 	std_logic;
	
	signal pxl_data						:	std_logic_vector(63 downto 0);
	signal pxl_data_ready				:	std_logic;
	signal pxl_addr						:	std_logic_vector(30 downto 0);
	signal app_wdf_data_signal			:	std_logic_vector(63 downto 0);
	signal pxl_addr_rst					:	std_logic;
	
	signal clk100M_SE						:	std_logic;
	
	signal camera_ila_signal			:	std_logic_vector(83 downto 0);
	signal camera_interface_ctrl_signal	:std_logic_vector(35 downto 0);
	signal ddr2_ila_ctrl_signal		:std_logic_vector(35 downto 0);
	signal ddr2_ila_signal				:std_logic_vector(172 downto 0);
	signal ddr2_interface_ila_ctrl_signal	:	std_logic_vector(35 downto 0);
	signal ddr2_interface_ila_signal	:std_logic_vector(148 downto 0);
	
	signal ddr2_wdf_wren		:std_logic;
	signal ddr2_af_wren		:std_logic;
	signal ddr2_cmd			:std_logic_vector(2 downto 0);
	signal ddr2_addr			:std_logic_vector(30 downto 0);
	signal ddr2_wrdata		:std_logic_vector(63 downto 0);
	signal ddr2_wrmask		:std_logic_vector(7 downto 0);
	
	signal ddr2_lb_la_signal	:std_logic_vector(29 downto 0);
	
	signal output_ddr2_addr_en :std_logic;
	signal output_ddr2_addr_wren :std_logic;
	signal output_ddr2_addr_register	:std_logic_vector(31 downto 0);
	signal output_ddr2_ctrl_en :std_logic;
	signal output_ddr2_ctrl_wren :std_logic;
	signal output_ddr2_ctrl_register	:std_logic_vector(31 downto 0);
	signal mig_af_wren	:std_logic;
	
	signal state			:std_logic_vector(3 downto 0);
	signal missed_frame 	:std_logic;
	signal dma_done_flag	:std_logic;
	signal frame_ready	:std_logic;
	
	signal software_self_destruct	:std_logic;
	signal hardware_self_destruct	:std_logic;
	signal initiate_destruct_sequence	:std_logic;
	
	signal ds_readyn_sel		:std_logic;
	signal ds_readyn_gpio_signal	:std_logic;
	signal ds_readyn_ddr_signal	:std_logic;
	signal ds_lb_blastn_signal	:std_logic;
	signal ddr2_lb_blastn_signal :std_logic;
	
	signal ddr2_read_en		:std_logic;
	
	signal ddr2_lb_ld			:std_logic_vector(31 downto 0);
	signal ddr2_lb_readyn	:std_logic;
	
	signal ddr2_clk0	:std_logic;
	signal ddr2_clk90	:std_logic;
	signal ddr2_clkdv	:std_logic;
	
	signal buffer_addr_rst	:std_logic;
	
	signal camera_pipeline_rst_n	:std_logic;
		
	signal ddr2_data_manager_icon_signal	:std_logic_vector(35 downto 0);
	signal local_bus_icon_signal	:std_logic_vector(35 downto 0);
	signal local_bus_ila_signal	:std_logic_vector(255 downto 0);
	
	signal lb_waitn_signal	:std_logic;
	
	signal frame_ready_signal	:std_logic;
	
	attribute keep :string;
	attribute keep of ddr2_data_manager_icon_signal: signal is "true";
	
	signal	ddr2_readyn_sel	:std_logic;
	
	signal	error_flag_signal	:std_logic;
	
	
	signal	reset_flag	:std_logic;
	
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
	constant	CLK_PERIOD 					:integer	:= 5000;
	constant	RST_ACT_LOW 				:integer	:= 1;
	
	
begin

	rstn	<=	lb_lresetn;
	
	lb_adsn <= lb_adsn_signal;
	lb_bigendn <= lb_bigendn_signal;
	lb_blastn <= lb_blastn_signal;
	lb_breqi <= lb_breqi_signal;
	lb_btermn <= lb_btermn_signal;
	lb_ccsn <= lb_ccsn_signal;
	lb_eotn <= lb_eotn_signal;
	lb_dp <= lb_dp_signal;
	lb_dreqn <= lb_dreqn_signal;
	lb_la <= lb_la_signal;
	lb_lben <= lb_lben_signal;
	lb_ld <= lb_ld_signal;
	lb_lholda <= lb_lholda_signal;
	lb_lintin <= lb_lintin_signal;
	lb_lw_rn <= lb_lw_rn_signal;
	lb_pmereon <= lb_pmereon_signal;
	lb_readyn <= lb_readyn_signal;
	lb_useri <= lb_useri_signal;

	PLX_ARBITER	:	plxArb
		port map(
			lresetn 			=>	rstn,
			lclk 				=>	clk50,	
			dsReq 			=>	lb_lhold,	-- This signal is used by the PCI9056 to request the Local Bus for a Direct Slave transfer
			dsAck 			=>	dsAck,		-- This signal grants the PCI9056 access to the Local Bus, asserted until lb_lhold is deasserted
			dsReqForce 		=>	lb_breqo,	--  
			dmReq 			=>	dmReq,		-- This signal 
			dmAck 			=>	dmAck,
			dmBackoff 		=>	dmBackoff,
			allClkStable 	=>	locked
		);
	

		gpio_address_valid <= '1' when (lb_la(31 downto 10) = (x"00000" & b"00")) else '0'; -- lb_la(31 downto 10) is used to select the
		ddr_address_valid <= '1' when (lb_la(31) = '1') else '0'; -- Use the MSB of the local bus address to select the DDR2 address space.
		address_valid <= gpio_address_valid or ddr_address_valid;
	
	PLX_SLAVE	:	plx32BitSlave
		port map(
			lresetn			=>	rstn,
			lclk				=>	clk50,
			ld_dir			=>	ds_ld_dir,
			lben				=>	lb_lben_signal,
			adsn				=>	lb_adsn,
			blastn			=>	lb_blastn_signal,
			readyn			=>	ds_readyn_gpio_signal,
			lw_rn				=>	lb_lw_rn,
			ArbiterAck		=> dsAck,
			address_valid	=>	address_valid
	);
	--lb_blastn_signal <= ds_lb_blastn_signal when ds_readyn_sel = '0' else ddr2_lb_blastn_signal;
	ds_readyn <= ds_readyn_gpio_signal when ds_readyn_sel = '0' else ddr2_lb_readyn;
	ds_readyn_sel <= ddr2_read_en;
	
	PLX_MASTER	:	plx32BitMaster
		generic map (	
			c_cfgRomSize 	=> 18,
			c_ramWidth 		=> 4,
			c_txfrCntWidth => 6,
			c_enPlxCfg 		=> TRUE)
		port map (
			lclk				=>	clk50,
			la					=>	dm_la,
			ld_dir			=>	dm_ld_dir,
			lben				=> dm_lben,
			adsn				=>	dm_adsn,						
			blastn			=>	dm_blastn,
			readyn			=>	lb_readyn,
			lw_rn				=>	dm_lw_rn,
			lresetn			=>	rstn,
			ccsn				=>	lb_ccsn_signal,
			dmpaf				=>	lb_eotn_signal,
			req				=>	dmReq,
			ack				=>	dmAck,
			backoff			=>	dmBackoff,
			txfrCtrl			=>	b"00",
			txfrAddr			=>	x"00000000",
			txfrCnt			=>	b"000000",
			int				=> open,
			cfgComplete		=>	cfgComplete,
			ramAddr 			=> open,
			ramWr 			=> open,
			ramEn 			=> open,
			cfgRomPtr 		=> cfgRomAddr,
			cfgRomDout		=> cfgRomDout,
			stateOut 		=> open
		);
		
	LB_ILA0 : LOCAL_BUS_ILA
	  port map (
		 CONTROL => local_bus_icon_signal,
		 CLK => clk50,
		 TRIG0 => local_bus_ila_signal);
		 
		 local_bus_ila_signal(0) <= lb_adsn_signal;
		 local_bus_ila_signal(1) <= lb_bigendn_signal;
		 local_bus_ila_signal(2) <= lb_blastn_signal;
		 local_bus_ila_signal(3) <= lb_breqi_signal;
		 local_bus_ila_signal(4) <= lb_breqo;
		 local_bus_ila_signal(5) <= lb_btermn_signal;
		 local_bus_ila_signal(6) <= lb_ccsn_signal;
		 local_bus_ila_signal(8 downto 7) <= lb_dackn;
		 local_bus_ila_signal(9) <= lb_eotn_signal;
		 local_bus_ila_signal(13 downto 10) <= lb_dp_signal;
		 local_bus_ila_signal(15 downto 14) <= lb_dreqn_signal;
		 local_bus_ila_signal(45 downto 16) <= lb_la_signal;
		 local_bus_ila_signal(49 downto 46) <= lb_lben_signal;
		 local_bus_ila_signal(81 downto 50) <= lb_ld_signal;
		 local_bus_ila_signal(82) <= lb_lhold;
		 local_bus_ila_signal(83) <= lb_lholda_signal;
		 local_bus_ila_signal(84) <= lb_lintin_signal;
		 local_bus_ila_signal(85) <= lb_linton;
		 local_bus_ila_signal(86) <= lb_lresetn;
		 local_bus_ila_signal(87) <= lb_lserrn;
		 local_bus_ila_signal(88) <= lb_lw_rn_signal;
		 local_bus_ila_signal(89) <= lb_pmereon_signal;
		 local_bus_ila_signal(90) <= lb_readyn_signal;
		 local_bus_ila_signal(91) <= lb_useri_signal;
		 local_bus_ila_signal(92) <= lb_usero;
		 local_bus_ila_signal(93) <= lb_waitn_signal;
		 local_bus_ila_signal(94) <= plx_hostenn;
		 local_bus_ila_signal(95) <= ddr2_read_en;
		 local_bus_ila_signal(96) <= ds_readyn_sel;
		 local_bus_ila_signal(97) <= ds_readyn;
		 local_bus_ila_signal(98) <= ds_readyn_gpio_signal;
		 local_bus_ila_signal(99) <= ddr2_lb_readyn;
		 local_bus_ila_signal(100) <= ds_ld_dir;
		 local_bus_ila_signal(101) <= dm_ld_dir;
		 local_bus_ila_signal(133 downto 102) <= ddr2_lb_ld;
		 local_bus_ila_signal(255 downto 134) <= (others => '1');
	
		lb_waitn_signal <= lb_waitn;
		
		
	
		------------------------------------
		--  LOCAL BUS SIGNAL ASSIGNMENTS  --
		------------------------------------
		lb_adsn_signal		<= dm_adsn 		when dmAck = '1' else 'Z';		--local bus address strobe, driven by plx32BitMaster when local bus is in Direct Master Mode, else it is high-Z
		lb_bigendn_signal <= '1';						-- PU on board
		lb_blastn_signal	<= dm_blastn	when dmAck = '1' else 'Z';		--local bus burst last signal, input to slave devices, driven by plx32BitMaster when given control by arbiter, else high-Z
		lb_breqi_signal 	<= 'Z'; 						-- PD on board
		--lb_btermn_signal 	<= 'Z';						-- PU on board
		lb_eotn_signal 	<= 'Z'; 						-- PU on board
		lb_dp_signal 		<= (others => 'Z'); 		-- PU on board
		lb_dreqn_signal 	<= (others => 'Z');		-- PU on board
		lb_la_signal		<= dm_la 		when dmAck = '1' else (others => 'Z');		--local bus physical address, driven by plx32BitMaster when given control by arbiter, else high-Z
		lb_lben_signal		<= dm_lben 		when dmAck = '1' else (others =>'Z');		--local bus
		lb_lholda_signal 	<= dsAck;
		lb_lw_rn_signal	<= dm_lw_rn 	when dmAck = '1' else 'Z';
		lb_pmereon_signal <= 'Z';						-- PU on board
		lb_readyn_signal	<= ds_readyn	when dsAck = '1' else 'Z';
		lb_useri_signal 	<= 'Z';						-- PU on board
		lb_ld_signal 		<= ld_out_signal when dm_ld_dir = '1' or ds_ld_dir = '1' or ddr2_read_en = '1' else (others => 'Z');
		
		u_CfgRom: plxCfgRom 
			port map(
				clk 				=> clk50,
				addr				=> cfgRomAddr,
				dout 				=> cfgRomDout
			); 
		
			IBUFGDS0 : IBUFGDS
		generic map (
			IOSTANDARD => "LVDS_25")
		port map (
			O => clk100M_SE,  -- Clock buffer output
			I => mainclkp,  -- Diff_p clock buffer input
			IB => mainclkn -- Diff_n clock buffer input
		);
		
		--------------
		-- CLOCKING --
		--------------
		CLK_CONTROL: clkControlMem_JAH
		 port map( 
			clk100M_SE		=> clk100M_SE,
			lb_lclko			=> lb_lclko_plx,
			lb_lclko_loop	=> lb_lclko_loop,
			lb_lclko_fb		=> lb_lclko_fb,
			clk50 			=> clk50,
			ddr2_clk200 	=> ddr2_clk0,
			locked			=> locked
		);

		
		----------------
		-- USER LOGIC --
		----------------	
		input_gpio_en <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"00") ) else '0';
		input_gpio_interrupt_enable_en <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"01")) else '0';
		input_gpio_interrupt_ack_en	<= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"02")) else '0';
		input_gpio_interrupt_register_en	 <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"03")) else '0';
		counter_peripheral_en <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"04")) else '0';
		output_gpio_en <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"05") ) else '0';	
		output_ddr2_addr_en <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"06") ) else '0';
		output_ddr2_ctrl_en <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"07") ) else '0';
		ddr2_read_en <= '1' when ((address_valid = '1') and (lb_la(9 downto 2) = x"08")) else '0';
		
		--INPUT GPIO REGISTER
		P_INPUT_GPIO	:	reg32_ReadOnly
		 port map( 
			clk 				=> clk50,	-- System clock signal
			rst_n				=> rstn,	-- Active-low reset signal
			user_D	 		=> gpio_input_signal, 	-- This is the register bank input signals that can be mapped to logic in the user design
			user_Q	 		=> input_gpio_register,	-- This is the register bank output signals that can be mapped to logic in the user design
			interrupt		=> input_gpio_interrupt
		);
		gpio_input_signal(31) <= frame_ready_signal;
		gpio_input_signal(30 downto 27)	<= fsm_state_signal;
		gpio_input_signal(14 downto 0) <= gpio_in;
		gpio_input_signal(26) <= error_flag_signal;
		gpio_input_signal(25 downto 15)	<= (others => '0');
		
		--INPUT GPIO INTERRUPT ENABLE REGISTER
		P_INPUT_GPIO_INTERRUPT_ENABLE	:	reg32_ReadWrite
		 port map( 
			clk 				=> clk50,	-- System clock signal
			rst_n				=> rstn,	-- Active-low reset signal
			wren	 			=> input_gpio_interrupt_enable_wren,-- Register bank select signal
			lb_lben			=> lb_lben_signal,
			user_D	 		=> lb_ld,	-- This is the register bank input signals that can be mapped to logic in the user design
			user_Q	 		=> input_gpio_interrupt_enable	-- This is the register bank output signals that can be mapped to logic in the user design			
		);
		input_gpio_interrupt_enable_wren <= input_gpio_interrupt_enable_en and lb_lw_rn and (not ds_readyn_gpio_signal);
		input_gpio_interrupt_enabled_signal <= input_gpio_interrupt and input_gpio_interrupt_enable;
		
		--INPUT GPIO INTERRUPT ACK LOGIC
		process(clk50,rstn) is
		begin
			if (rstn = '0') then
				input_gpio_interrupt_ack <= (others => '0');
			elsif (clk50'event and clk50 = '1') then
				if (input_gpio_interrupt_ack_wren = '1') then 
					input_gpio_interrupt_ack <= lb_ld;
				else
					input_gpio_interrupt_ack <= (others => '0');
				end if;
			end if;
		end process;		
		input_gpio_interrupt_ack_wren <= input_gpio_interrupt_ack_en and lb_lw_rn and (not ds_readyn_gpio_signal);
		
		--INPUT GPIO INTERRUPT LOGIC
		P_INPUT_GPIO_INTERRUPT_LOGIC	:	interrupt_logic
		port map(
			clk				=> clk50,
			rst_n				=> rstn,
			set				=> input_gpio_interrupt_enabled_signal,	--These are the interrupts from the local logic
			clear				=> input_gpio_interrupt_ack,	--These are the interrupt acknowledgments from the INTACK local bus slave logic
			interrupt		=> input_gpio_interrupt_signal	--These are the interrupt signals that are latched high when set until ACK clears is
		);
		input_gpio_interrupt_reduced <= or_reduce(input_gpio_interrupt_signal);
		lb_lintin_signal <= not input_gpio_interrupt_reduced;
		
		
		OUTPUT_GPIO	:	reg32_ReadWrite
		 port map( 
			clk 				=> clk50,	-- System clock signal
			rst_n				=> rstn,	-- Active-low reset signal
			wren	 			=> output_gpio_wren,-- Register bank select signal
			lb_lben			=> lb_lben_signal,
			user_D	 		=> lb_ld,	-- This is the register bank input signals that can be mapped to logic in the user design
			user_Q	 		=> output_gpio_register	-- This is the register bank output signals that can be mapped to logic in the user design			
		);
		output_gpio_wren <= output_gpio_en and lb_lw_rn and (not ds_readyn_gpio_signal);
		gpio_out(11 downto 0) <= output_gpio_register(11 downto 0);
		
		OUTPUT_DDR2_ADDR	:	reg32_ReadWrite
		 port map( 
			clk 				=> clk50,	-- System clock signal
			rst_n				=> rstn,	-- Active-low reset signal
			wren	 			=> output_ddr2_addr_wren,-- Register bank select signal
			lb_lben			=> lb_lben_signal,
			user_D	 		=> lb_ld,	-- This is the register bank input signals that can be mapped to logic in the user design
			user_Q	 		=> output_ddr2_addr_register	-- This is the register bank output signals that can be mapped to logic in the user design			
		);
		output_ddr2_addr_wren <= output_ddr2_addr_en and lb_lw_rn and (not ds_readyn_gpio_signal);
				
		OUTPUT_DDR2_CTRL	:	reg32_ReadWrite
		 port map( 
			clk 				=> clk50,	-- System clock signal
			rst_n				=> rstn,	-- Active-low reset signal
			wren	 			=> output_ddr2_ctrl_wren,-- Register bank select signal
			lb_lben			=> lb_lben_signal,
			user_D	 		=> lb_ld,	-- This is the register bank input signals that can be mapped to logic in the user design
			user_Q	 		=> output_ddr2_ctrl_register	-- This is the register bank output signals that can be mapped to logic in the user design			
		);
		output_ddr2_ctrl_wren <= output_ddr2_ctrl_en and lb_lw_rn and (not ds_readyn_gpio_signal);
		
		
		-- LED Output Signal Assignment
		user_led(1 downto 0) <= output_gpio_register(13 downto 12);
		user_led(3) <= locked;
		user_led(2) <= reset_flag;
		
		---------------------------------
		-- LOCAL BUS OUTPUT ASSIGNMENT --
		---------------------------------
		p_ld_out : process(dmAck,dsAck,input_gpio_en,output_gpio_en,gpio_input_register,output_gpio_register,cfgComplete,cfgRomDout,local_bus_gpio,
								 input_gpio_interrupt_register_en,input_gpio_interrupt_signal)
		begin
			if dmAck='1' then
				if cfgComplete = '1' then
						ld_out_signal <=	(others => '0'); --local_bus_gpio;	PLACE HOLDER UNTIL A BUS MASTER IS DESIGNED
				else
						ld_out_signal <=	cfgRomDout(31 downto 0);
				end if;
			elsif (dsAck = '1') then				
				if (input_gpio_en = '1') then
					ld_out_signal <= input_gpio_register;
				elsif (input_gpio_interrupt_enable_en = '1' and lb_lw_rn = '0') then
					ld_out_signal <= input_gpio_interrupt_enable;
				elsif (input_gpio_interrupt_register_en = '1' and lb_lw_rn = '0') then
					ld_out_signal <= input_gpio_interrupt_signal;
				elsif (output_gpio_en = '1' and lb_lw_rn = '0') then
					ld_out_signal <= output_gpio_register;
				elsif (output_ddr2_ctrl_en = '1' and lb_lw_rn = '0') then
					ld_out_signal <= output_ddr2_ctrl_register;
				elsif (output_ddr2_addr_en = '1' and lb_lw_rn = '0') then
					ld_out_signal <= output_ddr2_addr_register;
				elsif (counter_peripheral_en = '1' and lb_lw_rn = '0') then
					ld_out_signal <= std_logic_vector(count_1Hz);
				elsif (ddr2_read_en = '1') then
					ld_out_signal <= ddr2_lb_ld;
				else
					ld_out_signal <= x"DEADBEEF";
				end if;				
			else
				ld_out_signal <= x"DDDDDDDD";
			end if;
		end process p_ld_out;	
		
	------------------------------------------------------------------------------------------
	--						SELF_DESTRUCT0																			 --
	------------------------------------------------------------------------------------------
	-- This code is used to trigger a power-down of the VDX system.  After receiving        --
	-- This code is used to trigger a power-down of the VDX system.  After receiving        --
	-- a shutdown signal from either the application software or through the corresponding  --
	-- input GPIO pin, the POWER_DOWN_TIMER begins a 4-second countdown sequence to         --
	-- power down.  At the expiry of this countdown the shutdown signal output is asserted  --
	-- resulting in removal of system power.																 --	
	------------------------------------------------------------------------------------------
	SELF_DESTRUCT0	: POWER_DOWN_TIMER
		port map(
			clk		=> clk50,
			rst_n		=> output_gpio_register(26), --rstn,
			initiate_destruct_sequence		=> initiate_destruct_sequence,
			self_destruct	=> self_destruct
		);
	software_self_destruct <= output_gpio_register(28);
	hardware_self_destruct <= input_gpio_register(31);
	initiate_destruct_sequence <= hardware_self_destruct or software_self_destruct;
	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------
		
		
	------------------------------------------------------------------------------------------
	--							COUNTER0																				 --
	------------------------------------------------------------------------------------------
	-- This code is a simple counter used to generate periodic overflow flags to generate   --	
	-- simulated system events. This particular counter is a 1-Hz (@ 50-MHz clock) counter. --
	-- The counter_overflow output is asserted (high) for one cycle every second.				 --
	------------------------------------------------------------------------------------------	
		COUNTER0	:	counter_peripheral
			port map(
				clk	=> clk50,
				rst_n	=> output_gpio_register(26), --rstn,
				count_overflow	=> counter_overflow
			);			
	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------
		
	------------------------------------------------------------------------------------------
	--							COUNTER1																				 --
	------------------------------------------------------------------------------------------
	-- This code is used to generate a simulated frame trigger signal every four seconds.   --
	-- The minimum frame interval on the MOSES experiment is four seconds, so this can be   --
	-- used to simulate worst-case timing scenario for the Acquire-Buffer-DMA data flow.    --
	------------------------------------------------------------------------------------------
		COUNTER1	:	process(clk50,output_gpio_register(26),counter_overflow) is			
		begin
			if (output_gpio_register(26) = '0') then
				count_1Hz <= (others => '0');
				count_frame_trigger <= 0;
				frame_trigger <= '0';
			elsif (clk50'event and clk50 = '1') then
				frame_trigger <= '0';
				if (counter_overflow = '1') then
					count_1Hz <= count_1Hz + 1;
					count_frame_trigger <= count_frame_trigger + 1;
					if (count_frame_trigger = 3) then
						frame_trigger <= '1';
						count_frame_trigger <= 0;
					end if;
				end if;
			end if;
		end process;
		
		process(clk50,output_gpio_register(26)) is
		begin
			if (output_gpio_register(26) = '0') then
				reset_flag <= '1';
			elsif (clk50'event and clk50 = '1') then
				reset_flag <= reset_flag;
				if (frame_trigger = '1') then
					if (reset_flag = '1') then
						reset_flag <= '0';
					end if;
				end if;
			end if;			
		end process;
		
	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------
		
	------------------------------------------------------------------------------------------
	--						CAMERA_SIM0																				 --
	------------------------------------------------------------------------------------------
	-- This code simulates input from the ROE and is used for testing the data path and     --
	-- control logic in the FPGA.  This input into the datapath is selectable by the camera --
	-- multiplexer CAMERA_MUX0.  The trigger signal initiates a readout sequence.  There    --
	-- are four frames per image acquisition (3-CCDs + 1-Noise Channel). Each frame is      --
	-- 1024x2048 pixels in size.  There are 14 data bits per pixel (D(13:0)) and two frame  --
	-- identifier bits (D(15:14)).  All 16-bits are stored as data and passed to the host   --
	-- PC for storage.  In the camera_sim logic, the column data are simply a ramp from 0 to--
	-- 2047 repeating for each line.
	------------------------------------------------------------------------------------------
	camera_pipeline_rst_n <= (not buffer_addr_rst) and output_gpio_register(26);
		CAMERA_SIM0	:	camera_sim
			port map(
				clk		=> clk50,	-- system input clock
				rst_n		=> camera_pipeline_rst_n,	-- system reset signal (active-low)
				trigger	=> output_gpio_register(27),--frame_trigger,	-- frame enable signal (trigger the start of a frame)
				
				pxl_clk	=> pxl_clk_sim, 
				pxl_data	=> pxl_data_sim		
			);
	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------
	
			
	------------------------------------------------------------------------------------------
	--						CAMERA_INTERFACE0																		 --
	------------------------------------------------------------------------------------------
	-- This code receives camera data from the camera input multiplexer, synchronizes it to --
	-- the system clock (clk50), generates the pixel address signal, and drives a flag to   --
	-- indicate when a 32-bit word of data is ready at the output.  Since the camera        --
	-- interface is 16-bits, data are run through a shift register in order to match the    --
	-- local bus data width.  																					 --
	------------------------------------------------------------------------------------------
		CAMERA_INTERFACE0	: camera_interface
		 port map (
					clk 				=> clk50,
					rst_n 			=> camera_pipeline_rst_n,
					pxl_data_in 	=> pxl_data_mux,
					pxl_clk_in 		=>	pxl_clk_mux	,	
					pxl_data_out	=> pxl_data,
					pxl_data_ready	=> pxl_data_ready
					);
	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------	
	
		
		
	------------------------------------------------------------------------------------------
	--						CAMERA_MUX0																		       --
	------------------------------------------------------------------------------------------
	-- This code selects between two sources for the camera interface logic.  The first     --
	-- source is the camera simulation logic, which produces a ramp value across each row   --
	-- in the image.  The second source is the camera data input from the ROE.  Selection   --
	-- is controlled by output_gpio_register(30).
	------------------------------------------------------------------------------------------
		CAMERA_MUX0	: process(output_gpio_register(30)) is
		begin
			case (output_gpio_register(30)) is
				when '0' =>
					pxl_data_mux <= pxl_data_sim;
					pxl_clk_mux <= pxl_clk_sim;
				when others =>
					pxl_data_mux <= camera_data_in;
					pxl_clk_mux <= camera_pxl_clk_in;
			end case;
		end process;
	------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------
			 
	 CAMERA_ICON0 : Camera_Interface_ICON
		port map (
			CONTROL0 => ddr2_data_manager_icon_signal,
			CONTROL1 => local_bus_icon_signal);
		
	u_DDR2_CORE : DDR2_CORE_JAH
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
			ddr2_dq                    => ddr2_dq,
			ddr2_a                     => ddr2_a,
			ddr2_ba                    => ddr2_ba,
			ddr2_ras_n                 => ddr2_ras_n,
			ddr2_cas_n                 => ddr2_cas_n,
			ddr2_we_n                  => ddr2_we_n,
			ddr2_cs_n                  => ddr2_cs_n,
			ddr2_odt                   => ddr2_odt,
			ddr2_cke                   => ddr2_cke,
			ddr2_dm                    => ddr2_dm,
			sys_clk                    => ddr2_clk0,
			idly_clk_200               => ddr2_clk0,
			sys_rst_n                  => rstn, --output_gpio_register(26)
			phy_init_done              => phy_init_done,
			rst0_tb                    => rst0_tb,
			clk0_tb                    => clk0_tb,
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
			ddr2_dqs                   => ddr2_dqs,
			ddr2_dqs_n                 => ddr2_dqs_n,
			ddr2_ck                    => ddr2_ck,
			ddr2_ck_n                  => ddr2_ck_n
		);
	
	ddr2_lb_la_signal <= '0' & lb_la(30 downto 2);
	ddr2_lb_adsn_signal <= not (not lb_adsn_signal and ddr2_read_en);
	DDR2_Manager0	:	DDR2_DataManager
		port map(
			clk					=> clk50,
			rst_n					=> output_gpio_register(26),
			error_flag			=> error_flag_signal,
			
			-- User Data Interface
			-- Camera data for writing to DDR2
			pxl_data				=> pxl_data,
			pxl_data_ready		=> pxl_data_ready,
			
			-- PLX signals for reading the data out of DDR2
			lb_adsn				=> ddr2_lb_adsn_signal,
			lb_la					=> ddr2_lb_la_signal,--output_ddr2_addr_register(29 downto 0),--ddr2_lb_la_signal,
			lb_readyn			=> ddr2_lb_readyn,
			lb_blastn			=> lb_blastn_signal,--ddr2_lb_blastn_signal,
			lb_ld					=> ddr2_lb_ld,
			lb_btermn		 	=> lb_btermn_signal,
			lb_waitn				=> lb_waitn_signal,
			
			-- User Control Interface
			control				=> output_ddr2_ctrl_register(31 downto 24),
			fsm_state			=> fsm_state_signal,
			frame_ready			=> frame_ready_signal,
			ddr2_readyn_sel	=> ddr2_readyn_sel,
			
			-- DDR2 Interface
			ddr2_clk				=> clk0_tb,
			ddr2_rst				=> rst0_tb,
			app_wdf_wren      => app_wdf_wren,
			app_af_wren       => app_af_wren,
			app_af_cmd        => app_af_cmd,
			app_wdf_mask_data => app_wdf_mask_data,
			app_wdf_data      => app_wdf_data,
			app_af_addr       => app_af_addr,
			rd_data_fifo_out  => rd_data_fifo_out,
			rd_data_valid		=> rd_data_valid,
			buffer_addr_rst	=> buffer_addr_rst,
			ILA_CONTROL			=> ddr2_data_manager_icon_signal
		);

end Behavioral;