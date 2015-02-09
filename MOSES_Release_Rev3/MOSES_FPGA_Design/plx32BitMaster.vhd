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
-- Module:		plx32BitMaster
-- Parent:		ref_design
-- Description: PLX C mode, 32 bit local bus master.
--********************************************************************************
-- Date			Who		Modifications
----------------------------------------------------------------------------------
-- 2007-12-18	MF		Created
-- 2008-01-14	MF		Add interrupt generation
-- 2008-01-20	MF		Add DMPAF signal, rely on it to indicate when there are
--							zero entries left in the write fifo.
-- 2008-01-22	MF		Ack'ing is performed when start goes low.
-- 2008-03-04	MF		Add ram width generic
-- 2008-04-02	MF		txfr ctrl input vector size
--						allow transfer of 2^6 = 64 DWORDs
--						txfrCnt used to 1 based, now 0 based.
--                  	Added backOffDly counter
-- 2008-06-02	MF		Add generic to disable PLX configuration.
--********************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ctiUtil.all;

----------------------------------------------------------------------------------
entity plx32BitMaster is
----------------------------------------------------------------------------------
    generic (	
		c_cfgRomSize : integer := 18;
		c_ramWidth : integer := 4;
		c_txfrCntWidth : natural :=6;
		c_enPlxCfg : boolean := TRUE
	);
	port (
		lclk				: in std_logic;							
		la					: out std_logic_vector(31 downto 2);		
		ld_dir			: out std_logic;
		lben				: out std_logic_vector(3 downto 0);		
		adsn				: out std_logic;							
		blastn			: out std_logic;							
		readyn			: in std_logic;						
		lw_rn				: out std_logic;							
		lresetn			: in std_logic;
		ccsn				: out std_logic;
		dmpaf				: in std_logic;
		req				: out std_logic;
		ack				: in std_logic;
		backoff			: in std_logic;
		txfrCtrl			: in std_logic_vector(1 downto 0);
		txfrAddr			: in std_logic_vector(31 downto 0);
		txfrCnt			: in std_logic_vector(c_txfrCntWidth-1 downto 0);
		int				: out std_logic;
		cfgComplete		: out std_logic;
		ramAddr 			: out std_logic_vector(c_ramWidth-1 downto 0);
		ramWr 			: out std_logic_vector( 3 downto 0);
		ramEn 			: out std_logic;
		cfgRomPtr 		: out unsigned(4 downto 0);
      cfgRomDout 		: in std_logic_vector(47 downto 0);
		stateOut 		: out std_logic_vector(6 downto 0)
	);
end entity plx32BitMaster; 

----------------------------------------------------------------------------------
architecture rtl of plx32BitMaster is
----------------------------------------------------------------------------------

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Type Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	type masterStates is ( 	IDLE, 
							REQ_BUS, 
							ADDRESS, 
							TRANSFER, 
							CFG_COMPLETE, 
							COMPLETE, 
							WAIT_WR_FIFO_EMPTY,
							BACK_OFF
						); 
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--N/A
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Constant Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	constant PLX_WRITE : std_logic := '1';
	constant PLX_READ : std_logic := '0';	
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Signal Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	signal ctrlState, ctrlNextState : masterStates;
	
	signal op : std_logic;
	
	signal burstCntEn: std_logic;
	signal burstCntRst: std_logic;	
	signal burstCnt: std_logic_vector(c_txfrCntWidth-1 downto 0);
	signal burstSz: std_logic_vector(c_txfrCntWidth-1 downto 0);
	signal burstCntOv : std_logic;
	
	signal lastBurst : std_logic;
	
--	signal startPrev : std_logic;
--	signal startLatch : std_logic;
--	signal startLatchSet : std_logic;
--	signal startLatchRst : std_logic;
	
	signal curAddr : std_logic_vector(31 downto 2);	
	signal curAddrLoad : std_logic;
	signal curAddrInc : std_logic;
	
	signal nextAddr : std_logic_vector(31 downto 2);		
	
	signal ramWrAddr : std_logic_vector(c_ramWidth-1 downto 0);
	signal ramRdAddr : std_logic_vector(c_ramWidth-1 downto 0);
	--signal ramDout : std_logic_vector(31 downto 0);
	
	signal transfering : std_logic;	
	
	signal cfgPending : std_logic;
	--signal cfgComplete : std_logic;	
	signal cfgRomPtrCur : unsigned(4 downto 0);	
	
	signal burstEn : std_logic;
	
	--signal intAck : std_logic;
	
	signal cfgPendingClr : std_logic;
	
	signal backOffDly : std_logic_vector(3 downto 0);
	signal backOffDlyEn : std_logic;
	
begin --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	stateOut(0) <= '1' when (ctrlState = IDLE) else '0';
	stateOut(1) <= '1' when (ctrlState = REQ_BUS) else '0'; 
	stateOut(2) <= '1' when (ctrlState = ADDRESS) else '0'; 
	stateOut(3) <= '1' when (ctrlState = TRANSFER) else '0'; 
	stateOut(4) <= '1' when (ctrlState = CFG_COMPLETE) else '0'; 
	stateOut(5) <= '1' when (ctrlState = WAIT_WR_FIFO_EMPTY) else '0'; 
	stateOut(6) <= '1' when (ctrlState = COMPLETE) else '0'; 

	
	
--	intAck <= txfrCtrl(8);
	
	lw_rn <= op;
	--op <= dmCtrl(1);
	--la <= curAddr;
	--lben <= x"0"; -- enable all bytes, always
	
	--ld_out	<= cfgRomDout(31 downto 0) 					when cfgPending = '1' else ramDout;
	lben	<= cfgRomDout(35 downto 32) 				when cfgPending = '1' else x"0";
	la		<= x"00000" & cfgRomDout(47 downto 38) 		when cfgPending = '1' else curAddr;
	op		<= '1' 										when cfgPending = '1' else txfrCtrl(1);
	burstSz <= std_logic_vector(to_unsigned(c_cfgRomSize,c_txfrCntWidth)) when cfgPending = '1' else txfrCnt;
	burstEn <= '0' 										when cfgPending = '1' else '1'; 
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Configuration ROM
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

g_cfgY : if c_enPlxCfg = TRUE generate

	cfgComplete <= not cfgPending;

	p_cfgPend : process(lclk, lresetn )
	begin
		if lresetn = '0' then
			cfgPending <= '1';
		elsif rising_edge(lclk) then
			if(cfgPendingClr = '1') then
				cfgPending <= '0';
			end if;
		end if;
	end process p_cfgPend;	

	cfgRomPtr <= (cfgRomPtrCur+1) when (transfering = '1') else cfgRomPtrCur;
end generate g_cfgY;

g_cfgN : if c_enPlxCfg = FALSE generate
	cfgComplete <= '1';
	cfgPending <= '0';
	cfgRomPtr <= (others => '0');
end generate g_cfgN;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Block Ram
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- RAM write occurs during a read operation
	ramAddr <= ramWrAddr when (op = '0') else ramRdAddr;
	ramEn <= '1';
	ramWrAddr <= curAddr(c_ramWidth-1+2 downto 2);
	ramRdAddr <= nextAddr(c_ramWidth-1+2 downto 2) when (transfering = '1') else curAddr(c_ramWidth-1+2 downto 2);
	
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
	end process p_StateReg;	
	
	-- State machine
	p_SM : process(	ctrlState, 
					txfrCtrl(0),
					--burstCnt, 
					--burstSz,
					ack,
					backoff,
					readyn,
					cfgPending,
					burstEn,
					--intAck,
					op,
					dmpaf,
					lastBurst,
					backOffDly)
	begin
		CASE ctrlState IS
			WHEN IDLE =>
				if (txfrCtrl(0) = '1') or (cfgPending = '1') then
					ctrlNextState <= REQ_BUS;
				else
					ctrlNextState <= IDLE;	
				end if;						                    	
		
			WHEN REQ_BUS => 										
				if (ack = '1') then
					ctrlNextState <= ADDRESS;
				else
					ctrlNextState <= REQ_BUS;
				end if;
			
			-- set adsn, and inc count to 1
			WHEN ADDRESS =>
				ctrlNextState <= TRANSFER;
				
			when TRANSFER =>
				if ((readyn = '0') and (lastBurst='1')) then
				
					if cfgPending = '1' then
						ctrlNextState <= CFG_COMPLETE;
					else
						if op = '1' then
          					ctrlNextState <= WAIT_WR_FIFO_EMPTY;						    					    
						else
                    		ctrlNextState <= COMPLETE;
              			end if;
					end if;
				else
					if ( backoff = '1' ) then
						ctrlNextState <= BACK_OFF;											
					else
						if burstEn = '0' and readyn = '0' then
							ctrlNextState <= ADDRESS;						
						else
							ctrlNextState <= TRANSFER;												
						end if;
					end if;
				end if;
			
			when WAIT_WR_FIFO_EMPTY =>
				if dmpaf = '1' then
				    ctrlNextState <= WAIT_WR_FIFO_EMPTY;
				else
				    ctrlNextState <= COMPLETE;
				end if;
			
			when COMPLETE =>
				if txfrCtrl(0) = '0' then
					ctrlNextState <= IDLE;
				else
					ctrlNextState <= COMPLETE;
				end if;
				
			when CFG_COMPLETE =>
				ctrlNextState <= IDLE;
				
			when BACK_OFF =>
				if (backOffDly < x"F") then
					ctrlNextState <= BACK_OFF;																
				else
					ctrlNextState <= REQ_BUS;	
				end if;
				
			when others =>
				ctrlNextState <= IDLE;
		end CASE;
	end process p_SM; -- state machine evaluation

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- State machine outputs
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		

	-- Write = 1, direction to bus
	-- Read = 0, direction from bus
	-- when dir = 1, data FPGA => BUS
	
	blastn <= '0' when 	((ctrlState = ADDRESS) or (ctrlState = TRANSFER)) and 
						((lastBurst='1') or (burstEn = '0') ) else '1';	
						
--	startLatchRst <= '1' when (ctrlState = REQ_BUS) else '0';
	req <= '0' when (ctrlState = IDLE) or (ctrlState = COMPLETE) or  (ctrlState = BACK_OFF) else '1';

	curAddrLoad <= '1' when (ctrlState = IDLE) and (txfrCtrl(0) = '1') else '0';
	curAddrInc <= '1' when ((ctrlState = TRANSFER) AND readyn='0') else '0';
	transfering <= curAddrInc;
	
	adsn <= '0' 	when (ctrlState =  ADDRESS) else '1';													
	burstCntEn <= '1' when 	((ctrlState = TRANSFER) AND readyn='0') else '0';			
	burstCntRst <= '1' when 	(ctrlState = IDLE) else '0';				
	
	ramWr <= x"F" when ((ctrlState = TRANSFER) AND (readyn='0')) and  (op ='0') else x"0";
	
	ld_dir <= '1' when   ((ctrlState = ADDRESS) or (ctrlState = TRANSFER)) and (op = '1') else '0';
	
	cfgPendingClr <= '1' when   (ctrlState = CFG_COMPLETE)  else '0';
	
	ccsn <= '0' when ((ctrlState = ADDRESS) or (ctrlState = TRANSFER)) and (cfgPending = '1') else '1';
	
	int <= '1' when (ctrlState = COMPLETE) else '0';
	
	backOffDlyEn <= '1' when (ctrlState = BACK_OFF) else '0';
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Address counter
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	p_curAddr : process(lclk, lresetn)
		variable v_cnt0 : unsigned(31 downto 2);
	begin
		if lresetn = '0' then
			v_cnt0 := (others => '0');
			cfgRomPtrCur <= (others => '0');
		elsif rising_edge(lclk) then
			if (curAddrLoad = '1') then
				v_cnt0 := unsigned( txfrAddr(31 downto 2) );
				cfgRomPtrCur <= (others => '0');
			elsif (curAddrInc = '1') then 
				v_cnt0 := v_cnt0 + 1;
				cfgRomPtrCur <= cfgRomPtrCur + 1;
			end if;
		end if;
		
		curAddr <= std_logic_vector(v_cnt0);
		nextAddr <= std_logic_vector(v_cnt0+1);
	end process p_curAddr;
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Burst counter
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	p_burst_cnt : process(lclk, lresetn)
		variable v_cnt1 : unsigned(c_txfrCntWidth downto 0);
	begin
		if (lresetn = '0') then
			v_cnt1 := (others => '0');
		elsif rising_edge(lclk) then
		    if (burstCntRst = '1') then
                v_cnt1 := (others=>'0');	           
			elsif (burstCntEn = '1') then 
				v_cnt1 := v_cnt1 + 1;
			end if;
		end if;
		
		burstCnt <= std_logic_vector(v_cnt1(c_txfrCntWidth-1 downto 0));
		burstCntOv <= std_logic(v_cnt1(c_txfrCntWidth));
	end process p_burst_cnt;
	
	lastBurst <= '1' when ( (burstCnt >= burstSz) or (burstCntOv='1') ) else '0';
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Backoff Counter
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	p_backOffDly : process(lclk, lresetn)
		variable v_cnt2 : unsigned(3 downto 0);
	begin
		if (lresetn = '0') then
			v_cnt2 := (others => '0');
		elsif rising_edge(lclk) then
		    if (ack = '1') then
                v_cnt2 := (others=>'0');	           
			elsif (backOffDlyEn = '1') then 
				v_cnt2 := v_cnt2 + 1;
			end if;
		end if;
		
		backOffDly <= std_logic_vector(v_cnt2);
	end process p_backOffDly;

	
end architecture rtl;
