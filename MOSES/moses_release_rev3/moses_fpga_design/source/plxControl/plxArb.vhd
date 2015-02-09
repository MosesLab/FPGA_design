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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
entity plxArb is
----------------------------------------------------------------------------------
    Port ( lresetn : in  STD_LOGIC;
           lclk : in  STD_LOGIC;
           dsReq : in  STD_LOGIC; -- lb_lhold
           dsAck : out  STD_LOGIC; -- lb_lholda
		   dsReqForce : in std_logic; -- lb_breqo
           dmReq : in  STD_LOGIC;
           dmAck : out  STD_LOGIC;
		   dmBackoff : out std_logic;
		   allClkStable : in std_logic );
end plxArb;

----------------------------------------------------------------------------------
architecture rtl of plxArb is
----------------------------------------------------------------------------------

	type arbState is (		DS_CHECK, 
	                     DM_CHECK,
							DS_TRANSFER,
							DM_TRANSFER,
							DM_BACKOFF ); 
	
	signal curState :  arbState;
	signal nextState : arbState;
	
	--signal dmCnt : std_logic_vector(7 downto 0);
	--signal dmCntEn : std_logic;
	--signal dmCntRst : std_logic;


	--signal dsCnt : std_logic_vector(7 downto 0);
	--signal dsCntEn : std_logic;
	--signal dsCntRst : std_logic;	
	
begin

	p_state_reg : process(lclk,lresetn,allClkStable)
	begin
		if lresetn = '0' or allClkStable = '0' then
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

	-- State machine outputs
	dsAck <= '1' when (curState = DS_TRANSFER) else '0';
--	dsCntEn <= '1' when (curState = DS_TRANSFER) else '0';
--	dsCntRst <= '1' when (curState /= DS_TRANSFER) else '0';
	
	dmAck <= '1' when (curState = DM_TRANSFER) else '0';	
--	dmCntEn <= '1' when (curState = DM_TRANSFER) else '0';	
--	dmCntRst <= '1' when (curState /= DM_TRANSFER) else '0';	
	dmBackoff <= '1' when (curState = DM_BACKOFF) else '0';	
	
	-- Direct slave cycle counter
	-- p_dsCnt : process(lclk,lresetn)
		-- variable cnt : unsigned(7 downto 0);
	-- begin
		-- if lresetn = '0' then
			-- cnt := (others => '0');
		-- elsif rising_edge(lclk) then
			-- if (dsCntRst = '1') then
				-- cnt := (others => '0');		           
			-- elsif (dsCntEn = '1') then 
				-- cnt := cnt + 1;
			-- end if;
		-- end if;
		
		-- dsCnt <= std_logic_vector(cnt);
	-- end process p_dsCnt;
	
	-- Direct master cycle counter
	-- p_dmCnt : process(lclk,lresetn)
		-- variable cnt : unsigned(7 downto 0);
	-- begin
		-- if lresetn = '0' then
			-- cnt := (others => '0');
		-- elsif rising_edge(lclk) then
			-- if (dmCntRst = '1') then
				-- cnt := (others => '0');		           
			-- elsif (dmCntEn = '1') then 
				-- cnt := cnt + 1;
			-- end if;
		-- end if;
		
		-- dmCnt <= std_logic_vector(cnt);
	-- end process p_dmCnt; 
	

end rtl;

