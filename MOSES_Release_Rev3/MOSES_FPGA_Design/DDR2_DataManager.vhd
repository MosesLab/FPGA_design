----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:03:57 10/12/2014 
-- Design Name: 
-- Module Name:    DDR2_DataManager - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity DDR2_DataManager is
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
end DDR2_DataManager;

architecture Behavioral of DDR2_DataManager is

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
			read_fifo_data				:out	std_logic_vector(63 downto 0);
			read_fifo_data_empty		:out	std_logic;
			read_fifo_data_en			:in	std_logic;
			read_fifo_rdcount			:out	std_logic_vector(8 downto 0);
			write_data_fifo_empty	:out	std_logic;
			addr_fifo_empty			:out	std_logic;
			rst_rd_fifo					:in	std_logic;		
			data_read_error			:out	std_logic;
			data_write_error			:out	std_logic;
			addr_write_error			:out	std_logic
		);
	end component;
	
	component REG_GENERIC
		 Generic (WIDTH	:integer := 8);
		 Port ( clk : in  STD_LOGIC;
				  rst_n : in  STD_LOGIC;
				  D : in  STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
				  Q : out  STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0));
	end component;
	
	component DFF
		 Port ( clk : in  STD_LOGIC;
				  rst_n : in  STD_LOGIC;
				  D : in  STD_LOGIC;
				  Q : out  STD_LOGIC);
	end component;
	
	component DDR2_DataManager_ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 TRIG0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
		 TRIG1 : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
		 TRIG2 : IN STD_LOGIC_VECTOR(255 DOWNTO 0));
	end component;

	

	
	type	STATE	is	(IDLE,BUFFER_DATA0,BUFFER_DATA1,BUFFER_LOAD_ADDR,DMA_INIT,DMA_IDLE,DMA_DDR_FETCH,DMA_DATA_WAIT,DMA_DATA0,
						 DMA_DATA1,DMA_DATA2,DMA_DATA3,DMA_DATA1_WAIT,DMA_DATA2_WAIT,DMA_DATA3_WAIT);
	signal CurrentState	:STATE	:= IDLE;
	signal NextState		:STATE	:= IDLE;
	
	signal fsm_cmd			:std_logic_vector(2 downto 0);
	signal addr_sel		:std_logic;
	signal read_fifo_data_en	:std_logic;
	signal read_fifo_data	:std_logic_vector(63 downto 0);
	signal read_fifo_data_reg	:std_logic_vector(63 downto 0);
	signal read_fifo_data_empty_signal	:std_logic;
	signal write_data_fifo_empty	:std_logic;
	signal write_data_fifo_empty_reg	:std_logic;
	signal fifo_fsm_rstn_signal	:std_logic;
	signal fifo_rstn_signal	:std_logic;
	signal buffer_addr_signal	:unsigned(30 downto 0) := (others => '0');
	signal buffer_addr_rdy_signal	:std_logic;
	signal buffer_addr_rst_signal :std_logic;
	signal addr_rdy_mux_signal	:std_logic;
	signal addr_fifo_empty_signal	:std_logic;
	signal dma_addr_rdy_signal	:std_logic;
	signal addr_in_mux_signal :std_logic_vector(30 downto 0);
	signal dma_addr_signal	:std_logic_vector(30 downto 0);
	signal read_fifo_rdcount :std_logic_vector(8 downto 0);
	signal read_fifo_rdcount_reg	:std_logic_vector(8 downto 0);
	signal lb_readyn_signal :std_logic;
	signal lb_ld_signal	:std_logic_vector(31 downto 0);
	signal frame_ready_signal	:std_logic;
	signal lb_btermn_signal	:std_logic;
	
	signal rst_rd_fifo_signal	:std_logic;
	
	signal app_wdf_wren_signal :std_logic;
	signal app_wdf_data_signal :std_logic_vector(63 downto 0);
	
	signal error_flag_signal	:std_logic;
	
	signal fsm_state_signal :std_logic_vector(3 downto 0);
	
	signal ddr2_addr_inc	:std_logic;
	signal ddr2_readyn_sel_signal	:std_logic;
	
	signal ddr2_fsm_ila_signal :std_logic_vector(255 downto 0);
	signal ddr2_burst_controller_ila_signal :std_logic_vector(255 downto 0);
	
	signal dma_addr_inc_signal :std_logic;
	signal frame_error_signal	:std_logic;
	signal frame_error_count_en	:std_logic;
	signal frame_error_count	:unsigned(31 downto 0)	:= (others => '0');

	signal data_read_error_signal		:std_logic;
	signal data_write_error_signal	:std_logic;
	signal addr_write_error_signal	:std_logic;
	
	signal lb_waitn_signal			:std_logic;
	
	
	attribute keep	:string;
	attribute keep of buffer_addr_signal :signal is "true";
	
	

begin

	lb_waitn_signal <= lb_waitn;
	ddr2_readyn_sel <= ddr2_readyn_sel_signal;
	lb_btermn <= lb_btermn_signal;
	frame_ready <= frame_ready_signal or frame_error_signal;
	buffer_addr_rst <= buffer_addr_rst_signal;
	
	fifo_rstn_signal <= fifo_fsm_rstn_signal and rst_n;
	-- STATE MEMORY
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			CurrentState <= IDLE;
		elsif(clk'event and clk = '1') then
			CurrentState <= NextState;
		end if;
	end process;
	
	-- NEXT-STATE LOGIC
	process(clk,rst_n,CurrentState,control,buffer_addr_signal,pxl_data_ready,read_fifo_data_empty_signal,lb_blastn,lb_adsn,frame_error_signal) is
	begin
		NextState <= CurrentState;
		case (CurrentState) is
			when IDLE =>
				if (control = "00000001") then
					NextState <= BUFFER_DATA0;
				end if;
			when BUFFER_DATA0 =>
				if (frame_error_signal = '1') then
					NextState <= DMA_INIT;
				else
					if (pxl_data_ready = '1') then
						NextState <= BUFFER_DATA1;
					end if;
				end if;
			when BUFFER_DATA1 =>
				if (frame_error_signal = '1') then
					NextState <= DMA_INIT;
				else
					if (pxl_data_ready = '1') then
						NextState <= BUFFER_LOAD_ADDR;
					end if;
				end if;
				
			when BUFFER_LOAD_ADDR =>
				if (frame_error_signal = '1') then
					NextState <= DMA_INIT;
				else
					if ((buffer_addr_signal = 4194300)) then
						NextState <= DMA_INIT;
					else
						NextState <= BUFFER_DATA0;
					end if;
				end if;
				
			when DMA_INIT =>
				NextState <= DMA_IDLE;
			when DMA_IDLE =>
				if (control = "00000010") then
					NextState <= IDLE;
				else
					if (lb_adsn = '0') then
						NextState <= DMA_DDR_FETCH;
					end if;
				end if;
			when DMA_DDR_FETCH =>
				NextState <= DMA_DATA_WAIT;
			when DMA_DATA_WAIT =>
				if (read_fifo_data_empty_signal = '0') then
					NextState <= DMA_DATA0;
				end if;
			when DMA_DATA0 =>
				NextState <= DMA_DATA1_WAIT;
			when DMA_DATA1_WAIT =>	
				if (lb_adsn = '0') then
					NextState <= DMA_DATA1;
				end if;
			when DMA_DATA1 =>
				NextState <= DMA_DATA2_WAIT;
			when DMA_DATA2_WAIT =>
				if (lb_adsn = '0') then
					NextState <= DMA_DATA2;
				end if;
			when DMA_DATA2 =>
				NextState <= DMA_DATA3_WAIT;
			when DMA_DATA3_WAIT =>
				if (lb_adsn = '0') then
					NextState <= DMA_DATA3;
				end if;
			when DMA_DATA3 =>
				NextState <= DMA_IDLE;
		end case;
	end process;
	
	-- OUTPUT LOGIC
	process(CurrentState) is
	begin
		rst_rd_fifo_signal <= '0';
		case (CurrentState) is
			
			when IDLE =>
				fsm_cmd 					<= "000";
				addr_sel 				<= '0';
				buffer_addr_rst_signal 		<= '1';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "0000";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '0';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when BUFFER_DATA0 =>
				fsm_cmd 					<= "000";
				addr_sel 				<= '0';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "0001";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '0';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '1';
			when BUFFER_DATA1 =>
				fsm_cmd 					<= "000";
				addr_sel 				<= '0';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "0010";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '0';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '1';
			when BUFFER_LOAD_ADDR =>
				fsm_cmd 					<= "000";
				addr_sel 				<= '0';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "0011";
				buffer_addr_rdy_signal <= '1';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '0';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '1';
			when DMA_INIT =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '1';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '0';
				fsm_state_signal		<= "0100";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '1';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when DMA_IDLE =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "0101";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when DMA_DDR_FETCH =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "0110";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '1';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when DMA_DATA_WAIT =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= (others => '1');
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "0111";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when DMA_DATA0 =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '0';
				lb_ld_signal			<= read_fifo_data_reg(31 downto 0);
				read_fifo_data_en 	<= '0'; --JAH
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "1000";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when DMA_DATA1_WAIT =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= read_fifo_data_reg(63 downto 32);
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "1001";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';			
			when DMA_DATA1 =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '0';
				lb_ld_signal			<= read_fifo_data_reg(63 downto 32);
				read_fifo_data_en 	<= '1'; --JAH
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "1010";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when DMA_DATA2_WAIT =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= read_fifo_data_reg(63 downto 32);
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "1011";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';				
			when DMA_DATA2 =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '0';
				lb_ld_signal			<= read_fifo_data_reg(31 downto 0);
				read_fifo_data_en 	<= '0'; --JAH
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "1100";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
			when DMA_DATA3_WAIT =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '1';
				lb_ld_signal			<= read_fifo_data_reg(63 downto 32);
				read_fifo_data_en 	<= '0';
				fifo_fsm_rstn_signal	<= '1';
				fsm_state_signal		<= "1101";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '0';
				frame_error_count_en <= '0';
				
			when DMA_DATA3 =>
				fsm_cmd 					<= "001";
				addr_sel 				<= '1';
				buffer_addr_rst_signal 		<= '0';
				lb_readyn_signal		<= '0';
				lb_ld_signal			<= read_fifo_data_reg(63 downto 32);
				read_fifo_data_en 	<= '1';
				fifo_fsm_rstn_signal	<= '0';
				fsm_state_signal		<= "1110";
				buffer_addr_rdy_signal <= '0';
				frame_ready_signal	<= '0';
				lb_btermn_signal 		<= '1';
				ddr2_readyn_sel_signal <= '1';
				dma_addr_rdy_signal	<= '0';
				dma_addr_inc_signal <= '1';
				frame_error_count_en <= '0';
		end case;
	end process;
	
	lb_readyn <= lb_readyn_signal;
	lb_ld <=  lb_ld_signal;
	fsm_state <= fsm_state_signal;
	
	-- ERROR DETECTION LOGIC
	
	process(clk,rst_n,lb_readyn_signal,app_wdf_data_signal) is
	begin
		if (rst_n = '0') then
			error_flag_signal <= '0';
		elsif (clk'event and clk = '1') then
			error_flag_signal <= '0';			
			if (lb_readyn_signal = '0') then
				if (lb_ld_signal /= x"BEEFBEEF") then
					error_flag_signal <= '1';
				end if;
			end if;
		end if;
	end process;
	error_flag <= error_flag_signal;
	
	-- addr_in_mux signal generation
	addr_in_mux_signal <= std_logic_vector(buffer_addr_signal);-- when addr_sel = '0' else dma_addr_signal;
	addr_rdy_mux_signal <= buffer_addr_rdy_signal when addr_sel = '0' else dma_addr_rdy_signal;
	
	ddr2_addr_inc <= buffer_addr_rdy_signal when addr_sel = '0' else (dma_addr_inc_signal);
	-- Buffer Address Generation
	process(clk,buffer_addr_rst_signal,ddr2_addr_inc) is
	begin
		if (clk'event and clk = '1') then
			if ((buffer_addr_rst_signal = '1')) then
					buffer_addr_signal <= (others => '0');
			else
				if (ddr2_addr_inc = '1') then
					buffer_addr_signal <= buffer_addr_signal + 4; -- Increment by 4 in burst-4 mode
				end if;
			end if;
		end if;
	end process;
	
	-- DMA Address Generation
	dma_addr_signal <= '0' & lb_la;
	--dma_addr_rdy_signal <= not lb_adsn;

	DDR2_BC0	:	DDR2_BurstController
		port map(
			clk_usr		=> clk,
			clk_ddr2		=> ddr2_clk,
			rst_n			=> rst_n,
			rst_mig		=> ddr2_rst,
			
			--Instrument Interface
			data_in		=> pxl_data, -- USED ONLY IN BUFFER MODE
			addr_in		=> addr_in_mux_signal, -- MULTIPLE SOURCES DEPENDING ON BUFFER/DMA MODE
			cmd_in		=> fsm_cmd, -- SOURCED FROM FSM DEPENDING ON BUFFER/DMA MODE
			data_rdy		=> pxl_data_ready, -- USED ONLY IN BUFFER MODE
			addr_rdy		=> addr_rdy_mux_signal, -- MULTIPLE SOURCES DEPENDING ON BUFFER/DMA MODE
			mask_in		=> x"00", -- ENABLE ALL THE BYTES ALL THE TIME
			
			-- DDR2 Output Control Signals
			app_wdf_wren      => app_wdf_wren_signal,
			app_af_wren       => app_af_wren,
			app_af_cmd        => app_af_cmd,
			app_wdf_mask_data => app_wdf_mask_data,
			app_wdf_data      => app_wdf_data_signal,
			app_af_addr       => app_af_addr,
			rd_data_fifo_out  => rd_data_fifo_out,
			rd_data_valid		=> rd_data_valid,
			
			-- Data Signals
			read_fifo_data				=> read_fifo_data,
			read_fifo_data_empty		=> read_fifo_data_empty_signal,
			read_fifo_data_en			=> read_fifo_data_en,
			read_fifo_rdcount			=> read_fifo_rdcount,
			write_data_fifo_empty	=> write_data_fifo_empty,
			addr_fifo_empty			=> addr_fifo_empty_signal,
			rst_rd_fifo					=> rst_rd_fifo_signal,
			data_read_error			=> data_read_error_signal,
			data_write_error			=> data_write_error_signal,
			addr_write_error			=> addr_write_error_signal
		);
		app_wdf_wren <= app_wdf_wren_signal;
		app_wdf_data <= app_wdf_data_signal;
		
	-- FIFO OUTPUT SIGNAL REGISTERING
	REG0	:	REG_GENERIC
	 Generic map (WIDTH	=> 9)
    Port map( clk => clk,
           rst_n => rst_n,
           D => read_fifo_rdcount,
           Q => read_fifo_rdcount_reg);
			  
	REG1	:	REG_GENERIC
	 Generic map (WIDTH	=> 64)
    Port map( clk => clk,
           rst_n => rst_n,
           D => read_fifo_data,
           Q => read_fifo_data_reg);
			  
	DFF0	:	DFF
		 Port map( clk => clk,
				  rst_n => rst_n,
				  D => write_data_fifo_empty,
				  Q => write_data_fifo_empty_reg);
				  
	-- This logic enables a timer while the Camera Buffer/DMA finite-state machine
	-- is in buffer mode.  The 'frame_ready' signal is logical OR-ed with the
	-- 'frame_error' signal to prevent the FSM from hanging in the event of 
	-- a problem in the camera input data pipeline.
	-- Current wait time is 4.5 seconds (225,000,000 cycles @ 50-MHz)
	process(clk,rst_n,frame_error_count_en) is
	begin
		if (rst_n = '0') then
				frame_error_count <= (others => '0');
				frame_error_signal <= '0';
		elsif (clk'event and clk = '1') then

			if (frame_error_count_en = '1') then
				frame_error_count <= frame_error_count + 1;
			else
				frame_error_count <= (others => '0');
			end if;
			
			if (frame_error_count >= 225000000)then
				frame_error_signal <= '1';
			else
				frame_error_signal <= '0';
			end if;

		end if;
	end process;
				  
				  
	-- DDR2 INTERFACE LOGIC ANALYZER
			
	DDR2_DataManager_ILA0 : DDR2_DataManager_ILA
	  port map (
		 CONTROL => ILA_CONTROL,
		 CLK => clk,
		 TRIG0 => ddr2_fsm_ila_signal,
		 TRIG1 => ddr2_burst_controller_ila_signal,
		 TRIG2 => (others => '0'));
		 
		ddr2_fsm_ila_signal(7 downto 0) <= (others => '0');
		ddr2_fsm_ila_signal(15 downto 8) <= (others => '0');
		ddr2_fsm_ila_signal(18 downto 16) <= fsm_cmd;
		ddr2_fsm_ila_signal(19) <= addr_sel;
		ddr2_fsm_ila_signal(20) <= buffer_addr_rst_signal;
		ddr2_fsm_ila_signal(21) <= lb_readyn_signal;
		ddr2_fsm_ila_signal(53 downto 22) <= lb_ld_signal;
		ddr2_fsm_ila_signal(54) <= read_fifo_data_en;
		ddr2_fsm_ila_signal(55) <= fifo_fsm_rstn_signal;
		ddr2_fsm_ila_signal(59 downto 56) <= fsm_state_signal;
		ddr2_fsm_ila_signal(63 downto 60) <= (others => '0');
		ddr2_fsm_ila_signal(71 downto 64) <= control;
		ddr2_fsm_ila_signal(102 downto 72) <= std_logic_vector(buffer_addr_signal);
		ddr2_fsm_ila_signal(103) <= buffer_addr_rdy_signal;
		ddr2_fsm_ila_signal(112 downto 104) <= read_fifo_rdcount;
		ddr2_fsm_ila_signal(113) <= lb_btermn_signal;
		ddr2_fsm_ila_signal(114) <= frame_ready_signal;
		ddr2_fsm_ila_signal(145 downto 115) <= dma_addr_signal;
		ddr2_fsm_ila_signal(146) <= dma_addr_rdy_signal;
		ddr2_fsm_ila_signal(147) <= ddr2_readyn_sel_signal;
		ddr2_fsm_ila_signal(148) <= frame_error_signal;
		ddr2_fsm_ila_signal(149) <= lb_blastn;
		ddr2_fsm_ila_signal(150) <= error_flag_signal;
		ddr2_fsm_ila_signal(151) <= data_read_error_signal;
		ddr2_fsm_ila_signal(152) <= data_write_error_signal;
		ddr2_fsm_ila_signal(153) <= addr_write_error_signal;
		ddr2_fsm_ila_signal(154) <= lb_adsn;
		ddr2_fsm_ila_signal(155) <= lb_waitn_signal;
		ddr2_fsm_ila_signal(255 downto 156) <= (others => '0');
		
		ddr2_burst_controller_ila_signal(63 downto 0) <= pxl_data;
		ddr2_burst_controller_ila_signal(94 downto 64) <= addr_in_mux_signal;
		ddr2_burst_controller_ila_signal(97 downto 95) <= fsm_cmd;
		ddr2_burst_controller_ila_signal(98) <= pxl_data_ready;
		ddr2_burst_controller_ila_signal(99) <= addr_rdy_mux_signal;
		ddr2_burst_controller_ila_signal(107 downto 100) <= x"00";
		ddr2_burst_controller_ila_signal(171 downto 108) <= read_fifo_data_reg;
		ddr2_burst_controller_ila_signal(172) <= read_fifo_data_empty_signal;
		ddr2_burst_controller_ila_signal(173) <= read_fifo_data_en;
		ddr2_burst_controller_ila_signal(182 downto 174) <= read_fifo_rdcount_reg;
		ddr2_burst_controller_ila_signal(183) <= write_data_fifo_empty_reg;
		ddr2_burst_controller_ila_signal(184) <= addr_fifo_empty_signal;
		ddr2_burst_controller_ila_signal(255 downto 185) <= (others => '0');
		
end Behavioral;

