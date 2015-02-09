----------------------------------------------------------------------------------
-- Company: Montana State University
-- Engineer: Justin A. Hogan
-- 
-- Create Date:    18:57:53 08/11/2014 
-- Design Name:  MOSES
-- Module Name:    camera_interface - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This logic implements an interface to the camera ROE
-- used in the MOSES sounding rocket payload.  It synchronizes the incoming
-- clock and data signals to the system clock, detects a rising edge on the 
-- incoming pixel clock, buffers two pixel values for writing to a 32-bit
-- DDR2 memory interface, and signals when data is ready on the output.  The 
-- output is a registered 32-bit data bus and a byte-ready flag that is asserted
-- high for a single clock cycle when new, valid data is available on the bus.
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

entity camera_interface is
    Port ( 	clk 				: in  std_logic;
				rst_n 			: in  std_logic;
				
				-- camera interface signals
				pxl_data_in 		: in  std_logic_vector(15 downto 0);
				pxl_clk_in 			: in  std_logic;
				pxl_addr_rst		: in	std_logic;				
				pxl_data_out		:	out	std_logic_vector(31 downto 0);
				pxl_data_ready		:	out	std_logic;
				pxl_addr_out		:	out	std_logic_vector(30 downto 0)
				
				);
end camera_interface;

architecture Structural of camera_interface is
	
	-- STAGE 0 COMPONENTS AND SIGNALS
	component SYNC
		Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  data_in : in  STD_LOGIC;
			  data_out : out  STD_LOGIC);
	end component;
	
	
	component SYNC16
	 Port ( clk : in  std_logic;
			  rst_n : in  std_logic;
			  data_in : in  std_logic_vector(15 downto 0);
			  data_out : out  std_logic_vector(15 downto 0));
	end component;
	
	signal	pxl_clk_sync0		:std_logic;
	signal	pxl_data_sync0		:std_logic_vector(15 downto 0);
	
	-- STAGE 1 COMPONENTS AND SIGNALS
	component DFF
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC;
			  Q : out  STD_LOGIC);
	end component;
	
	component REG16
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC_VECTOR (15 downto 0);
			  Q : out  STD_LOGIC_VECTOR (15 downto 0));
	end component;
	
	signal	pxl_clk_sync1		:std_logic;
	signal	pxl_data_sync1		:std_logic_vector(15 downto 0);
	
	-- STAGE 2 COMPONENTS AND SIGNALS
	signal	pxl_clk_sync_RE	:std_logic; -- Intermediate combinational logic output that is asserted on rising edge of pixel clock
	signal	pxl_clk_sync_RE2	:std_logic; -- Registered pixel clock rising edge detection signal
	signal	pxl_data_sync2		:std_logic_vector(15 downto 0); -- Registered stage 2 pixel data signal
	
	-- STAGE 3 COMPONENTS AND SIGNALS
	component SHIFT_REG32
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC_VECTOR (15 downto 0);
			  Q : out  STD_LOGIC_VECTOR (31 downto 0);
			  en : in  STD_LOGIC);
	end component;
	
	component COUNTER
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  en : in  STD_LOGIC;
			  flag : out  STD_LOGIC);
	end component;
	
	signal pxl_data_ready_flag	:std_logic;
	signal pxl_data32	:std_logic_vector(31 downto 0);
	
	-- STAGE 4 COMPONENTS AND SIGNALS	
	component DFF_EN
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC;
			  Q : out  STD_LOGIC;
			  en : in	std_logic);
	end component;

	component REG32
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC_VECTOR (31 downto 0);
			  Q : out  STD_LOGIC_VECTOR (31 downto 0);
			  en : in  STD_LOGIC);
	end component;
	
	component ADDRESS_GENERATOR
	 Port ( clk 		: 	in  	std_logic;
			  rst_n 		:	in  	std_logic;
			  addr_rst 	:	in  	std_logic;
			  addr_inc	:	in		std_logic;
			  addr 		: 	out  	std_logic_vector (30 downto 0));
	end component;
	
	signal pxl_addr_out_signal	:	std_logic_vector(31 downto 0);
	signal pxl_addr_gen_signal :	std_logic_vector(30 downto 0) := (others => '0');
	signal pxl_addr_signal :	std_logic_vector(31 downto 0);
	signal pxl_addr_reg_en_signal :	std_logic := '0';
	
begin

	-- DETECT THE RISING EDGE
	process(clk,rst_n) is
	begin
		if (rst_n = '0') then
		
	end process;
	
	-- SHIFT DATA IN ON RISING EDGE
	
	-- COUNT NUMBER OF RISING EDGES
	
	-- CALCULATE THE ADDRESS
	
	
	
	

	-- STAGE 0: INPUT SYNCHRONIZATION
	CLK_SYNC0	:	SYNC
		port map(clk,rst_n,pxl_clk_in,pxl_clk_sync0);
		
	DATA_SYNC0	:	SYNC16
		port map(clk,rst_n,pxl_data_in,pxl_data_sync0);
		
	-- STAGE 1:	INPUT REGISTERING
	CLK_REG1	:	DFF
		port map(clk,rst_n,pxl_clk_sync0,pxl_clk_sync1);
		
	DATA_REG1	:	REG16
		port map(clk,rst_n,pxl_data_sync0,pxl_data_sync1);
		
	-- STAGE 2:	PIXEL CLOCK RISING EDGE DETECT
	pxl_clk_sync_RE	<=	pxl_clk_sync0 and (not pxl_clk_sync1);
	
	CLK_REG2	:	DFF
		port map(clk,rst_n,pxl_clk_sync_RE,pxl_clk_sync_RE2);
		
	DATA_REG2	:	REG16
		port map(clk,rst_n,pxl_data_sync1,pxl_data_sync2);

	-- STAGE 3:	SHIFT REGISTER USED TO ACQUIRE TWO BYTES
	SHIFT_REG3	:	SHIFT_REG32
		port map(clk,rst_n,pxl_data_sync2,pxl_data32,pxl_clk_sync_RE2);
	
	COUNTER3		:	COUNTER
		port map(clk,rst_n,pxl_clk_sync_RE2,pxl_data_ready_flag);
		
	-- STAGE 4:	OUTPUT SIGNAL REGISTERING
	DATA_READY4	:	DFF
		port map(clk,rst_n,pxl_data_ready_flag,pxl_data_ready);
--		pxl_data_ready <= pxl_data_ready_flag;
		
	DATA_REG4	:	REG32
		port map(clk,rst_n,pxl_data32,pxl_data_out,pxl_clk_sync_RE2);
		
	ADDR_REG4	:	REG32
		port map(clk,rst_n,pxl_addr_signal,pxl_addr_out_signal,pxl_clk_sync_RE2);
		
	pxl_addr_reg_en_signal <= pxl_data_ready_flag or pxl_addr_rst;
	pxl_addr_signal <= '0' & pxl_addr_gen_signal;
		
	-- ADDRESS GENERATION
	ADDR0	:	ADDRESS_GENERATOR
	 port map ( clk 	=> clk,
			  rst_n 		=> rst_n,
			  addr_rst 	=> pxl_addr_rst,
			  addr_inc	=> pxl_data_ready_flag,
			  addr 		=> pxl_addr_gen_signal);

	pxl_addr_out <= pxl_addr_out_signal(30 downto 0);	

end Structural;

