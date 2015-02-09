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
-- Project: 	FreeForm/PCI-104
-- Module:		eepromMaster
-- Parent:		N/A
-- Description: microwire eeprom master
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-03-26	MF		Created
-- 2008-03-27	MF		Initial simulation testing
--********************************************************************************

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use work.ctiUtil.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
entity eepromMaster is
----------------------------------------------------------------------------------
generic ( c_numReg : natural := 16 );
port ( 
	rstn	: in std_logic;
	clk		: in std_logic;
	-- micro wire interface
	sk		: out std_logic;
	cs		: out std_logic;
	sd		: inout std_logic;
	--sdi		: out std_logic;
	--sdo		: in std_logic;
	--tri		: out std_logic;   
	-- host interface
	mwStart	: in std_logic;
	mwCmd	: in std_logic_vector(1 downto 0);
	mwAddr	: in std_logic_vector(7 downto 0);
	mwRdCnt : in std_logic_vector(3 downto 0);
	mwDo	: in std_logic_vector(15 downto 0);
	mwDone	: out std_logic;	 
	mwDi	: out std_logic_vector(15 downto 0);

	regQ : out std_logic_matrix_16(c_numReg-1 downto 0);
	stateOut : out std_logic_vector(31 downto 0)
);
end entity eepromMaster;

----------------------------------------------------------------------------------
architecture rtl of eepromMaster is
----------------------------------------------------------------------------------

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	component shiftRegXX
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
	end component shiftRegXX;
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Signal / Constant Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	-- State type
	type mwState is (	
						IDLE,
						LOAD,
						SHIFT_OUT,
						SHIFT_IN,
						NEXT_READ,
						CHECK_STATUS,
						CS_HOLD_HIGH,
						CS_HOLD_LOW,
						DONE
					);
					
	signal state : mwState;
	signal nextState : mwState;
	
	-- MW op codes
	constant c_mwAddrEwds	: std_logic_vector(1 downto 0) := "00";
	constant c_mwAddrWral	: std_logic_vector(1 downto 0) := "01";
	constant c_mwAddrEral	: std_logic_vector(1 downto 0) := "10";
	constant c_mwAddrEwen	: std_logic_vector(1 downto 0) := "11";
	
	constant c_mwOp			: std_logic_vector(1 downto 0) := "00";
	constant c_mwOpWrite	: std_logic_vector(1 downto 0) := "01";
	constant c_mwOpRead		: std_logic_vector(1 downto 0) := "10";
	constant c_mwOpErase	: std_logic_vector(1 downto 0) := "11";
	
	-- output clock
	constant c_skCntWidth : natural := 6; -- 50 / 2^6 = 781.25 Khz
	signal sk_x : std_logic;
	signal skEn : std_logic;
	signal skPrev : std_logic;
	signal skFall : std_logic;
	signal skRise : std_logic;
	--signal skCnt : std_logic_vector(c_skCntWidth-1 downto 0);
	signal skCntRst : std_logic;
	
	-- output shift register
	constant c_shiftoWidth : natural := 27;  -- 16 data, 8 address, 2 cmd, 1 start bit
	constant c_shiftoCntWidth : natural := 5;
	constant c_shiftoSzWr : std_logic_vector(c_shiftoCntWidth-1 downto 0) := "11011";  -- 27 
	constant c_shiftoSzOthers : std_logic_vector(c_shiftoCntWidth-1 downto 0) := "01011"; -- 11
	
	signal shifto : std_logic_vector(c_shiftoWidth-1 downto 0);
	signal shiftoLd : std_logic;
	signal shiftoEn : std_logic;
	signal shiftoCnt : std_logic_vector(c_shiftoCntWidth-1 downto 0);
	signal shiftoCntMax : std_logic_vector(c_shiftoCntWidth-1 downto 0); 
	
	-- input shift register
	constant c_shiftiWidth : natural := 16;
	constant c_shiftiCntWidth : natural := 5; --4;
	constant shiftiCntMax : std_logic_vector(c_shiftiCntWidth-1 downto 0) := "10000"; 
	signal shifti : std_logic_vector(c_shiftiWidth-1 downto 0);
	signal shiftiLd : std_logic;
	signal shiftiEn : std_logic;
	signal shiftiCnt : std_logic_vector(c_shiftiCntWidth-1 downto 0);
	signal shiftiCntRst : std_logic;
	
	signal sdi		:  std_logic;
	signal sdo		:  std_logic;
	signal tri		:  std_logic;   
	
	-- register bank
	constant c_regSelWidth : natural := 4;
	

	signal regWr : std_logic;
	signal regCntEn : std_logic;
	signal regCntOv : std_logic;
	signal regCntRst : std_logic;
	
	signal regEn : std_logic_vector(c_numReg-1 downto 0);
	signal regCnt : std_logic_vector(c_regSelWidth-1 downto 0);
	
	signal rdBulkDone : std_logic;
----------------------------------------------------------------------------------	
begin -- architecture rtl
----------------------------------------------------------------------------------

	stateOut(0) <= '1' when state = IDLE else '0';
	stateOut(1) <= '1' when state = LOAD else '0';
	stateOut(2) <= '1' when state = SHIFT_OUT else '0';
	stateOut(3) <= '1' when state = SHIFT_IN else '0';
	stateOut(4) <= '1' when state = NEXT_READ else '0';
	stateOut(5) <= '1' when state = CHECK_STATUS else '0';
	stateOut(6) <= '1' when state = CS_HOLD_HIGH else '0';
	stateOut(7) <= '1' when state = CS_HOLD_LOW else '0';
	stateOut(8) <= '1' when state = DONE else '0';
	stateOut(31 downto 9) <= (others => '0');

	sd <= sdi when tri = '0' else 'Z';
	sdo <= sd;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- SK clock generator
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

	p_sk : process(clk)
		variable v_cnt : unsigned(c_skCntWidth-1 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if skCntRst = '1' then
				v_cnt := (others=>'0');
				skPrev <= '0';
			else
				v_cnt := v_cnt + 1;
				skPrev <= sk_x;
			end if;
		end if;
		
		--skCnt <= std_logic_vector(v_cnt);
		sk_x <= std_logic( v_cnt(c_skCntWidth-1) );	
	end process p_sk;
	
	sk <= sk_x and skEn;
	
	skFall <= not sk_x and skPrev;
	skRise <= sk_x and not skPrev;
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Output shift register
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
	
	shifto(26)			 <= '1';
	shifto(25 downto 24) <= mwCmd;
	shifto(23 downto 16) <= mwAddr;
	shifto(15 downto 0)  <= mwDo;
		
	u_shifto : shiftRegXX
	generic map ( c_width => 27 )
	port map (
		clk => clk,
		rstn => rstn,
		en => shiftoEn,
		load => shiftoLd,
		di => shifto,
		do => open,
		si => '0',
		so => sdi
	);
	
	-- output shift counter
	p_shiftoCnt : process (clk,rstn)
		variable v_cnt : unsigned(c_shiftoCntWidth-1 downto 0);
	begin
	   if rstn ='0' then 
		  v_cnt := (others => '0'); 
	   elsif rising_edge(clk) then  
	   	  if shiftoLd = '1' then 
			v_cnt := (others => '0'); 
		  elsif shiftoEn = '1' then 
			 v_cnt := v_cnt + 1;
		  end if; 
	   end if;
	   
	   shiftoCnt <= std_logic_vector(v_cnt);
	end process p_shiftoCnt;
	
	shiftoCntMax <=  c_shiftoSzWr when (mwCmd = c_mwOpWrite) or ((mwCmd = c_mwOp) and (mwAddr(7 downto 6) = c_mwAddrWral)) else 
						c_shiftoSzOthers;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- input shift register
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
	u_shifti : shiftRegXX
	generic map ( c_width => 16 )
	port map (
		clk => clk,
		rstn => rstn,
		en => shiftiEn,
		load => shiftiLd,
		di => x"0000",
		do => shifti,
		si => sdo,
		so => open
	);
	
	mwDi <= shifti;
	
	-- input shift counter
	p_shiftiCnt : process (clk,rstn)
		variable v_cnt : unsigned(c_shiftiCntWidth-1 downto 0);
	begin
	   if rstn ='0' then 
		  v_cnt := (others => '0'); 
	   elsif rising_edge(clk) then  
		  if shiftiCntRst = '1' then
			v_cnt := (others => '0'); 
		  elsif shiftiEn = '1' then 
			 v_cnt := v_cnt + 1;
		  end if; 
	   end if;
	   
	   shiftiCnt <= std_logic_vector(v_cnt);
	end process p_shiftiCnt;
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Control state machine
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	--
	-- State register
	--	
	p_smReg : process(clk,rstn)
	begin
		if rstn = '0' then
			state <= IDLE;
		elsif rising_edge(clk) then
			state <= nextState;
		end if;
	end process p_smReg;
	
	--
	-- Next state logic
	--	
	p_sm : process(	state, 
					mwStart,
					skRise,
					shiftoCnt,
					shiftoCntMax,
					mwCmd, 
					mwAddr,
					shiftiCnt,
					rdBulkDone,
					sdo					)
	begin
		case state is
			when IDLE =>
				if mwStart = '1' then
					nextState <= LOAD;
				else
					nextState <= IDLE;
				end if;

			-- hold the cs high in this state
			when LOAD =>
				if skRise = '1' then
					nextState <= SHIFT_OUT;
				else
					nextState <= LOAD;
				end if;
							
			when SHIFT_OUT =>
				if shiftoCnt < shiftoCntMax then
					nextState <= SHIFT_OUT;
				else
					if mwCmd = c_mwOpRead then
						nextState <= SHIFT_IN;					
					else
						nextState <= CS_HOLD_HIGH;					
					end if;
				end if; 
				
			when SHIFT_IN =>
				if shiftiCnt = shiftiCntMax then
					--if rdBulkDone ='0' then
					--	nextState <= SHIFT_IN;
					--else
						nextState <= NEXT_READ;	
					--end if;
				else
					nextState <= SHIFT_IN;					
				end if; 			
			
			when NEXT_READ =>
				if rdBulkDone ='0' then
					nextState <= SHIFT_IN;					
				else
					nextState <= CS_HOLD_HIGH;					
				end if;				
				
			-- hold chip select low.  if required, check the status
			-- this must last at least 250 ns.
			when CS_HOLD_HIGH =>
				if skRise = '1' then
					if ( (mwCmd = c_mwOpRead) or 
						 (mwCmd = c_mwOp and (mwAddr(7 downto 6) = c_mwAddrEwds or mwAddr(7 downto 6) = c_mwAddrEwen)) ) then
						nextState <= DONE;
					else
						nextState <= CS_HOLD_LOW;
					end if;
				else
						nextState <= CS_HOLD_HIGH;
				end if;
				
			when CS_HOLD_LOW =>
				if skRise = '1' then
						nextState <= CHECK_STATUS;
				else
						nextState <= CS_HOLD_LOW;
				end if;
				
			-- status should become available
			when CHECK_STATUS =>
				if skRise = '1' then
					if sdo = '1' then
						nextState <= DONE;
					else
						nextState <= CHECK_STATUS;
					end if;
				else
					nextState <= CHECK_STATUS;
				end if;
			
			-- wait for start to go low, and the next rising edge of sk.
			when DONE =>
				if mwStart = '0' and skRise = '1' then
					nextState <= IDLE;
				else
					nextState <= DONE;
				end if;				
			
			when others =>
				nextState <= IDLE;
		end case;
	end process p_sm;
	
	--
	-- State machine outputs logic
	--		
	cs <= '1' when 	state = LOAD or 
					state = SHIFT_OUT or 
					state = CS_HOLD_HIGH or 
					state = SHIFT_IN or
					state = NEXT_READ or
					state = CHECK_STATUS else '0';
	
	skCntRst <= '1' when state = IDLE else '0';
	skEn <= '1' when state = SHIFT_OUT or state = SHIFT_IN else '0';
	
	shiftoLd <= '1' when state = LOAD else '0';
	shiftoEn <= '1' when state = SHIFT_OUT and skFall = '1' else '0';
	
	shiftiLd <= '1' when state = LOAD else '0';
	shiftiEn <= '1' when state = SHIFT_IN and skFall = '1' else '0';
	
	shiftiCntRst <= '1' when  state = LOAD or state = NEXT_READ else '0';
	
	mwDone <= '1' when state = DONE else '0';
	
	tri <= '0' when state = LOAD or state = SHIFT_OUT else '1';

	
	regWr <= regCntEn; --'1' when state = NEXT_READ else '0';
	regCntEn <= '1' when (state = SHIFT_IN) and (shiftiCnt = shiftiCntMax) else '0';
	regCntRst <= '1' when state = LOAD else '0'; 
	
	rdBulkDone <= '1' when (regCnt > mwRdCnt) or regCntOv = '1' else '0';
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Register bank for continuous read
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	p_regCnt : process (clk,rstn)
		variable v_cnt : unsigned(c_regSelWidth downto 0);
	begin
		if rstn ='0' then 
			v_cnt := (others => '0'); 
		elsif rising_edge(clk) then  
			if regCntRst = '1' then
				v_cnt := (others=>'0');
			elsif regCntEn = '1' then 
				v_cnt := v_cnt + 1;
			end if; 
		end if;

		regCnt <= std_logic_vector(v_cnt(c_regSelWidth-1 downto 0) );
		regCntOv <= std_logic(v_cnt(c_regSelWidth) );
	end process p_regCnt;
	
	g_regs : for i in 0 to (c_numReg-1) generate
		regEn(i) <= '1' when  regCnt = to_stdlogic(i,c_regSelWidth) and regWr = '1' else '0';
	
		p_reg : process(rstn, clk)
			begin
			if (rstn = '0') then
				regQ(i) <= (others => '0');
			elsif rising_edge (clk) then 
				if regEn(i) = '1' then
					regQ(i) <= shifti;
				end if;
			end if;
		end process p_reg;
	end generate g_regs;

	
----------------------------------------------------------------------------------	
end architecture rtl;
----------------------------------------------------------------------------------	
