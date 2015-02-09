--********************************************************************************
-- Copyright © 2008 Connect Tech Inc. All Rights Reserved. 
--********************************************************************************
-- Project:		ctiSpi
-- Module:		ctiSpi (rtl)
-- Parent:		N/A
-- Description: Picoblaze SPI Flash programmer
--
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2008-11-28	MF	 	Fast SPI program with fifos
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ctiUtil.all;

library unisim;
use unisim.vcomponents.all;

----------------------------------------------------------------------------------
entity plxSPIf2 is
----------------------------------------------------------------------------------
port
(       
	rst			: in std_logic;
	clk			: in std_logic;
	cmdReg		: in std_logic_vector(7 downto 0);
	paramReg	: in std_logic_matrix_08(3 downto 0);
	statusReg	: out std_logic_vector(7 downto 0);
	statusRegWr	: out std_logic;
	resultReg	: out std_logic_matrix_08(3 downto 0);
	resultRegWr	: out std_logic_vector(3 downto 0);
	dpDin		: out std_logic_vector(7 downto 0);
	dpDout		: in std_logic_vector(7 downto 0);
	dpAddr		: out std_logic_vector(7 downto 0);
	dpWr		: out std_logic;
	spiSck		: out std_logic;
	spiMiso		: in std_logic;
	spiMosi		: out std_logic;
	spiSS		: out std_logic
	--reprogram	: out std_logic
);
end plxSPIf2;

----------------------------------------------------------------------------------
architecture Behavioral of plxSPIf2 is

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	component kcpsm3 
	Port (      
		address : out std_logic_vector(9 downto 0);
		instruction : in std_logic_vector(17 downto 0);
		port_id : out std_logic_vector(7 downto 0);
		write_strobe : out std_logic;
		out_port : out std_logic_vector(7 downto 0);
		read_strobe : out std_logic;
		in_port : in std_logic_vector(7 downto 0);
		interrupt : in std_logic;
		interrupt_ack : out std_logic;
		reset : in std_logic;
		clk : in std_logic);
	end component;

	component pbProgf2
	Port (      
		address : in std_logic_vector(9 downto 0);
		instruction : out std_logic_vector(17 downto 0);
		clk : in std_logic);
	end component;

    component bbfifo_16x8 is
    Port (       
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0);
		reset : in std_logic;               
		write : in std_logic; 
		read : in std_logic;
		full : out std_logic;
		half_full : out std_logic;
		data_present : out std_logic;
		 clk : in std_logic);
    end component;
    
	component ctiFifo is 
	generic ( 	width : natural := 8;
				fifoSize : natural := 16);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           wren : in  STD_LOGIC;
		   rden : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (width-1 downto 0);
           dout : out  STD_LOGIC_VECTOR (width-1 downto 0);
		   empty : out std_logic;
		   halfFull : out std_logic;		   
		   full : out std_logic );
	end component;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- signal Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	-- Signals used to connect KCPSM3 to program ROM and I/O logic
	signal  address         : std_logic_vector(9 downto 0);
	signal  instruction     : std_logic_vector(17 downto 0);
	signal  port_id         : std_logic_vector(7 downto 0);
	signal  out_port        : std_logic_vector(7 downto 0);
	signal  in_port         : std_logic_vector(7 downto 0);
	--signal  in_portq         : std_logic_vector(7 downto 0);
	signal  write_strobe    : std_logic;
	signal  read_strobe     : std_logic;
	signal  interrupt       : std_logic;
	signal  interrupt_ack   : std_logic;

	signal  spiCtrl     	: std_logic_vector(7 downto 0);
	signal  spiStatus       : std_logic_vector(7 downto 0);
	signal  spiDo	        : std_logic_vector(7 downto 0);
	signal  spiDi   	    : std_logic_vector(7 downto 0);
	--signal transmitDataWr 	: std_logic;

	signal txFifoIn			: std_logic_vector(7 downto 0);
	signal txFifoOut		: std_logic_vector(7 downto 0);
	signal txFifoWr			: std_logic;
	signal txFifoRd			: std_logic;
	signal txFifoFull		: std_logic;
	signal txFifoHalfFull	: std_logic;
	signal txFifoPresent	: std_logic;
	
	signal rxFifoIn			: std_logic_vector(7 downto 0);
	signal rxFifoOut		: std_logic_vector(7 downto 0);
	signal rxFifoWr			: std_logic;
	signal rxFifoRd			: std_logic;
	signal rxFifoFull		: std_logic;
	signal rxFifoHalfFull	: std_logic;
	signal rxFifoPresent	: std_logic;	
	
	signal SPIXfer_done : std_logic;
	signal SR_5_Tx_Empty : std_logic;
begin


	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- KCPSM3 and the program memory 
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	interrupt <= '0';
	
	processor: kcpsm3
	port map(      
		address			=> address,
		instruction		=> instruction,
		port_id			=> port_id,
		write_strobe	=> write_strobe,
		out_port		=> out_port,
		read_strobe		=> read_strobe,
		in_port			=> in_port,
		interrupt		=> interrupt,
		interrupt_ack 	=> interrupt_ack,
		reset			=> rst,
		clk				=> clk
	);
	
	program_rom: pbProgf2
	port map(      
		address		=> address,
		instruction	=> instruction,
		clk			=> clk
	);

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- KCPSM3 input ports 
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- The inputs connect via a pipelined multiplexer
	input_ports: process(clk)
	begin
		if rising_edge(clk) then

			--if port_id(2) = '0' then
				case port_id(2 downto 0) is
					when "000" =>	in_port <= cmdReg;
					when "001" =>	in_port <= paramReg(0);
					when "010" =>	in_port <= paramReg(1);
					when "011" =>	in_port <= paramReg(2);	
					when "100" => 	in_port <= paramReg(3);		
					when "101" =>	in_port <= dpDout;  
					when "110" =>	in_port <= spiStatus;  
					when "111" =>	in_port <= rxFifoOut;  					
					when others =>	in_port <= (others => '0');  
				end case;	
		end if;
	end process input_ports;

    -- For memory FIFO  (was registered inside process above )
	-- Note: if fifos are implemented as memory (ie. from coregen)
	-- then data is only available AFTER read strobe.
	-- therefore, the FIFO output can't be registered through the mux.

	--inFifoRd <= read_strobe and not port_id(1) and port_id(0);
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- KCPSM3 output ports (these are output registers)
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	output_ports: process(clk,rst)
	begin
		if rst = '1' then
			dpAddr <= (others => '0');
			--spiDo <= (others => '0');
			spiCtrl(0) <= '0';
			spiCtrl(1) <= '0';
			spiCtrl(2) <= '1';
			spiCtrl(7 downto 3) <= (others => '0');
		elsif rising_edge(clk) then
			if write_strobe='1' then
						
				-- Write to SPI data output
				if port_id(5)='1' then
					dpAddr <= out_port;
				end if;			
					
				-- Write to SPI data output
				--if port_id(7)='1' then
				--	spiDo <= out_port;
				--end if;
				
				-- Write to SPI control
				if port_id(6)='1' then
					spiCtrl <= out_port;
				end if;
							
			end if;
		end if; 
	
	end process output_ports;


	statusRegWr <= '1' when (write_strobe='1' and port_id(0)='1') else '0';
	resultRegWr(0) <= '1' when (write_strobe='1' and port_id(1)='1') else '0';
	resultRegWr(1) <= '1' when (write_strobe='1' and port_id(2)='1') else '0';
	resultRegWr(2) <= '1' when (write_strobe='1' and port_id(3)='1') else '0';
	resultRegWr(3) <= '0';
	
	dpDin <= out_port;
	dpWr <= '1' when (write_strobe='1' and port_id(4)='1') else '0';
	
    
	statusReg <= out_port;
	resultReg(0) <= out_port;
	resultReg(1) <= out_port;
	resultReg(2) <= out_port;
	resultReg(3) <= (others => '0');

	
	-- transmit fifo
    u_txfifo : bbfifo_16x8 
    Port map (       
		data_in		=> txFifoIn,
		data_out	=> txFifoOut,
		reset		=> rst,
		write		=> txFifoWr, 
		read		=> txfifoRd,
		full		=> txfifoFull,
		half_full	=> txFifoHalfFull,
		data_present => txFifoPresent,
		clk			=> clk
	);	
	
	-- receive fifo
    u_rxfifo : bbfifo_16x8 
    Port map (       
		data_in		=> rxFifoIn,
		data_out	=> rxFifoOut,
		reset		=> rst,
		write		=> rxFifoWr, 
		read		=> rxfifoRd,
		full		=> rxfifoFull,
		half_full	=> rxFifoHalfFull,
		data_present => rxFifoPresent,
		clk			=> clk
	);		

	txFifoWr 	<= write_strobe and port_id(7);
	txfifoRd 	<= SPIXfer_done;
	txFifoIn  	<= out_port;
	spiDo 		<= txfifoOut;
	
	rxFifoWr 	<= SPIXfer_done and not spiCtrl(3);
	rxFifoRd 	<= read_strobe and port_id(0) and port_id(1) and port_id(2);	
	rxFifoIn 	<= spiDi;
	
	SR_5_Tx_Empty <=  not txFifoPresent;
	
	spiStatus(1) <= not txFifoPresent;
	spiStatus(2) <= txFifoFull;
	spiStatus(3) <= txFifoHalfFull;
	
	spiStatus(4) <= not rxFifoPresent;
	spiStatus(5) <= rxFifoFull;
	spiStatus(6) <= rxFifoHalfFull;
	
	u_spi_ctrl : entity work.spi_module_cti 
	PORT MAP(
		Bus2IP_Clk => clk,
		Reset => rst,
		SR_3_MODF => spiStatus(0),
		SR_5_Tx_Empty => SR_5_Tx_Empty,
		modf_Reset => spiCtrl(0),
		SPI_En => spiCtrl(1),
		Slave_Select_Reg(0) => spiCtrl(2),
		Transmit_Data => spiDo,
		--Bus2IP_Transmit_Reg_WrCE => txFifoWr,
		Receive_Data => spiDi,
		SPIXfer_done => SPIXfer_done,
		DTR_underrun => open,
		SCK_I => '0',
		SCK_O => spiSck,
		SCK_T => open,
		MISO_I => spiMiso,
		MISO_O => open,
		MISO_T => open,
		MOSI_I => '0',
		MOSI_O => spiMosi,
		MOSI_T => open,	
		SS_I(0) => '0',
		SS_O(0) => spiSS,
		SS_T => open
	);	


--	SR_5_TX_EMPTY_REG_PROCESS:process(clk)
--	begin
--		if (clk'event and clk='1') then
--			if (Reset = '1') then
--				sr_5_Tx_Empty_i <= '1';
--			elsif ( Bus2IP_Transmit_Reg_WrCE = '1') then
--				sr_5_Tx_Empty_i <= '0';
--			elsif (SPIXfer_done = '1') then
--				sr_5_Tx_Empty_i <= '1';
--			end if;
--		end if;
--	end process SR_5_TX_EMPTY_REG_PROCESS;
--
--	sr_5_Tx_Empty <= sr_5_Tx_Empty_i;

end Behavioral;

