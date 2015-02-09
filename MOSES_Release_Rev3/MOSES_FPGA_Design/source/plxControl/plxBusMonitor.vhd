--********************************************************************************
-- Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.
--
-- THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
-- The copyright notice above does not evidence any actual or intended
-- publication of such source code.
--
-- This module contains Proprietary Information of Connect Tech, Inc
-- and should be treated as Confidential.
--********************************************************************************
-- Project: 	FreeForm/PCI104
-- Module:		plxBusMonitor
-- Parent:		init_plx
-- Description: Chipscope ILA sampling the PLX local bus
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2008-01-10	MF		Created
-- 2008-02-11	MF 		Changed generic defaults
-- 2008-05-01	MF 		Move generic decision to top level
--********************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
entity plxBusMonitor is
----------------------------------------------------------------------------------
port(
	clk : in std_logic;
	lb_adsn : in std_logic;  
	lb_bigendn : in std_logic;
	lb_blastn : in std_logic;
	lb_breqi : in std_logic;
	lb_breqo : in std_logic;
	lb_btermn : in std_logic;
	lb_ccsn : in std_logic; 
	lb_dackn : in std_logic_vector(1 downto 0);
	lb_eotn : in std_logic;
	lb_dp : in std_logic_vector(3 downto 0);
	lb_dreqn : in std_logic_vector(1 downto 0);	
	lb_la : in std_logic_vector(31 downto 2); 
	lb_lben : in std_logic_vector(3 downto 0);
	lb_lclko : in std_logic;
	lb_lclki : in std_logic;
	lb_ld : in std_logic_vector(31 downto 0);
	lb_lhold : in std_logic;
	lb_lholda : in std_logic;
	lb_lintin : in std_logic;						
	lb_linton : in std_logic;
	lb_lresetn : in std_logic;
	lb_lserrn : in std_logic;
	lb_lw_rn : in std_logic;
	lb_pmereon : in std_logic;
	lb_readyn : in std_logic;
	lb_useri : in std_logic;
	lb_usero : in std_logic;
	lb_waitn : in std_logic;
	allClkStable : in std_logic 
);
end plxBusMonitor;

----------------------------------------------------------------------------------
architecture chipscope of plxBusMonitor is
----------------------------------------------------------------------------------

	component icon01
    port
    (
		control0    :   inout std_logic_vector(35 downto 0)
	);
	end component;

	component ilaPlxBus
    port
	(
	control     : inout    std_logic_vector(35 downto 0);
	clk         : in    std_logic;
	data        : in    std_logic_vector(76 downto 0);
	trig0       : in    std_logic_vector(7 downto 0);
	trig1       : in    std_logic_vector(0 downto 0);
	trig2       : in    std_logic_vector(0 downto 0);
	trig3       : in    std_logic_vector(0 downto 0)
	);
	end component;	
	
	signal cscontrol0       : std_logic_vector(35 downto 0);

	signal csdata       : std_logic_vector(76 downto 0);
	signal cstrig0      : std_logic_vector(7 downto 0);
	signal cstrig1      : std_logic_vector(0 downto 0);
	signal cstrig2      : std_logic_vector(0 downto 0);
	signal cstrig3      : std_logic_vector(0 downto 0);

begin


		i_icon : icon01
	    port map
	    (
			control0    => cscontrol0
	    );

		i_ila : ilaPlxBus
		port map
		(
			control   => cscontrol0,
			clk       => clk,
			data      => csdata,
			trig0     => cstrig0,
			trig1     => cstrig1,
			trig2     => cstrig2,
			trig3     => cstrig3
		);	
		
		
		cstrig0 <= lb_la(9 downto 2);
		cstrig1(0) <= lb_ccsn;
		cstrig2(0) <= lb_blastn;
		cstrig3(0) <= lb_readyn;
		
		
		csdata(0) <= lb_adsn;  
		--lb_bigendn : in std_logic;
		csdata(1) <= lb_blastn;
		--lb_breqi : in std_logic;
		--lb_breqo : in std_logic;
		--lb_btermn : in std_logic;
		csdata(2) <= lb_ccsn; 
		--lb_dackn : in std_logic_vector(1 downto 0);
		--lb_eotn : in std_logic;
		--lb_dp : in std_logic_vector(3 downto 0);
		--lb_dreqn : in std_logic_vector(1 downto 0);	
		csdata(32 downto 3) <= lb_la; 
		csdata(36 downto 33) <= lb_lben;
		csdata(37) <= lb_lclko;
		csdata(38) <= lb_lclki;
		csdata(70 downto 39) <= lb_ld;
		csdata(71) <= lb_lhold;
		csdata(72) <= lb_lholda;
		--lb_lintin : in std_logic;						
		--lb_linton : in std_logic;
		csdata(73) <= lb_lresetn;
		csdata(74) <= lb_lserrn;
		csdata(75) <= lb_lw_rn;
		--lb_pmereon : in std_logic;
		csdata(76) <= lb_readyn;
		--lb_useri : in std_logic;
		--lb_usero : in std_logic;
		--lb_waitn : in std_logic

		
end chipscope;

