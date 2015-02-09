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
-- Module:		plxArb
-- Parent:		
-- Description: PLX C mode, bus arbites.
--
-- ds = direct slave, PLX is bus master
-- dm = dirct master, FPGA is bus master
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2007-12-21	MF		Created
-- 2008-04-02	MF		Change to rotating priority scheme, added back off state
--********************************************************************************

------------------------------------------------------------------
--		MODIFIED BY JUSTIN HOGAN
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity plxArb is
    port ( 
		lresetn 			: in  std_logic;
      lclk 				: in  std_logic;
      dsReq 			: in  std_logic; -- lb_lhold
      dsAck 			: out	std_logic; -- lb_lholda
		dsReqForce 		: in 	std_logic; -- lb_breqo
      dmReq 			: in  std_logic;
      dmAck 			: out	std_logic;
		dmBackoff 		: out	std_logic;
		allClkStable 	: in	std_logic);
end plxArb;


architecture rtl of plxArb is

	type arbState is (DS_CHECK, DM_CHECK, DS_TRANSFER, DM_TRANSFER, DM_BACKOFF ); 	
	signal curState :  arbState;
	signal nextState : arbState;
	
begin

	p_state_reg : process(lclk,lresetn,allClkStable)
	begin
		if ( (lresetn = '0') or (allClkStable = '0') ) then
			curState <= DS_CHECK;
		elsif rising_edge (lclk) then
			curState <= nextState;
		end if;
	end process;
	
	
	p_state_sel : process(curState, dsReq, dmReq, dsReqForce)
	begin
		CASE curState IS
			WHEN DS_CHECK =>
				if dsReq = '1' then			    
            		nextState <= DS_TRANSFER;
        		else
         			nextState <= DM_CHECK;
   			end if;

			when DM_CHECK =>
				if dmReq = '1' then
					nextState <= DM_TRANSFER;					
				else				
					nextState <= DS_CHECK;					
				end if;
				
			WHEN DS_TRANSFER => 
				if dsReq = '1' then
					nextState <= DS_TRANSFER;
				else
					nextState <= DM_CHECK;
				end if;			

			WHEN DM_TRANSFER =>
				if dmReq = '1' then
					if dsReqForce = '1' then
						nextState <= DM_BACKOFF;
					else
						nextState <= DM_TRANSFER;					
					end if;
				else				
					nextState <= DS_CHECK;					
				end if;
			
			WHEN DM_BACKOFF =>
			   if dmReq = '0' then
					nextState <= DS_CHECK;
        		else
        			nextState <= DM_BACKOFF;
    			end if;
			
			WHEN others => 
				nextState <= DS_CHECK;
		END CASE;
	end process;
	
	
	-- STATE MACHINE OUTPUT PROCESS -- JAH output logic code
	PLXARB_OUTPUTS	:	process(curState) is
	begin
		case curState is
			when DS_TRANSFER	=>
				dsAck			<= '1';
				dmAck			<= '0';
				dmBackoff	<= '0';
			when DM_TRANSFER	=>
				dsAck			<= '0';
				dmAck			<= '1';
				dmBackoff	<= '0';
			when DM_BACKOFF	=>
				dsAck			<= '0';
				dmAck			<= '0';
				dmBackoff	<= '1';
			when others =>
				dsAck			<= '0';
				dmAck			<= '0';
				dmBackoff	<= '0';
		end case;
	end process;
	
	-- Original output logic code
--	dsAck <= '1' when (curState = DS_TRANSFER) else '0';
--	dmAck <= '1' when (curState = DM_TRANSFER) else '0';	
--	dmBackoff <= '1' when (curState = DM_BACKOFF) else '0';	
end rtl;

