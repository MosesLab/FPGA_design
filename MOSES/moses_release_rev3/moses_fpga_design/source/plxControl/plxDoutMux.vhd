-- 2008-06-10 MF removed signal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.ctiUtil.all;

entity lbDoutMux is
port ( 	
	owner 	: in std_logic;
	dsSpace : in std_logic;
	ds0Sel 	: in std_logic;
	ds1Sel 	: in std_logic;
	ds0Data : in std_logic_matrix_32(1 downto 0);
	ds1Data : in std_logic_matrix_32(1 downto 0);		
	dmSel 	: in std_logic;
	dmData 	: in std_logic_matrix_32(1 downto 0);
	dout 	: out std_logic_vector(31 downto 0)
);
end lbDoutMux;

architecture rtl of lbDoutMux is

	signal muxSel : std_logic_vector(2 downto 0);

	--signal sel : std_logic_vector(5 downto 0);
begin

--				dmSel => cfgComplete,
--				dmData(0) => cfgRomDout(31 downto 0),
--				dmData(1) => ramDout,
--					
--				dsSpace => ds1AddrValid,
--				ds0Sel => ds0RamEn,
--				ds0Data(0) => ds0RegDout,
--				ds0Data(1) => ramDout,
--				ds1Sel => ds1RamEn,
--				ds1Data(0) => ds1RegDout,
--				ds1Data(1) => ds1RamDout,




	muxSel(2) <= owner;
	muxSel(1) <= dsSpace;
	muxSel(0) <= (	  owner and dmSel ) or 
				 (not owner and ( (not dsSpace and ds0Sel ) or  
								  (    dsSpace and ds1Sel ) ) );
				 
				 
	dout <=	ds0Data(0) 	when muxSel = "000" else
			ds0Data(1) 	when muxSel = "001" else
			ds1Data(0) 	when muxSel = "010" else
			ds1Data(1) 	when muxSel = "011" else
			dmData(0) 	when muxSel = "100" else
			dmData(1) 	when muxSel = "101" else
			dmData(0) 	when muxSel = "110" else
			dmData(1) 	when muxSel = "111";  
			
--	p_ld_datapath : process(dsSpace,dmData, ds0Data, ds1Data, owner, dmSel, ds0Sel,ds1Sel)
--	begin
--		if owner = '1' then
--			if (dmSel = '1') then
--				dout <= dmData(1);          
--			else
--				dout <= dmData(0);
--			end if;
--		else
--			if dsSpace = '1' then
--				if (ds1Sel = '1') then
--					dout <= ds1Data(1);
--				else 
--					dout <= ds1Data(0);
--				end if;
--			else
--				if (ds0Sel = '1') then
--					dout <= ds0Data(1);
--				else 
--					dout <= ds0Data(0);
--				end if;				
--			end if;			
--		end if;
--	 end process;
	 
end architecture;