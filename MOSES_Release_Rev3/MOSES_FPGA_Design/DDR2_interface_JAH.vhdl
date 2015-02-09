----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:18:12 09/04/2014 
-- Design Name: 
-- Module Name:    DDR2_interface_JAH - Behavioral 
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

entity DDR2_interface_JAH is
	port(
		clk				:in	std_logic;	-- System input clock
		rst_n				:in	std_logic;	-- Active-low global reset
		
		-- DDR2 INTERFACE FSM SIGNALS
		state				:out	std_logic_vector(3 downto 0);	-- DDR2 Interface State output signal (used for debugging)
		dma_done_flag	:in	std_logic;	-- Input signaling the DDR2 interface that the DMA phase is complete
		frame_ready		:out	std_logic;	-- Input signaling a whole frame has been buffered from the camera interface
		missed_frame	:out	std_logic;	-- Output signaling activity detected on camera interface while still DMA-ing a previous frame
		
		--INPUT SIGNALS FROM THE CAMERA INTERFACE
		pxl_data_ready	:in	std_logic;	-- Signal from the camera interface indicating valid data is available to be read
		pxl_data			:in	std_logic_vector(63 downto 0);	-- Pixel data from camera interface
		pxl_mask			:in	std_logic_vector(7 downto 0);	-- Pixel data byte mask
		
		--INPUT SIGNALS FROM THE PLX INTERFACE
		lb_adsn			:in	std_logic;
		lb_la				:in	std_logic_vector(29 downto 0);
		lb_readyn		:out	std_logic;
		lb_ld				:out	std_logic_vector(31 downto 0);

		--INPUT SIGNALS FROM THE DDR2 MIG INTERFACE
		clk_tb			:in	std_logic;
		rst_tb			:in	std_logic;	
		phy_init_done	:in	std_logic;

		--OUTPUT SIGNALS TO DDR2 MIG INTERFACE
		ddr2_af_wren	:out	std_logic; 	-- DDR2 Address FIFO Write-enable
		ddr2_wdf_wren	:out	std_logic;	-- DDR2 Write-data FIFO Write-enable
		ddr2_cmd			:out	std_logic_vector(2 downto 0);	-- DDR2 Command bits
		ddr2_addr		:out	std_logic_vector(30 downto 0);	-- DDR2 Address
		ddr2_wrdata		:out	std_logic_vector(63 downto 0);	-- DDR2 Write Data
		ddr2_wrmask		:out	std_logic_vector(7 downto 0);		--	DDR2 Write Data Mask
		ddr2_rddata		:in	std_logic_vector(63 downto 0);
		ddr2_rdrdy		:in	std_logic
	);		
end DDR2_interface_JAH;

architecture Behavioral of DDR2_interface_JAH is

	component SYNC
		 Port ( clk : in  STD_LOGIC;
				  rst_n : in  STD_LOGIC;
				  data_in : in  STD_LOGIC;
				  data_out : out  STD_LOGIC);
	end component;
	
	component SYNC_GENERIC
		 Generic (WIDTH	:integer := 8);
		 Port ( clk : in  STD_LOGIC;
				  rst_n : in  STD_LOGIC;
				  data_in : in  STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
				  data_out : out  STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0));
	end component;
	
	component DFF
		 Port ( clk : in  STD_LOGIC;
				  rst_n : in  STD_LOGIC;
				  D : in  STD_LOGIC;
				  Q : out  STD_LOGIC);
	end component;
	
	signal pxl_ready_sync	:std_logic;
	signal pxl_data_sync		:std_logic_vector(63 downto 0);
	signal pxl_addr_sync		:std_logic_vector(30 downto 0);
	signal pxl_addr			:std_logic_vector(30 downto 0);
	signal addr_rstn			:std_logic;
	signal write_addr_signal	:unsigned(30 downto 0) := (others => '0');
	signal pxl_mask_sync		:std_logic_vector(7 downto 0);
	signal frame_ready_flag :std_logic;
	
	signal lb_la_sync			:std_logic_vector(29 downto 0);
	signal read_address		:std_logic_vector(30 downto 0);
	signal lb_ads				:std_logic;
	signal lb_ads_prev		:std_logic;
	signal lb_ads_re			:std_logic;
	signal lb_ads_re_sync	:std_logic;
	signal ddr2_rddata_sync	:std_logic_vector(63 downto 0);
	
	signal ddr2_rdrdy_sync	:std_logic;
	
	signal ddr2_wraddr_temp	:std_logic_vector(30 downto 0);
	signal ddr2_wraddr_sync	:std_logic_vector(30 downto 0);
	
	signal ddr2_wrmask_temp	:std_logic_vector(7 downto 0);
	signal ddr2_wrmask_sync	:std_logic_vector(7 downto 0);
	
	signal ddr2_rdaddr_temp	:std_logic_vector(29 downto 0);
	signal ddr2_rdaddr_sync	:std_logic_vector(29 downto 0);
	
	signal ddr2_fsm_wren	:std_logic;
	signal ddr2_fsm_cmd	:std_logic_vector(2 downto 0);
	
	signal ddr2_write_interface_en :std_logic;
	signal ddr2_read_interface_en  :std_logic;
	
	signal lb_adsn_temp	:std_logic;
	signal lb_adsn_sync	:std_logic;
	
	signal ddr2_mux_select	:std_logic;
	signal ddr2_wdf_wren_wrmode_signal	:std_logic;
	
	signal ddr2_read_address	:std_logic_vector(30 downto 0);
	signal ddr2_af_wren_signal	:std_logic;
	
	type FSM_STATES is (INIT,BUFFER_0,DMA_0,FRAME_ERROR);
	signal NextState	:FSM_STATES;
	signal CurrentState :FSM_STATES;
	
	signal rst_tb_n	:std_logic;

begin
	
	rst_tb_n <= not rst_tb;

	--SYNCHRONIZE THE INPUTS FROM THE CAMERA INTERFACE (EXPLICITLY USING D-FLIP FLOPS)
	-- PXL_READY SYNCHRONIZATION
	SYNC0	:	SYNC
		 port map(
			clk 		=> clk_tb,
			rst_n 	=> rst_tb_n,
			data_in 	=> pxl_data_ready,
			data_out => pxl_ready_sync
		);
	ddr2_wdf_wren_wrmode_signal <= 	pxl_ready_sync and ddr2_write_interface_en;
	ddr2_wdf_wren	<= ddr2_wdf_wren_wrmode_signal;
		
	-- PXL_DATA SYNCHRONIZATION
	SYNC1	:	SYNC_GENERIC
		 generic map (WIDTH => 64)
		 port map(
			clk 		=> clk_tb,
			rst_n 	=> rst_tb_n,
			data_in 	=> pxl_data,
			data_out => pxl_data_sync
		);
	ddr2_wrdata		<= pxl_data_sync;
	
	-- PXL_ADDR SYNCHRONIZATION
	SYNC2	:	SYNC_GENERIC
		 generic map (WIDTH => 31)
		 port map(
			clk 		=> clk_tb,
			rst_n 	=> rst_tb_n,
			data_in 	=> pxl_addr,
			data_out => pxl_addr_sync
		);
	
	-- PXL_WR_MASK SYNCHRONIZATION
	SYNC3	:	SYNC_GENERIC
		 generic map (WIDTH => 8)
		 port map(
			clk 		=> clk_tb,
			rst_n 	=> rst_tb_n,
			data_in 	=> pxl_mask,
			data_out => pxl_mask_sync
		);	
	ddr2_wrmask		<= pxl_mask_sync;
	
	-- LOCAL BUS ADDRESS SYNCHRONIZATION
	SYNC4	:	SYNC_GENERIC
		 generic map (WIDTH => 30)
		 port map(
			clk 		=> clk_tb,
			rst_n 	=> rst_tb_n,
			data_in 	=> lb_la,
			data_out => lb_la_sync
		);
		read_address <= "00" & lb_la_sync(28 downto 0);
	-- LOCAL BUS ADDRESS VALID RISING EDGE GENERATION
	lb_ads <= not lb_adsn;
	
	DFF0	:	DFF
		port map(
			clk 	=> clk_tb, -- Check that there's not a timing hazard here...that is, make sure that clk_tb is fast compared to clk
			rst_n => rst_tb_n,
			D 		=> lb_ads,
			Q 		=> lb_ads_prev
		);
		lb_ads_re <= (not lb_ads_prev) and lb_ads;
	
	SYNC5	:	SYNC
		 port map(
			clk 		=> clk_tb,
			rst_n 	=> rst_tb_n,
			data_in 	=> lb_ads_re,
			data_out => lb_ads_re_sync
		);
		ddr2_af_wren_signal <= lb_ads_re_sync and ddr2_read_interface_en;
		
	SYNC6	:	SYNC
		 port map(
			clk 		=> clk,
			rst_n 	=> rst_n,
			data_in 	=> ddr2_rdrdy,
			data_out => ddr2_rdrdy_sync
		);
		
		lb_readyn <= (not ddr2_rdrdy_sync) and ddr2_read_interface_en;
		
	SYNC7	:	SYNC_GENERIC
		 generic map (WIDTH => 64)
		 port map(
			clk 		=> clk,
			rst_n 	=> rst_n,
			data_in 	=> ddr2_rddata,
			data_out => ddr2_rddata_sync
		);	
	lb_ld <= ddr2_rddata_sync(31 downto 0);
		
	

	-- DDR2 INTERFACE SIGNAL ASSIGNMENTS
	
	--FINITE STATE MACHINE
	process(clk_tb,rst_tb) is
	begin
		if (rst_tb = '1') then
			CurrentState <= INIT;
		elsif(clk_tb'event and clk_tb = '1') then
			CurrentState <= NextState;
		end if;
	end process;
	
	process(phy_init_done,frame_ready_flag,pxl_ready_sync,dma_done_flag) is
	begin
		if (rst_tb = '1') then
			NextState <= INIT;
		elsif(clk_tb'event and clk_tb = '1') then
			case (CurrentState) is
				when INIT =>
					if (phy_init_done = '1') then
						NextState <= BUFFER_0;
					else
						NextState <= INIT;
					end if;
				when BUFFER_0 =>
					if (frame_ready_flag = '1') then
						NextState <= DMA_0;
					else
						NextState <= BUFFER_0;
					end if;
				when DMA_0 =>
					if (pxl_ready_sync = '1') then
						NextState <= FRAME_ERROR;
					elsif (dma_done_flag = '1') then
						NextState <= BUFFER_0;
					else
						NextState <= DMA_0;
					end if;
				when FRAME_ERROR =>
					if (dma_done_flag = '1') then
						NextState <= BUFFER_0;
					else
						NextState <= FRAME_ERROR;
					end if;
			end case;
		end if;
	end process;
	
	process(CurrentState) is
	begin
		case (CurrentState) is
			when INIT =>
				ddr2_write_interface_en <= '0';
				ddr2_read_interface_en <= '0';
				ddr2_cmd <= "000";
				missed_frame <= '0';
				state <= "0000";
				ddr2_mux_select <= '0';
				addr_rstn <= '0';
			when BUFFER_0 =>
				ddr2_write_interface_en <= '1';
				ddr2_read_interface_en <= '0';
				ddr2_cmd <= "000";
				missed_frame <= '0';
				state <= "0001";
				ddr2_mux_select <= '0';
				addr_rstn <= '1';
			when DMA_0 =>
				ddr2_write_interface_en <= '0';
				ddr2_read_interface_en <= '1';
				ddr2_cmd <= "001";
				missed_frame <= '0';
				state <= "0010";
				ddr2_mux_select <= '1';
				addr_rstn <= '0';
			when FRAME_ERROR =>
				ddr2_write_interface_en <= '0';
				ddr2_read_interface_en <= '1';
				ddr2_cmd <= "001";
				missed_frame <= '1';
				state <= "0011";
				ddr2_mux_select <= '1';
				addr_rstn <= '0';
		end case;
	end process;
	
	--DDR2 ADDRESS FIFO ADDRESS MUX
	process(ddr2_mux_select) is
	begin
		case (ddr2_mux_select) is
			when '0' => -- BUFFER MODE...pxl_addr_sync is generated by a local process 
				ddr2_addr <= pxl_addr_sync;
			when others =>
				ddr2_addr <= read_address;
		end case;
	end process;

	--DDR2 ADDRESS FIFO ADDRESS WREN MUX
	-- When the interface is in write mode, the address fifo wren signal is the same as the write-data fifo wren
	-- When the interface is in read mode, the address fifo wren signal is driven by the PLX adsn interface signal
	process(ddr2_mux_select) is
	begin
		case (ddr2_mux_select) is
			when '0' => -- BUFFER MODE...DATA IS BEING WRITTEN TO THE DDR2
				ddr2_af_wren <= ddr2_wdf_wren_wrmode_signal;	-- ddr2_af_wren is the same as ddr2_wdf_wren in write mode so data and addr is latched simultaneously
			when others => -- DMA MODE...DATA IS BEING READ FROM THE DDR2
				ddr2_af_wren <= ddr2_af_wren_signal; -- in read mode the ddr2_af_wren signal is driven by distinct logic
		end case;
	end process;
	
	--DDR2 BUFFER-MODE ADDRESS GENERATION
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
			write_addr_signal <= (others =>'0');
		elsif (clk'event and clk = '1') then
			if (addr_rstn = '0') then
				write_addr_signal <= (others => '0');
			elsif (ddr2_wdf_wren_wrmode_signal = '1') then
				write_addr_signal <= write_addr_signal + 1;
			end if;
		end if;
	end process;
	pxl_addr <= std_logic_vector(write_addr_signal);
	
	-- This logic detects when the last word of frame data has been written
	-- to the DDR2 interface and asserts a flag indicating this to the 
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
		elsif (clk'event and clk = '1') then
			if (write_addr_signal = 1048576) then
				frame_ready_flag <= '1';
			else
				frame_ready_flag <= '0';
			end if;
		end if;
	end process;
	frame_ready <= frame_ready_flag;
	
end Behavioral;

