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

entity plx32BitSlave is
	port (
		lresetn			: in 	std_logic; 								-- Local bus reset
		lclk				: in 	std_logic;								-- Local clock input
		ld_dir			: out std_logic;								
		lben				: in 	std_logic_vector(3 downto 0);		-- Local Byte Enables
		adsn				: in 	std_logic;								-- Addres Strobe
		blastn			: in 	std_logic;								-- Burst last
		readyn			: out std_logic;								-- READY I/O
		lw_rn				: in 	std_logic;								-- Local Write/Read															
		ArbiterAck		: in 	std_logic;
		address_valid	: in 	std_logic
	);
end plx32BitSlave; 

architecture rtl of plx32BitSlave is

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Type Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	type core_FSM_states is (	IDLE, 
										ADDR_VALID,
										ADDR_INVALID,								
										READY, 
										WAIT_BLAST); 

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Signal Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	signal ctrlState, ctrlNextState : core_FSM_states;
	
begin
	
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
	
	-- State machine Next-State Logic
	p_SM : process(
					ctrlState, 
					address_valid,
					blastn,
					adsn, 
					ArbiterAck)
	begin
	-- execute on change in either "cntrlState" or "adsn"
	case ctrlState is
		when IDLE =>
			-- stay in IDLE state until ADS kicks off new cycle
			-- ADS detected, a new cycle has been launched. 
			if (adsn = '0' and ArbiterAck = '1')	then
				if (address_valid = '1')	then
					ctrlNextState <= ADDR_VALID;
				else
					ctrlNextState <= ADDR_INVALID;
				end if;
			else
				ctrlNextState <= IDLE;	
			end if;						                    	

		-- address state - assign and drive CE's.
		when ADDR_VALID => 										
			ctrlNextState <= READY;

		when ADDR_INVALID =>
			if (blastn = '0') then
				ctrlNextState  <= IDLE;
			else
				ctrlNextState <= WAIT_BLAST;
			end if;

		when READY =>		
			-- if Byte Last signal detected - normal end cycle
			if (blastn = '0') then
				ctrlNextState <= IDLE;
			else
				ctrlNextState <= READY;
			end if;   
			
		-- Wait for blast to be asserted, but make sure that writing doesn't occur
		when WAIT_BLAST =>			
			if (blastn = '0') then
				ctrlNextState <= IDLE;
			else	
				ctrlNextState <= WAIT_BLAST;            
			end if;   
		end case;
	
	end process;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- State machine outputs
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
	OUTPUT_LOGIC	:	process(ctrlState) is
	begin
		case (ctrlState) is
			when IDLE			=>
				ld_dir <= '0';
				readyn <= '1';
			when ADDR_VALID	=>
				ld_dir <= (not lw_rn); -- For read operations (lw_rn = '0'), ld_dir  = '1', making the Local Bus an output from the FPGA to the PLX9056
				readyn <= '1';
			when ADDR_INVALID	=>
				ld_dir <= (not lw_rn);
				readyn <= '1';
			when READY			=>
				ld_dir <= (not lw_rn);
				readyn <= '0';
			when WAIT_BLAST	=>
				ld_dir <= (not lw_rn);
				readyn <= '0';
		end case;
	end process;	

end rtl;
