--********************************************************************************
-- Copyright © 2008 Connect Tech Inc. All Rights Reserved. 
--********************************************************************************
-- Project: 	FreeForm/PCI104
-- Module:		plx32BitSlave
-- Parent:		
-- Description: PLX C mode, 32 bit local bus slave.
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2007-11-29	MF		Created
-- 2008-01-14	MF		Moved all datapath, and address validation to top level
-- 2008-01-16	MF		Add logic to handle two address spaces
-- 2008-04-16	MF		Removed lserrn as output
--********************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ctiUtil.all;

----------------------------------------------------------------------------------
entity plx32BitSlave is
----------------------------------------------------------------------------------
	port (
		lresetn			: in std_logic; 							-- Local bus reset
		lclk			: in std_logic;								-- Local clock input
		ld_dir			: out std_logic;
		lben			: in std_logic_vector(3 downto 0);			-- Local Byte Enables
		adsn			: in std_logic;								-- Addres Strobe
		blastn			: in std_logic;								-- Burst last
		READYn			: out std_logic;							-- READY I/O
		lw_rn			: in std_logic;								-- Local Write/Read															
		--lserrn        	: out std_logic;
		plxAck			: in std_logic;
		addrValid0		: in std_logic;
		addrValid1		: in std_logic;		
		wrByte0			: out std_logic_vector( 3 downto 0);
		wrByte1			: out std_logic_vector( 3 downto 0);		
		ramAccess0		: in std_logic;
		ramAccess1		: in std_logic;
		burst4			: in std_logic
	);
end plx32BitSlave; 

----------------------------------------------------------------------------------
architecture rtl of plx32BitSlave is
----------------------------------------------------------------------------------

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Type Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	type core_FSM_states is (	IDLE, 
								ADDR_VALID,
								ADDR_INVALID,								
								READY, 
								WAIT_BLAST, 
								ERROR_STATE,
								WAIT_RAM); 
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- n/a

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Signal Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	signal ctrlState, ctrlNextState : core_FSM_states;

	signal wr0 : std_logic;
	signal wr1 : std_logic;
	signal rd0 : std_logic;
	signal rd1 : std_logic;

	signal burstCntEn: std_logic;
	signal burstCntRst: std_logic;	
	signal burstCnt: std_logic_vector(7 downto 0);

	signal ramRdAccess : std_logic;
	signal tmpcnt0 : unsigned(7 downto 0);
	signal addrSpaceValid : std_logic;
	
begin

	ramRdAccess <= ((ramAccess0 and addrValid0) or (ramAccess1 and addrValid1)) and not lw_rn;
	addrSpaceValid <= addrValid0 xor addrValid1;
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--  State Machine
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	-- State Register
	p_StateReg : process(lclk, lresetn )
	begin
		if lresetn = '0' then
			ctrlState <= IDLE;
		elsif (lclk'event and lclk='1') then
			ctrlState <= ctrlNextState;
		end if;
	end process;	
	
	-- State machine
	p_SM : process(	ctrlState, 
					addrSpaceValid,
					ramRdAccess,
					blastn,
					adsn, 
					burstCnt, 
					plxAck,
					burst4 )
	begin
-- execute on change in either "cntrlState" or "adsn"
	CASE ctrlState IS
	
		WHEN IDLE =>
			-- stay in IDLE state until ADS kicks off new cycle
			-- ADS detected, a new cycle has been launched. 
			if (adsn = '0' and plxAck = '1') then
			
				if 	(addrSpaceValid = '1')  then
					ctrlNextState <= ADDR_VALID;
				else
					ctrlNextState <= ADDR_INVALID;
				end if;
			else
				ctrlNextState <= IDLE;	
			end if;						                    	

		-- address state - assign and drive CE's.
		WHEN ADDR_VALID => 										
			--ctrlNextState <= READY;							
			if ramRdAccess ='1' then
				ctrlNextState <= wait_ram;
			else
				ctrlNextState <= READY;
			end if;

		when ADDR_INVALID =>
			ctrlNextState <= WAIT_BLAST;
			
		-- while waiting for synchronus ram access, deassert READY
		when wait_ram =>
			ctrlNextState <= READY;

		WHEN READY =>
		
			-- if Byte Last signal detected - normal end cycle
			if (blastn = '0') then
				ctrlNextState <= IDLE;
			else	
				-- expected for lwords to be written, cnt increments while in READY state
				-- on count 3, we are on 4th lword.
				if ((burstCnt < x"03") or burst4 = '0' ) and (addrSpaceValid = '1') then
					if ramRdAccess ='1' then
						ctrlNextState <= wait_ram;
					else
						ctrlNextState <= READY;
					end if;
				else  
				    if (burstCnt >= x"03") and (burst4 = '1') then
                    	ctrlNextState <= ERROR_STATE;
               		else
                   		ctrlNextState <= WAIT_BLAST;
           			end if;
				end if;
			end if;   
			
		-- Wait for blast to be asserted, but make sure that writing doesn't occur
		WHEN WAIT_BLAST =>			
			if (blastn = '0') then
				ctrlNextState <= IDLE;
			else	
				    if (burstCnt >= x"03") and (burst4 = '1') then
                    	ctrlNextState <= ERROR_STATE;
               		else
                   		ctrlNextState <= WAIT_BLAST;
           			end if;	            
			end if;   					
			
		-- what do we do?
		WHEN ERROR_STATE => 
		    	if (blastn = '0') then
				ctrlNextState <= IDLE;
			else	
				ctrlNextState <= ERROR_STATE;
			end if;
		END CASE;
	END PROCESS; -- state machine evaluation

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- State machine outputs
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	--lserrn <= '0' when (ctrlState =  ERROR_STATE) else '1';							
	READYn <= '0' 	when (ctrlState =  READY) or (ctrlState = WAIT_BLAST) or (ctrlState = ERROR_STATE) else '1';													
	burstCntEn <= '1' when 	((ctrlState = READY) or (ctrlState = WAIT_BLAST)) else '0';			
	burstCntRst <= '1' when 	(ctrlState = IDLE) else '0';				
	
	wr0 <= '1' when (ctrlState = READY) and (lw_rn = '1') and (addrValid0 = '1') else '0';
	wr1 <= '1' when (ctrlState = READY) and (lw_rn = '1') and (addrValid1 = '1') else '0';
	
	wrByte0(0) <= wr0 and not lben(0);
	wrByte0(1) <= wr0 and not lben(1);
	wrByte0(2) <= wr0 and not lben(2);
	wrByte0(3) <= wr0 and not lben(3);	
	
	wrByte1(0) <= wr1 and not lben(0);
	wrByte1(1) <= wr1 and not lben(1);
	wrByte1(2) <= wr1 and not lben(2);
	wrByte1(3) <= wr1 and not lben(3);	
	
	rd0 <= '1' when (ctrlState = READY) and (lw_rn = '0') and (addrValid0 = '1') else '0';
	rd1 <= '1' when (ctrlState = READY) and (lw_rn = '0') and (addrValid1 = '1') else '0';
	
	--dummyData <= '1' when (ctrlState = WAIT_BLAST) else '0';
	
	ld_dir <= '1' when   (ctrlState /= IDLE) and (lw_rn = '0') else '0';
	--ld_dir <= not lw_rn;
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Burst error counter
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	p_burst_cnt : process(lclk, lresetn)
		
	begin
		if lresetn = '0' then
			tmpcnt0 <= (others => '0');
		elsif rising_edge(lclk) then
			if (burstCntRst = '1') then
				tmpcnt0 <= (others => '0');		           
			elsif (burstCntEn = '1') then 
				tmpcnt0 <= tmpcnt0 + 1;
			end if;
		end if;
	end process;
	
	burstCnt <= std_logic_vector(tmpcnt0);
end rtl;
