----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:06:43 10/01/2014 
-- Design Name: 
-- Module Name:    DDR2_Interface_FSM - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity DDR2_Interface_FSM is
	port(
		-- Clock and Reset Signals
		clk					:in	std_logic;
		sys_rst_n         :in	std_logic;		
		
		-- Input Control Signals
		phy_init_done     :in	std_logic;
		app_wdf_afull     :in	std_logic;
		app_af_afull      :in	std_logic;
		rd_data_valid     :in	std_logic;
		start_flag			:in	std_logic;
		
		-- Output Control Signals
		app_wdf_wren      :out	std_logic;
		app_af_wren       :out	std_logic;
		app_af_cmd        :out	std_logic_vector(2  downto 0); 
		app_wdf_mask_data :out	std_logic_vector(7  downto 0);
		
		-- Data Signals
		rd_data_fifo_out  :in	std_logic_vector(63 downto 0);
		app_wdf_data      :out	std_logic_vector(63 downto 0);		
		
		
		-- Address Signals
		app_af_addr       :out	std_logic_vector(30 downto 0);
		
		-- Status Signals
		fsm_state					:out	std_logic_vector(3 downto 0)
		
	);
end DDR2_Interface_FSM;

architecture Behavioral of DDR2_Interface_FSM is

	type	STATE	is (INITIALIZING, WRITE_DATA0, READ_DATA0, WRITE_DATA1, READ_DATA1, WRITE_DATA2, WRITE_DATA3, WRITE_DATA4, READ_DATA2, READ_DATA3, READ_DATA4,
						 PAUSE0, PAUSE1, PAUSE2, PAUSE3, PAUSE4, PAUSE5, PAUSE6, PAUSE7, PAUSE8, PAUSE9, STOP);
	signal CurrentState	:STATE := INITIALIZING;
	signal NextState		:STATE := INITIALIZING;
	
	signal app_af_wren_signal	:std_logic;

begin

	-- STATE MEMORY
	process(clk) is
	begin
		if (clk'event and clk = '1') then
			if (sys_rst_n = '0') then
				CurrentState <= INITIALIZING;
			else
				CurrentState <= NextState;
			end if;
		end if;
	end process;
	
	-- NEXT-STATE LOGIC
	process(clk,sys_rst_n,CurrentState,phy_init_done,rd_data_valid,app_af_wren_signal,start_flag) is
	begin
		NextState <= CurrentState;
		case (CurrentState) is
			when INITIALIZING =>
				if (phy_init_done = '1' and start_flag = '1') then
					NextState <= WRITE_DATA0;
				end if;
			when WRITE_DATA0 =>
					NextState <= PAUSE0;
			when PAUSE0 =>	
				NextState <= WRITE_DATA1;
			when WRITE_DATA1 =>
					NextState <= PAUSE1;
			when PAUSE1 =>	
				NextState <= WRITE_DATA2;
			when WRITE_DATA2 =>
					NextState <= PAUSE2;
			when PAUSE2 =>	
				NextState <= WRITE_DATA3;
			when WRITE_DATA3 =>
					NextState <= PAUSE3;
			when PAUSE3 =>	
				NextState <= WRITE_DATA4;
			when WRITE_DATA4 =>				
					NextState <= PAUSE4;
			when PAUSE4 =>	
				NextState <= READ_DATA0;
			when READ_DATA0 =>
					NextState <= PAUSE5;
			when PAUSE5 =>	
				if (rd_data_valid = '1') then
					NextState <= READ_DATA1;
				end if;
			when READ_DATA1 =>
				NextState <= PAUSE6;
			when PAUSE6 =>	
				if (rd_data_valid = '1') then
					NextState <= READ_DATA2;
				end if;
			when READ_DATA2 =>
				NextState <= PAUSE7;
			when PAUSE7 =>	
				if (rd_data_valid = '1') then
					NextState <= READ_DATA3;
				end if;
			when READ_DATA3 =>
				NextState <= PAUSE8;
			when PAUSE8 =>	
				if (rd_data_valid = '1') then
					NextState <= READ_DATA4;
				end if;
			when READ_DATA4 =>
				NextState <= PAUSE9;
			when PAUSE9 =>	
				if (rd_data_valid = '1') then
					NextState <= STOP;
				end if;
			when STOP =>
				NextState <= STOP;			
		end case;
	end process;
	
	-- OUTPUT LOGIC
	process(CurrentState) is
	begin
		case (CurrentState) is
			when INITIALIZING =>
				fsm_state <= "0000";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '0';
				app_af_addr <= (others => '1');
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
			when WRITE_DATA0 =>
				fsm_state <= "0001";
				app_wdf_wren <= '1';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000000";
				app_wdf_data     <= x"00000000FAFAFAFA";
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
			when READ_DATA0	=>
				fsm_state <= "0010";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000000";
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "001";
				app_wdf_mask_data <= x"F0";
			when WRITE_DATA1 =>
				fsm_state <= "0011";
				app_wdf_wren <= '1';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000001";--(others => '0');
				app_wdf_data     <= x"11111111EBEBEBEB";
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
			when READ_DATA1	=>
				fsm_state <= "0100";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000001";
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "001";
				app_wdf_mask_data <= x"F0";
			when WRITE_DATA2 =>
				fsm_state <= "0101";
				app_wdf_wren <= '1';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000010";--(others => '0');
				app_wdf_data     <= x"22222222CDCDCDCD";
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
			when READ_DATA2	=>
				fsm_state <= "0110";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000010";
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "001";
				app_wdf_mask_data <= x"F0";
			when WRITE_DATA3 =>
				fsm_state <= "0111";
				app_wdf_wren <= '1';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000011";--(others => '0');
				app_wdf_data     <= x"33333333BEEFBEEF";
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
			when READ_DATA3 =>
				fsm_state <= "1000";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000011";
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "001";
				app_wdf_mask_data <= x"F0";
			when WRITE_DATA4 =>
				fsm_state <= "1001";
				app_wdf_wren <= '1';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000100";--(others => '0');
				app_wdf_data     <= x"44444444FEEDFEED";
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
			when READ_DATA4 =>
				fsm_state <= "1010";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '1';
				app_af_addr <= b"0000000000000000000000000000100";
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "001";
				app_wdf_mask_data <= x"F0";
			when STOP =>
				fsm_state <= "1011";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '0';
				app_af_addr <= (others => '0');
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
			when others =>
				fsm_state <= "1111";
				app_wdf_wren <= '0';
				app_af_wren_signal <= '0';
				app_af_addr <= (others => '0');
				app_wdf_data     <= (others => '0');
				app_af_cmd <= "000";
				app_wdf_mask_data <= x"F0";
		end case;
	end process;
	
	app_af_wren <= app_af_wren_signal;


end Behavioral;

