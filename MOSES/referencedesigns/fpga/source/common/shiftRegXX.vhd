library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use work.ctiUtil.all;

----------------------------------------------------------------------------------	
entity shiftRegXX is
----------------------------------------------------------------------------------	
generic ( c_width : natural := 16 );
port (
	clk : in std_logic;
	rstn : in std_logic;
	en : in std_logic;
	load : in std_logic;
	di : in std_logic_vector(c_width-1 downto 0);
	do : out std_logic_vector(c_width-1 downto 0);
	si : in std_logic;
	so : out std_logic
);
end entity shiftRegXX;

----------------------------------------------------------------------------------	
architecture rtl of shiftRegXX is
----------------------------------------------------------------------------------	
	signal reg : std_logic_vector(c_width-1 downto 0);
begin

	p_shift : process (clk,rstn)
	begin
	   if rstn ='0' then 
		  reg <= (others => '0'); 
	   elsif rising_edge(clk) then  
	   	  if load = '1' then 
			reg <= di;
		  elsif en = '1' then 
			reg <= reg(c_width-2 downto 0) & si;
		  end if; 
	   end if;
	end process p_shift;
	
	so <= reg(c_width-1);
	do <= reg;
	
end architecture rtl;