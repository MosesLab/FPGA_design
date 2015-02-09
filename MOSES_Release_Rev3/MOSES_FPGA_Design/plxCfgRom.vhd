--********************************************************************************
-- Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary Information of Connect Tech, Inc
-- and should be treated as Confidential.
--********************************************************************************
-- Project: 	FreeForm/PCI104
-- Module:		plxCfgRom
-- Parent:		plx32BitMaster
-- Description: Configuration ROM, contents hard coded for PLX registers
--
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-01-12	MF		Created
-- 2008-03-05	MF		Added generics for Local address space sizing
-- 2008-03-07	MF		Corrected addtion glitch in generation of range register
-- 2009-03-10	MF		Add enable generics for each local address space
-- '			'		makeRR so that it makes a minimum of 4 bytes 
--********************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
entity plxCfgRom is
----------------------------------------------------------------------------------
	generic ( 	c_romSize 	: integer := 20;
				c_ds0BaseAddr 	: std_logic_vector(31 downto 4) := x"0000000"; 
				c_ds0ByteSz		: natural := 128;--128;
				c_ds0En			: std_logic := '1';				
				c_ds1BaseAddr	: std_logic_vector(31 downto 4) := x"1000000"; 
				c_ds1ByteSz		: natural := 512;
				c_ds1En			: std_logic := '1'
			);
    port ( clk 				: in  std_logic;
           addr 				: in  unsigned (4 downto 0);
           dout 				: out std_logic_vector (47 downto 0));
end plxCfgRom;

----------------------------------------------------------------------------------
architecture rtl of plxCfgRom is
----------------------------------------------------------------------------------

	type rom is array (0 to c_romSize-1) of std_logic_vector (47 downto 0);
	
	function makeRR(byteSz : in natural) return std_logic_vector is
		variable v_tmp : unsigned(31 downto 0);
		variable v_rr : unsigned(32 downto 0);
	begin
		-- basically makes two complement
		if (byteSz < 4) then
			v_tmp := to_unsigned(4,32); -- 128 = 0x80	512 = 0x200
		else
			v_tmp := to_unsigned(byteSz,32); -- 128 = 0x80	512 = 0x200
		end if;
		v_tmp := not(v_tmp);				-- 0xFFFFFF7F	FFFFFDFF
		v_rr := ('0'&v_tmp)+1;					-- 0xFFFFFF80	FFFFFE00
		return(std_logic_vector(v_rr(31 downto 4)));
	end function;
				
--	constant LBRD0		: std_logic_vector(31 downto 0) := x"41000043";
--	constant PCIIDR	: std_logic_vector(31 downto 0);
--	constant PCICR		: std_logic_vector(15 downto 0) := "0000000100000111";
--	constant PCISR		: std_logic_vector(15 downto 0) := x"0000";
--	constant PCISID		: std_logic_vector(15 downto 0) := x"12C4";
--	constant PCISVID	: std_logic_vector(15 downto 0) := x"9999";
--	constant PCIILR		: std_logic_vector(7 downto 0) 	:= x"00";
--	constant PCIIPR		: std_logic_vector(7 downto 0) 	:= x"00";
--	constant PCIMGR		: std_logic_vector(7 downto 0) 	:= x"00";
--	constant PCIMLR		: std_logic_vector(7 downto 0) 	:= x"00";
	constant c_LAS0RR	: std_logic_vector(31 downto 0) :=  makeRR(c_ds0ByteSz) & "0000"; --x"FFFFFC00";
															-- (0) = when 0, space is memory
															-- (2:1) = must be 00 when memory
															-- (3) = when 1, space is prefetchable
	constant c_LAS0BA	: std_logic_vector(31 downto 0) := c_ds0BaseAddr & "000" & c_ds0En;
															-- x"00000001";
															-- (0) = when 1, space is enabled
															-- (1) = reserved
															-- (3:2) = must be 00 when mememory
	constant c_LAS1RR	: std_logic_vector(31 downto 0) := makeRR(c_ds1ByteSz) & "0000"; --x"FFC00000";
	constant c_LAS1BA	: std_logic_vector(31 downto 0) := c_ds1BaseAddr & "000" & c_ds1En; --x"80000001";
															-- x"10000001";

--	constant DMRR 		: std_logic_vector(31 downto 0) := x"FFFF0000";
		--	= Local Range for Direct Master-to-PCI
		--	[31:16]	Spec which local bits to map to pci bits
		--	ie. FFF0 decodes 1MB.


--	constant DMLBAM 	: std_logic_vector(31 downto 0) := x"00010000";
		--	 = Local Base Address for Direct Master-to-PCI Memory
		--	[31:16]	Assigns a value to bits to use for decoding Local-to-PCI Memory accesses.
		--	ie. multiple of 1MB, so 001x

--	constant DMLBAI 	: std_logic_vector(31 downto 0) := x"00000000";
		--	 = Local Base Address for Direct Master-to-PCI I/O Configuration
		--	[31:16]	Assigns a value to bits to use for decoding Local-to-PCI I/O or PCI Configuration Space accesses.

--	constant DMPBAM 	: std_logic_vector(31 downto 0) := x"00001001";
		--	 = PCI Base Address (Remap) for Direct Master-to-PCI Memory
		--	[0]		Direct Master Memory Access Enable
		--	[1]		Direct Master I/O Access Enable
		--	[2]		Direct Master Read Ahead Mode
		--	[13]	I/O Remap Select, when 1 forces PCI_ADDR[31-16] to 0
		--	[31:16]	Remap Local-to-PCI Space into PCI Address Space. Bits in this register
		--			remap (replace) Local Address bits used in decode as the PCI Address bits.

--	constant DMCFGA 	: std_logic_vector(31 downto 0) := x"00000000";
		--	= PCI Configuration Address for Direct Master-to-PCI I/O Configuration

							--	addr		ben		data			pci
							--	47:36		35:32	31:0
	constant romArray : rom :=
							(	
								--x"098" &	x"0" &	x"41000043",	-- 018	LBRD0[31:0]
								-- JAH -- disabled burst mode
								x"098" &	x"0" &	x"41000043",		-- 018	LBRD0[31:0]	
																				-- 32 bit, no wait states
																				-- ready enabled
																				-- burst 4
																				-- burst enabled
																				--
																		
								--x"000" &	x"0" &	x"B00BEEE5",	--PCI Device ID PCIIDR
								    -- default = 9056 10B5
								--x"008" &	x"0" &	x"00000000",	--PCICCR[23:8] / PCIREV[7:0]
								x"004" & 	x"D" & x"00000106", 	-- PCISR / PCICR;
																	-- serr enable
								    -- default = 0680 00BA
								x"02C" &	x"0" &	x"999912C4",	--		PCISID[15:0] / PCISVID[15:0]
								
								x"03C" &	x"0" &	x"00000100",	--		PCIMLR[7:0] / PCIMGR[7:0] / PCIIPR[7:0] / PCIILR[7:0]
								
								x"080" &	x"0" &	c_LAS0RR,		-- 000	LAS0RR[31:0]
								x"084" &	x"0" &	c_LAS0BA,		-- 004	LAS0BA[31:0]
								x"088" &	x"0" &	x"00240000",	-- 008	MARBR[31:0]
								x"08C" &	x"2" &	x"00002000",	-- 00C	LMISC2[5:0]/ PROT_AREA[6:0] / LMISC1[7:0] / BIGEND[7:0]
																				-- all little endian
																				-- enable lserr interrupt
								x"090" &	x"0" &	x"00000000",	-- 010	EROMRR[31:0]
																				-- not used
								x"094" &	x"0" &	x"00000000",	-- 014	EROMBA[31:0]										
																				-- not used

								x"09C" &	x"3" &	x"FFFF0000",	-- 01C	DMRR[31:0]	
								x"0A0" &	x"3" &	x"00010000",	-- 020	DMLBAM[31:0]	
								x"12C" &	x"3" &	x"00000000",	-- 024	DMLBAI[31:0]	
																				-- not required
								x"0A8" &	x"0" &	x"00000001",	-- 028	DMPBAM[31:0]	
																				-- Bit 0 = DM memory access enable
																				-- Bit 12 = Prefetch 8 words on read
								x"0Ac" &	x"0" &	x"00000000",	-- 02C	DMCFGA[31:0]	
																				-- not required								
								
								x"0E8" &	x"0" &	x"00000900",	-- 040 INTCSR
								--x"0E8" &	x"0" &	x"00000100",	-- 
								                                    -- Bit 8 PCI interrupt enable
								                                    -- Bit 11 Local int in enable
								                                    -- Bit 16 Local int out enable
								--x"0C4" &	x"0" &	x"55667788",	-- 044	MBOX1[31:0]

								x"170" &	x"0" &	c_LAS1RR,		-- 0F0	LAS1RR[31:0]
								                                      -- local space is 9 address bits 
								                                      -- 512 bytes
								                                      
								x"174" &	x"0" &	c_LAS1BA,		-- 0F4	LAS1BA[31:0]
								x"178" &	x"0" &	x"00000143",	-- 0F8	LBRD1[31:0]	
								                                       -- bit 1:0 = 11, enable 32 bit
								                                        -- bit 6  = enable ready
								                                        -- bit 8 =  burst enable
																				-- 32 bit, no wait states
																				-- ready enabled
																				-- burst 4
																				-- burst enabled
																				--							

								x"08C" &	x"D" &	x"00000500"		--	LMISC2[5:0]/ PROT_AREA[6:0] / LMISC1[7:0]/ BIGEND[7:0]
							);  

begin

	p_cfgRom : process (clk)                                                
	begin                                                        
		if rising_edge(clk) then                              
			if  to_integer( addr ) < c_romSize then
				dout <= romArray( to_integer(addr) );   
			else
				dout <= romArray( (c_romSize-1) );   
			end if;    
		end if;                                                      
	end process; 
	
end rtl;

