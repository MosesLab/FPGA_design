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
-- 2007-03-12	MF		Created
-- 2008-01-20	MF		Modified from PC/104 version, to be used with PLX local bus
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ctiUtil.all;

library unisim;
use unisim.vcomponents.all;

----------------------------------------------------------------------------------
entity plxSPI is
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
	spiSdo		: in std_logic;
	spiSdi		: out std_logic;
	spiCsn		: out std_logic
	--reprogram	: out std_logic
);
end plxSPI;

----------------------------------------------------------------------------------
architecture Behavioral of plxSPI is

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

	component ctiProg
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
	
	program_rom: ctiProg
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
					when "110" =>	in_port <= x"FF";  
					when "111" =>	in_port <= spiSdo & "0000000";  					
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
			spiSdi <= '0';
			spiSck <= '0';
			spiCsn <= '1';  --< active low chip select
		elsif rising_edge(clk) then
			if write_strobe='1' then
						
				-- Write to SPI data output
				if port_id(5)='1' then
					dpAddr <= out_port;
				end if;			
					
				-- Write to SPI data output
				if port_id(7)='1' then
					spiSdi <= out_port(7);
				end if;
				
				-- Write to SPI control
				if port_id(6)='1' then
					spiSck <= out_port(0);
					spiCsn <= out_port(1);
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

end Behavioral;

