--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.ALL;

package ctiUtil is

	constant DDR2400 : integer := 0;
	constant DDR2533 : integer := 1;
	constant DDR2667 : integer := 2;

	-- Types
	type std_logic_matrix_02 is array(integer range <>) of std_logic_vector(1 downto 0);
	type std_logic_matrix_03 is array(integer range <>) of std_logic_vector(2 downto 0);
	type std_logic_matrix_04 is array(integer range <>) of std_logic_vector(3 downto 0);
	type std_logic_matrix_05 is array(integer range <>) of std_logic_vector(4 downto 0);	
	type std_logic_matrix_06 is array(integer range <>) of std_logic_vector(5 downto 0);	
	type std_logic_matrix_08 is array(integer range <>) of std_logic_vector(7 downto 0);	
	type std_logic_matrix_16 is array(integer range <>) of std_logic_vector(15 downto 0);	
	type std_logic_matrix_32 is array(integer range <>) of std_logic_vector(31 downto 0);	
	type std_logic_matrix_64 is array(integer range <>) of std_logic_vector(63 downto 0);		
	type std_logic_matrix_128 is array(integer range <>) of std_logic_vector(127 downto 0);			
	
	-- Declare functions and procedure
	function to_stdlogic(x : in natural; size : in natural) return std_logic_vector;
	function to_stdlogic(x : in boolean) return std_logic;
	function bToS (bVal : in boolean) return std_logic;
	function powerOfTwo( x : in natural) return natural;
	function maximum (x, y : in natural) return natural;
 	function reverse_bit_order(vec : in std_logic_vector) return std_logic_vector;
	function flipMsb(x : in std_logic_vector) return std_logic_vector;
	function flipEndian(x : in std_logic_vector) return std_logic_vector;

end ctiUtil;


package body ctiUtil is

   --from numeric_std: function TO_UNSIGNED (ARG, SIZE: NATURAL) return UNSIGNED;
   function to_stdlogic(x : in natural; size : in natural) return std_logic_vector is
      variable result : std_logic_vector(size-1 downto 0);
   begin
       result := std_logic_vector(to_unsigned(x, size));
      return result;
   end to_stdlogic;

    function to_stdlogic(x : in boolean) return std_logic is
   	    variable result : std_logic;
   	begin 
   	    if x then
   	        result := '1';
   	    else
   	        result := '0';
   	    end if;
   	    
   	    return result;
   	end function;
   
	function bToS (bVal : in boolean) return std_logic is
		variable sVal : std_logic;
	begin
		if bVal = true then
			sVal := '1';
		else
			sVal := '0';
		end if;
		
		return sVal;
	end function;   
	
	function powerOfTwo( x : in natural) return natural is
		variable y : natural;
	begin
	    y := 0;
		
		while (2**y < x) loop
			y := y + 1;
		end loop; 
		
		return y;
	end function;
	
	function maximum (x, y : in natural) return natural is
	begin  -- function max
		if x >= y then 
			return x;
		else 
			return y;
		end if;
	end function maximum;
	
	function reverse_bit_order(vec : in std_logic_vector) return std_logic_vector is
		variable result: std_logic_vector(vec'RANGE);
		alias tmp: std_logic_vector(vec'REVERSE_RANGE) is vec;
	begin
		for i in tmp'RANGE loop
			result(i) := tmp(i);
		end loop;

		return result;
	end function reverse_bit_order;
	
	function flipMsb(x : in std_logic_vector) return std_logic_vector is
		variable y : std_logic_vector(x'reverse_range);
	begin
		for i in x'range loop
			y(y'high-i) := x(i); 
		end loop;
		
		return(y);
	end function;		
	
	function flipEndian(x : in std_logic_vector) return std_logic_vector is
		variable y : std_logic_vector(x'range);
		variable numByte : natural;
		variable lastByte : natural;
	begin
	
--		numByte := (x'left + 1) / 8;
--		lastByte := numByte-1;
--		
--		for i in 0 to lastByte loop
--			y(i*8+7 downto i*8) := x(((lastByte-i)*8+7) to ((lastByte-i)*8));
--		end loop;

		y(31 downto 24) := x( 7 downto  0);
		y(23 downto 16) := x(15 downto  8);
		y(15 downto  8) := x(23 downto 16);
		y( 7 downto  0) := x(31 downto 24);
		
		
		return (y);
	end function;	
	
end ctiUtil;
