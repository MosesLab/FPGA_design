
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ctiUtil.all;

entity XTo1Mux_32 is
	generic (	selWidth : natural := 3 );
	port (
		sel : in std_logic_vector(selWidth-1 downto 0);
		din : in std_logic_matrix_32((2**selwidth)-1 downto 0);
		dout : out std_logic_vector(31 downto 0)
	);
end XTo1Mux_32;

architecture rtl of XTo1Mux_32 is
	constant numInput : natural := 2**selwidth;
begin

-- ~~~~~~~~~~~~~~~~~~~~~
-- IMPLEMENTATION A ~~~~
-- ~~~~~~~~~~~~~~~~~~~~~

	p_mux : process(sel, din)
	begin
		for i in 0 to numInput-1 loop
		
			if std_logic_vector(to_unsigned(i,selWidth)) = sel then
				dout <= din(i);
			end if;
		
		end loop;
	end process;

-- ~~~~~~~~~~~~~~~~~~~~~
-- IMPLEMENTATION B ~~~~
-- ~~~~~~~~~~~~~~~~~~~~~

--	dout <= din( to_integer( unsigned(sel)) );

-- ~~~~~~~~~~~~~~~~~~~~~
-- IMPLEMENTATION B ~~~~
-- ~~~~~~~~~~~~~~~~~~~~~

--	g_mux2x1 : if selWidth = 1 generate
--		dout <= din(0) when sel="0" else
--				din(1);
--	end generate;
--
--	g_mux4x1 : if selWidth = 2 generate
--		dout <= din(0) when sel="00" else
--				din(1) when sel="01" else		
--				din(2) when sel="10" else	
--				din(3);
--	end generate;
--	
--	g_mux8x1 : if selWidth = 3 generate
--		dout <= din(0) when sel="000" else
--				din(1) when sel="001" else		
--				din(2) when sel="010" else	
--				din(3) when sel="011" else	
--				din(4) when sel="100" else
--				din(5) when sel="101" else		
--				din(6) when sel="110" else	
--				din(7);
--	end generate;
--
--	g_mux16x1 : if selWidth = 4 generate
--		dout <= din(0) when sel="0000" else
--				din(1) when sel="0001" else		
--				din(2) when sel="0010" else	
--				din(3) when sel="0011" else	
--				din(4) when sel="0100" else
--				din(5) when sel="0101" else		
--				din(6) when sel="0110" else	
--				din(7) when sel="0111" else	
--				din(8) when sel="1000" else
--				din(9) when sel="1001" else		
--				din(10) when sel="1010" else	
--				din(11) when sel="1011" else	
--				din(12) when sel="1100" else
--				din(13) when sel="1101" else		
--				din(14) when sel="1110" else	
--				din(15);
--	end generate;	
end rtl;