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
				pxl_data_out		:	out	std_logic_vector(63 downto 0);
				pxl_data_ready		:	out	std_logic				
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
	component SHIFT_REG64
	 Port ( clk : in  STD_LOGIC;
			  rst_n : in  STD_LOGIC;
			  D : in  STD_LOGIC_VECTOR (15 downto 0);
			  Q : out  STD_LOGIC_VECTOR (63 downto 0);
			  en : in  STD_LOGIC);
	end component;
	
	component COUNTER
		Generic(TERMINAL_COUNT	:integer := 4);
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
	
begin

	-- STAGE 0: INPUT SYNCHRONIZATION
	CLK_SYNC0	:	SYNC
		port map(clk,rst_n,pxl_clk_in,pxl_clk_sync0);
		
	DATA_SYNC0	:	SYNC16
		port map(clk,rst_n,pxl_data_in,pxl_data_sync0);
		
	-- STAGE 1:	INPUT REGISTERING
	CLK_REG1	:	DFF
		port map(clk,rst_n,pxl_clk_sync0,pxl_clk_sync1);
		
	-- STAGE 2:	PIXEL CLOCK RISING EDGE DETECT
	pxl_clk_sync_RE	<=	pxl_clk_sync0 and (not pxl_clk_sync1);

	-- STAGE 3:	SHIFT REGISTER USED TO ACQUIRE FOUR BYTES
	SHIFT_REG3	:	SHIFT_REG64
		port map(clk,rst_n,pxl_data_sync0,pxl_data_out,pxl_clk_sync_RE);
	
	COUNTER3		:	COUNTER
		generic map(TERMINAL_COUNT => 4)
		port map(clk,rst_n,pxl_clk_sync_RE,pxl_data_ready_flag);

	pxl_data_ready <= pxl_data_ready_flag;

end Structural;

