library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.ALL;

package ffpci104_pkg is
	constant c_product			: string(1 to 8) := "FCG006RD";
	constant c_bldType			: std_logic_vector(7 downto 0) := x"00";
	constant c_pcbrev			: character := 'D';
	constant c_v5type			: string(1 to 3) := "LXT";
	constant c_DQ_IO_MS 		: bit_vector := "11001100100101011011001000100011";	
--	constant c_autoblink		: boolean := false;
	constant c_simulation 		: boolean := false;
	constant c_plxDebug 		: boolean := false; -- don't enable at same time as DDR2 debug
--	constant c_ddr2enable 		: boolean := true;
--	constant c_emacenable 		: boolean := true;
--	constant c_eepromenable 	: boolean := true;
--	constant c_serialenable 	: boolean := true;
	constant c_ddr2Debug 		: integer := 0;
	constant c_emacPorCntBit	: natural := 24;
--	constant c_gpioDiff 		: boolean := FALSE;
	constant c_enPlxCfg 		: boolean := true;
	constant c_ODT_TYPE			: integer := 1; -- ODT (=0(none),=1(75),=2(150),=3(50))
	constant c_REDUCE_DRV		: integer := 0; -- reduced strength mem I/O (=1 yes)
	
	constant c_standalone		: boolean := FALSE;
	constant c_gtp_debug 		: integer := 0;
end package ffpci104_pkg;

package body ffpci104_pkg is
end package body ffpci104_pkg;