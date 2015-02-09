--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.ALL;
use std.textio.all;

package ctiSim is

	-- Types

	-- Procedure Declarations
	procedure msg(text : string);
	procedure msg(active : boolean; text: string);
	procedure title (text :string);
	procedure waitRisingEdge (signal x : in std_logic);    
	procedure waitFallingEdge (signal x : in std_logic);
	procedure waitFallingEdge(cycles : in integer; signal  x : in std_logic);
	procedure waitRisingEdge(cycles : in integer;  signal  x : in std_logic);
    function iff( expr : boolean; op1 : string; op2 : string) return string;
end ctiSim;


package body ctiSim is

        procedure msg(text : string) is
            variable l : line;
        begin
           
            --gMsg(1 to text'right) <= text;
        				write(l,now);
				write(l,(" : " & text));
				writeline(output,l);
        end procedure;
        
		procedure msg(active : boolean; text: string) is
		   --variable msgStr : string(1 to 90);
		   variable l : line;
		begin
			if active then
				write(l,now);
				write(l,(" : " & text));
				writeline(output,l);
			end if;
		end procedure;
    
        procedure title (text :string) is
        variable l : line;
        begin
            write(l,string'("========================================="));
            writeline(output,l);
            --write(l,text);
            --writeline(output,l);
				msg("=== " & text);
            write(l,string'("========================================="));
            writeline(output,l);
        end procedure;

		-- waits for the rising edge of a signal
		procedure waitRisingEdge (signal x : in std_logic) is    
		begin
			wait until rising_edge(x);
		end waitRisingEdge;
	 
	 	-- waits for the falling edge of a signal
		procedure waitFallingEdge (signal x : in std_logic) is    
		begin
			wait until falling_edge(x);
		end waitFallingEdge;
	
        procedure waitFallingEdge(cycles : in integer; signal  x : in std_logic) is
        begin
            for i in 1 to cycles loop
                wait until falling_edge(x);
            end loop;
        end procedure;
        
        
        procedure waitRisingEdge(cycles : in integer;  signal  x : in std_logic) is
        begin
            for i in 1 to cycles loop
                wait until rising_edge(x);
            end loop;
        end procedure;
        
        function iff( expr : boolean; op1 : string; op2 : string) return string is
        begin
            if( expr ) then
                return op1;    
            else
                return op2;            
            end if;
        end function;
end ctiSim;
