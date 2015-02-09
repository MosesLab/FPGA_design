--********************************************************************************
-- Copyright © 2008 Connect Tech inc. All Rights Reserved. 
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH inC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary information of Connect Tech, inc
-- and should be treated as Confidential.
--
--********************************************************************************
-- Project: 	FreeForm/PCI-104
-- Module:		regBank_32
-- Parent:		(any)
-- Description: Configurable 32 bit register bank
--
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-03-05	MF		If the register bank is not enabled; output 0xDDDDDDDD
--********************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regBank_32 is
	generic	( 	selWidth : natural := 4;
				busReadOnly : bit_vector (63 downto 0) := (others=>'0') );
    port ( 
		clk : in  STD_LOGIC;
		rstn : in  STD_LOGIC;
		
		busEn : in std_logic;
		busSel : in  STD_LOGIC_vector((selWidth-1) downto 0);
		busWr : in  STD_LOGIC_vector(3 downto 0);
		busIn : in  STD_LOGIC_VECTOR (31 downto 0);
		busOut : out  STD_LOGIC_VECTOR (31 downto 0);

		localWr : in std_logic_matrix_04(((2**selWidth)-1) downto 0);
		localIn : in  std_logic_matrix_32 (((2**selWidth)-1) downto 0);
		localOut : out   std_logic_matrix_32 (((2**selWidth)-1) downto 0)   
   );
end regBank_32;

architecture rtl of regBank_32 is

	constant numReg : natural := (2**selWidth);

	signal regQ : std_logic_matrix_32((numReg-1) downto 0);
	signal wren : std_logic_matrix_04((numReg-1) downto 0);
	signal muxOut : STD_LOGIC_VECTOR (31 downto 0);
	
	component XTo1Mux_32 is
		generic (	selWidth : natural := 3 );
		port (
			sel : in std_logic_vector(selWidth-1 downto 0);
			din : in std_logic_matrix_32((2**selwidth)-1 downto 0);
			dout : out std_logic_vector(31 downto 0)
		);
	end component;

begin

	-- generate 8 registers
	g_regs : for i in 0 to (numReg-1) generate

		g_read : if busReadOnly(i) = '1' generate
			p_regA : process(rstn, clk)
				begin
				if (rstn = '0') then
				   	regQ(i) <= (others => '0');
				elsif rising_edge (clk) then 
					if localWr(i)(0) = '1' then
						regQ(i)(7 downto 0) <= localIn(i)(7 downto 0);
					end if;

					if localWr(i)(1) = '1' then
						regQ(i)(15 downto 8) <= localIn(i)(15 downto 8);
					end if;

					if localWr(i)(2) = '1' then
						regQ(i)(23 downto 16) <= localIn(i)(23 downto 16);
					end if;

					if localWr(i)(3) = '1' then
						regQ(i)(31 downto 24) <= localIn(i)(31 downto 24);
					end if;
					
				end if;
			end process; -- p_regA		
		end generate; -- g_read 
		
		g_read_write : if busReadOnly(i) = '0' generate
		
			wren(i)(0) <= '1' when  busSel = std_logic_vector( to_unsigned(i,selWidth) ) and (busWr(0) = '1') and (busEn = '1') else '0';
			wren(i)(1) <= '1' when  busSel = std_logic_vector( to_unsigned(i,selWidth) ) and (busWr(1) = '1') and (busEn = '1') else '0';
			wren(i)(2) <= '1' when  busSel = std_logic_vector( to_unsigned(i,selWidth) ) and (busWr(2) = '1') and (busEn = '1') else '0';
			wren(i)(3) <= '1' when  busSel = std_logic_vector( to_unsigned(i,selWidth) ) and (busWr(3) = '1') and (busEn = '1') else '0';		
		
			p_reg : process(rstn, clk)
				begin
				if (rstn = '0') then
				   	regQ(i) <= (others => '0');
				elsif rising_edge (clk) then 

						if (wren(i)(0)='1') then
							regQ(i)(7 downto 0) <= busIn(7 downto 0); 
						end if;
						
						if (wren(i)(1)='1') then
							regQ(i)(15 downto 8) <= busIn(15 downto 8); 
						end if;
						
						if (wren(i)(2)='1') then
							regQ(i)(23 downto 16) <= busIn(23 downto 16); 
						end if;
						
						if (wren(i)(3)='1') then
							regQ(i)(31 downto 24) <= busIn(31 downto 24); 
						end if;	
				end if;
			end process; -- p_reg
		end generate; -- g_read_write
		
	end generate; -- g_regs

	u_mux : XTo1Mux_32
	generic map (	selWidth => selWidth )
	port map (
		sel => busSel,
		din => regQ,
		dout => muxOut );
	
	busOut <= muxOut when busEn = '1' else x"DDDDDDDD";
	    
	localOut <= regQ;
end rtl;

