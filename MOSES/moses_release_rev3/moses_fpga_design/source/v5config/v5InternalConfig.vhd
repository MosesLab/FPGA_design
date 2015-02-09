----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity v5InternalConfig is
    Port ( clk : in  STD_LOGIC;
           start : in  STD_LOGIC);
end v5InternalConfig;

architecture rtl of v5InternalConfig is





	function bitSwap(din : std_logic_vector(31 downto 0) ) return std_logic_vector is
		variable dout : std_logic_vector(31 downto 0);
		variable i : natural;
	begin
	
		for i in 0 to 7 loop
			dout(i) 	:= din(7-i);
			dout(i+8) 	:= din(15-i);
			dout(i+16)	:= din(23-i);
			dout(i+24)	:= din(31-i);
		end loop;
	
		return dout;
	end function;

	signal icapBusy : std_logic;
	signal icapDo : std_logic_vector(31 downto 0);
	signal icapCe : std_logic;
	signal icapDi :std_logic_vector(31 downto 0);
	signal icapWrn : std_logic;
	signal startPrev : std_logic;
	
	signal romAddr : unsigned(3 downto 0);
	
	constant rom : std_logic_matrix_32(0 to 15) :=
		( 		bitSwap(x"FFFFFFFF"), --dummy
				bitSwap(x"AA995566"),  --Sync Word
				bitSwap(x"20000000"),  --Type 1 NO OP
				bitSwap(x"30020001"),  --Type 1 Write 1 Words to WBSTAR
				bitSwap(x"00000000"),  --Warm Boot Start Address (Load the Desired Address
				bitSwap(x"30008001"),  --Type 1 Write 1 Words to CMD
				bitSwap(x"0000000F"),  --IPROG Command
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"),  --Type 1 NO OP 
				bitSwap(x"20000000"));--Type 1 NO OP 

--The ICAP_VIRTEX5 primitive works the same way as the SelectMAP configuration 
--interface except it is on the fabric side, and ICAP has a separate read/write bus, as opposed 
--to the bidirectional bus in SelectMAP. The general SelectMAP timing diagrams and the 
--SelectMAP bitstream ordering information as described in the ?SelectMAP Configuration 
--Interface? section of this user guide are also applicable to ICAP. It allows the user to access 
--configuration registers, readback configuration data, or partially reconfigure the FPGA 
--after configuration is done.
--ICAP has three data width selections through the ICAP WIDTH parameter: x8, x16, and 
--x32.
--The two ICAP ports cannot be operated simultaneously. The design must start from the top 
--ICAP, then switch back and forth between the two. 


--CLK		Input	ICAP interface clock 
--CE		Input	Active-Low ICAP interface select. Equivalent to CS_B in the SelectMAP interface.
--WRITE	I	nput	0=WRITE, 1=READ. Equivalent to the RDWR_B signal in the SelectMAP interface.
--I[31:0]	Input	ICAP write data bus. The bus width depends on ICAP_WIDTH parameter. The bit ordering is identical to 
--					the SelectMAP interface. See SelectMap Data Ordering in 
--O[31:0]	Output	ICAP read data bus. The bus width depends on the ICAP_WIDTH parameter. The bit ordering is identical to 
--					the SelectMAP interface. See SelectMap Data Ordering in 
--BUSY		Output	Active-High busy status. Only used in read operations. BUSY remains Low during writes.

--Dummy Word
--FFFFFFFF dummy
--AA995566  Sync Word
--20000000  Type 1 NO OP
--30020001  Type 1 Write 1 Words to WBSTAR
--00000000  Warm Boot Start Address (Load the Desired Address
--30008001  Type 1 Write 1 Words to CMD
--0000000F  IPROG Command
--20000000  Type 1 NO OP	

	attribute INIT: string;
	attribute INIT of icapCe : signal is "1"; 
	attribute INIT of icapWrn : signal is "1"; 			
begin


	p_start : process(clk)
	begin
		if rising_edge(clk) then
			startPrev <= start;
		end if;
	end process;
	
	p_enable : process(clk)
	begin
		if rising_edge(clk) then
			if ((start = '1') and (startPrev = '0')) then
				icapCe <= '0';
				icapWrn <= '0';
			end if;
		end if;
	end process;		

	p_romAddrCnt : process(clk)
	begin
		if rising_edge(clk) then
			if icapCe = '0' then
				romAddr <= romAddr + 1;
			else
				romAddr <= (others => '0');
			end if;
		end if;
	end process;

	icapDi <= rom(to_integer(romAddr));

   u_icap : ICAP_VIRTEX5
   generic map (
      ICAP_WIDTH => "X32") -- "X8", "X16" or "X32" 
   port map (
      BUSY => icapBusy,   	-- Busy output
      O => icapDo,         	-- 32-bit data output
      CE => icapCe,       	-- Clock enable input
      CLK => CLK,     		-- Clock input
      I => icapDi,      	-- 32-bit data input
      WRITE => icapWrn  	-- Write input
   );
end rtl;

