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

entity DDR2_DataGen_FSM is
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
end DDR2_DataGen_FSM;

architecture Behavioral of DDR2_DataGen_FSM is

	type	STATE	is (INITIALIZING, WRITE_DATA0, WRITE_DATA1, WRITE_DATA2, WRITE_DATA3, READ_DATA0, READ_DATA1, STOP);
	signal CurrentState	:STATE := INITIALIZING;
	signal NextState		:STATE := INITIALIZING;

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
	process(clk,sys_rst_n,CurrentState,phy_init_done,start_flag) is
	begin
		NextState <= CurrentState;
		case (CurrentState) is
			when INITIALIZING =>
				if (phy_init_done = '1' and start_flag = '1') then
					NextState <= WRITE_DATA0;
				end if;
			when WRITE_DATA0 =>
				NextState <= WRITE_DATA1;
			when WRITE_DATA1 =>
				NextState <= READ_DATA0;
			when WRITE_DATA2 =>
				NextState <= WRITE_DATA3;
			when WRITE_DATA3 =>
				NextState <= READ_DATA1;
			when READ_DATA0 =>
				NextState <= WRITE_DATA2;
			when READ_DATA1	=>
				NextState <= STOP;
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
				data_rdy <= '0';
				addr_rdy <= '0';
				addr <= (others => '1');
				data     <= (others => '0');
				cmd <= "000";
				mask <= x"F0";
			when WRITE_DATA0 =>
				fsm_state <= "0001";
				data_rdy <= '1';
				addr_rdy <= '0';
				addr <= b"0000000000000000000000000000000";
				data     <= x"00000000FAFAFAFA";
				cmd <= "000";
				mask <= x"00";
			when WRITE_DATA1 =>
				fsm_state <= "0011";
				data_rdy <= '1';
				addr_rdy <= '1';
				addr <= b"0000000000000000000000000000000";--(others => '0');
				data     <= x"11111111EBEBEBEB";
				cmd <= "000";
				mask <= x"00";
			when WRITE_DATA2 =>
				fsm_state <= "0101";
				data_rdy <= '1';
				addr_rdy <= '0';
				addr <= b"0000000000000000000000000000100";--(others => '0');
				data  <= x"22222222CDCDCDCD";
				cmd <= "000";
				mask <= x"00";
			when WRITE_DATA3 =>
				fsm_state <= "0111";
				data_rdy <= '1';
				addr_rdy <= '1';
				addr <= b"0000000000000000000000000000100";--(others => '0');
				data     <= x"33333333BEEFBEEF";
				cmd <= "000";
				mask <= x"00";
			when READ_DATA0	=>
				fsm_state <= "1011";
				data_rdy <= '0';
				addr_rdy <= '1';
				addr <= "0000000000000000000000000000000";
				data     <= (others => '0');
				cmd <= "001";
				mask <= x"00";
			when READ_DATA1	=>
				fsm_state <= "1011";
				data_rdy <= '0';
				addr_rdy <= '1';
				addr <= "0000000000000000000000000000100";
				data     <= (others => '0');
				cmd <= "001";
				mask <= x"00";
			when STOP =>
				fsm_state <= "1011";
				data_rdy <= '0';
				addr_rdy <= '0';
				addr <= (others => '0');
				data     <= (others => '0');
				cmd <= "000";
				mask <= x"00";
		end case;
	end process;

end Behavioral;

