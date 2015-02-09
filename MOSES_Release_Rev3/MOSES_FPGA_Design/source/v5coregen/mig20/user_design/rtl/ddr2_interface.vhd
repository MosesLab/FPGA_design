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
-- Module:		ddr2_interface
-- Parent:		
-- Description: Bridges PLX local bus memory locations to mig controllers 
--				 application interface
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-02-29	MF		Created
-- 2008-03-03	MF		simulation corrections
-- 2008-03-06	MF		register entire data path to/from mig
--********************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

-- burstSz = 0; is a transfer of 1

----------------------------------------------------------------------------------
entity ddr2_interface is
----------------------------------------------------------------------------------
  generic (
    --BANK_WIDTH    : integer := 2;
    --COL_WIDTH     : integer := 10;
    --DM_WIDTH      : integer := 4;
    --DQ_WIDTH      : integer := 32;
    --ROW_WIDTH     : integer := 13;
    APPDATA_WIDTH : integer := 64;
    --ECC_ENABLE    : integer := 0;
    BURST_LEN     : integer := 4;
	
	DP_A_WIDTH		: integer := 6;
	MAX_BURST		: integer := 16;
	BURST_SZ_WIDTH	: integer := 4
    );
  port (
	-- FreeForm interface
	clkPlx			: in std_logic;
	txfrCtrlA		: in std_logic_vector(1 downto 0);
	txfrCmdA		: in std_logic_vector(2 downto 0);
	txfrSzA			: in std_logic_vector(BURST_SZ_WIDTH-1 downto 0);
	txfrAddrA		: in std_logic_vector(30 downto 0);
	txfrStatusA		: out std_logic_vector(3 downto 0);
	
	dpEnA			: in std_logic;
	dpWenA			: in std_logic_vector(3 downto 0);
	dpAddrA			: in std_logic_vector(DP_A_WIDTH-1 downto 0);
	dpDinA			: in std_logic_vector(31 downto 0);
	dpDoutA			: out std_logic_vector(31 downto 0);
	
	-- Application interface
    clk0              : in  std_logic;
    rst0              : in  std_logic;
    app_af_afull      : in  std_logic;
    app_wdf_afull     : in  std_logic;
    rd_data_valid     : in  std_logic;
    rd_data_fifo_out  : in  std_logic_vector(APPDATA_WIDTH-1 downto 0);
    phy_init_done     : in  std_logic;
    app_af_wren       : out std_logic;
    app_af_cmd        : out std_logic_vector(2 downto 0);
    app_af_addr       : out std_logic_vector(30 downto 0);
    app_wdf_wren      : out std_logic;
    app_wdf_data      : out std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data : out std_logic_vector((APPDATA_WIDTH/8)-1 downto 0)
    );
end entity ddr2_interface;

----------------------------------------------------------------------------------
architecture rtl of ddr2_interface is
----------------------------------------------------------------------------------

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Constant Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	constant DP_B_WIDTH : integer := DP_A_WIDTH - 1;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Component Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	component dp_32_64
	port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(31 downto 0);
		addra: IN std_logic_VECTOR(5 downto 0);
		ena: IN std_logic;
		wea: IN std_logic_VECTOR(3 downto 0);
		douta: OUT std_logic_VECTOR(31 downto 0);
		clkb: IN std_logic;
		dinb: IN std_logic_VECTOR(63 downto 0);
		addrb: IN std_logic_VECTOR(4 downto 0);
		web: IN std_logic_VECTOR(7 downto 0);
		doutb: OUT std_logic_VECTOR(63 downto 0));
	end component;

	component fifo_42x16
	port (
		din: IN std_logic_VECTOR(41 downto 0);
		rd_clk: IN std_logic;
		rd_en: IN std_logic;
		rst: IN std_logic;
		wr_clk: IN std_logic;
		wr_en: IN std_logic;
		dout: OUT std_logic_VECTOR(41 downto 0);
		empty: OUT std_logic;
		full: OUT std_logic;
		valid: OUT std_logic);
	end component;

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Type Declarations
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	type STATE_TYPE is (	IDLE, 
							LOAD_CMD, 
							DELAY, 
							WRBURST_0, 
							WRBURST_1,
							RDBURST_0, 
							RDBURST_1,
							DONE );
	
	-- Signal Declaration
	
	signal state				:  STATE_TYPE;
	signal nextState			:  STATE_TYPE;	

	-- PLX Domain
	signal txfrPushA			: std_logic;
	signal fifoInA				: std_logic_VECTOR(41 downto 0);	
	signal fifoFullA			: std_logic;	
	signal txfrCtrlA_r			: std_logic_vector(1 downto 0);	
	
	-- DDR2 app domain
	signal dpAddrB				: std_logic_vector(DP_B_WIDTH-1 downto 0);
	signal dpWeB				: std_logic_vector(7 downto 0);
	signal txfrCmdB				: std_logic_vector(2 downto 0);
	signal txfrSzB				: std_logic_vector(BURST_SZ_WIDTH-1 downto 0);
	signal txfrAddrB			: std_logic_vector(30 downto 0);
	signal txfrValidB 			: std_logic;
	signal txfrPopB				: std_logic;
	signal fifoOutB				: std_logic_VECTOR(41 downto 0);
	signal fifoEmptyB			: std_logic;
	signal ackB					: std_logic;
	
	-- state machine control
	signal op					: std_logic;
	signal cmd       			: std_logic_vector(2 downto 0);
	signal load 				: std_logic;
	signal complete				: std_logic;
	signal busy					: std_logic;
	signal addrInc				: std_logic;
	signal addrIncRd			: std_logic;
	signal addrIncWr			: std_logic;	
	signal cntInc				: std_logic;
	signal cntIncRd				: std_logic;
	signal cntIncWr				: std_logic;	
	signal dpInc : std_logic;
	signal dpIncRd : std_logic;
	signal dpIncWr : std_logic;
		signal dpPreInc : std_logic;
	signal burstSz				: std_logic_vector(BURST_SZ_WIDTH-1 downto 0);
	signal dpAddrBMax			: std_logic_vector(DP_B_WIDTH-1 downto 0);
	signal burstCnt 			: std_logic_vector(BURST_SZ_WIDTH-1 downto 0);
	
	-- meta stable regs
	signal ack_m				: std_logic;
	signal complete_m			: std_logic;
	signal busy_m 				: std_logic;
	signal phy_init_done_m		: std_logic;
	
	-- register state to output data path
    signal app_af_wrenD       :  std_logic;
    signal app_af_cmdD       :  std_logic_vector(2 downto 0);
    signal app_af_addrD       :  std_logic_vector(30 downto 0);
    signal app_wdf_wrenD      :  std_logic;
    signal app_wdf_dataD      :  std_logic_vector(APPDATA_WIDTH-1 downto 0);
    signal app_wdf_mask_dataD :  std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);	
	
	signal rst0_r      :   std_logic;
	signal app_af_afull_r      :   std_logic;
    signal app_wdf_afull_r     :   std_logic;
    signal rd_data_valid_r    :   std_logic;
    signal rd_data_fifo_out_r  :   std_logic_vector(APPDATA_WIDTH-1 downto 0);
    signal phy_init_done_r     :   std_logic;
begin

	-- register all data to & from mig
	-- this should ease timing between memory <-> fifo
	process(clk0)
	begin
		if (rising_edge(clk0)) then
--			if (rst0 = '1') then
--				app_af_wren       <= '0';
--				app_af_cmd        <= (others=>'0');
--				app_af_addr       <= (others=>'0');
--				app_wdf_wren      <= '0';
--				app_wdf_data      <= (others=>'0');
--				app_wdf_mask_data <= (others=>'0');	
--
--				app_af_afull_r      <= '0';
--				app_wdf_afull_r    <= '0';
--				rd_data_valid_r    <= '0';
--				rd_data_fifo_out_r  <= (others=>'0');
--				phy_init_done_r     <= '0';			
--			else
				app_af_wren       <= app_af_wrenD;
				app_af_cmd        <= app_af_cmdD;
				app_af_addr       <= app_af_addrD;
				app_wdf_wren      <= app_wdf_wrenD;
				app_wdf_data      <= app_wdf_dataD;
				app_wdf_mask_data <= app_wdf_mask_dataD;
				
				app_af_afull_r      <= app_af_afull;
				app_wdf_afull_r    <= app_wdf_afull;
				rd_data_valid_r    <= rd_data_valid;
				rd_data_fifo_out_r  <= rd_data_fifo_out;
				phy_init_done_r     <= phy_init_done;		
				rst0_r <= rst0;
			end if;
--		end if;
	end process;
	
	

	-- clock domain crossing: Controller > PLX
	process(clkPlx)
	begin
		if (rising_edge(clkPlx)) then
			complete_m <= complete;
			txfrStatusA(0) <= complete_m;	
			
			busy_m <= busy;			
			txfrStatusA(1) <= busy_m;
			
			phy_init_done_m <=phy_init_done_r;			
			txfrStatusA(2) <= phy_init_done_m;
			
			txfrCtrlA_r(0) <= txfrCtrlA(0);
		end if;
	end process;
	
	fifoInA <= "0000" & txfrAddrA & txfrSzA & txfrCmdA;
	txfrPushA <= txfrCtrlA(0) and not txfrCtrlA_r(0);	
	
	txfrStatusA(3) <= fifoFullA;
	
	-- Clock domain crossing: PLX > Controller
	-- 	fifo for address, count, and command

	
	process(clk0)
	begin
		if (rising_edge(clk0)) then
			ack_m <= txfrCtrlA(1);
			ackB <= ack_m;
		end if;
	end process;
	
	txfrCmdB <= fifoOutB(2 downto 0); 
	txfrSzB <= fifoOutB(6 downto 3); 
	txfrAddrB <= fifoOutB(37 downto 7); 

	u_fifo : fifo_42x16
	port map (
		rst => rst0_r,
		
		wr_clk => clkPlx,
		wr_en => txfrPushA,
		din => fifoInA,
		full => fifoFullA,
		
		rd_clk => clk0,
		rd_en => txfrPopB,
		dout => fifoOutB,
		empty => fifoEmptyB,
		valid => txfrValidB
		);
	-- full is write domain
	-- empty, valid in read domain

	-- Dual part memory for data
	u_dp : dp_32_64
	port map (
		clka => clkPlx,
		dina => dpDinA,
		addra => dpAddrA,
		ena => dpEnA,
		wea => dpWenA,
		douta => dpDoutA,
		
		clkb => clk0,
		dinb => rd_data_fifo_out_r,
		addrb => dpAddrB,
		web => dpWeB,
		doutb => app_wdf_dataD );
			
	-- State register				
	p_stateReg : process (clk0)
	begin
		if (rising_edge(clk0)) then
			if (rst0_r = '1') then
				state <= IDLE;
			else
				state <= nextState;
			end if;
		end if;
	end process;
  
	-- Next State Logic
	p_stateNext : process ( phy_init_done_r,
							txfrValidB,
							app_af_afull_r,
							app_wdf_afull_r,
							ackB, 
							state, 
							op, 
							dpAddrB, 
							dpAddrBMax,
							burstCnt,
							burstSz )
	begin
		case (state) is
			when IDLE =>
				if (phy_init_done_r = '1') and (txfrValidB = '1') and (ackB = '0') then
					nextState <= LOAD_CMD;
				else
					nextState <= IDLE;
				end if;
				
			when LOAD_CMD =>
				nextState <= DELAY;
				
			when DELAY =>
				if op = '1' then
					nextState <= RDBURST_0;
				else
            				if (app_af_afull_r = '0') and (app_wdf_afull_r = '0') then
					   nextState <= WRBURST_0;				
					else
					   nextState <= DELAY;				
					end if;
				end if;

			-- only increment the address and data counters if neither
			-- fifo is full
			when WRBURST_0 =>
					-- same condition as cntIncWr really
					if (app_af_afull_r = '0') and (app_wdf_afull_r = '0') then
						nextState <= WRBURST_1;				
					else
						nextState <= WRBURST_0;
					end if;			
		
			-- only increment data counter if neither fifo is full
			when WRBURST_1 =>		
				if (app_wdf_afull_r = '0') then
		    			if (burstCnt >= burstSz) then
            					nextState <= DONE;		
					else
					  nextState <= WRBURST_0;		
					end if;
				else
					nextState <= WRBURST_1;				
				end if;
		
			when RDBURST_0 =>
				if (burstCnt >= burstSz) then
					nextState <= RDBURST_1;
				else
					nextState <= RDBURST_0;				
				end if;
			
			when RDBURST_1 =>
				if (dpAddrB >= dpAddrBMax) then
					nextState <= DONE;	
				else
					nextState <= RDBURST_1;					
				end if;
				
			when DONE =>
				if ackB = '1' then
					nextState <= IDLE;
				else
					nextState <= DONE;				
				end if;
				
			when others =>
				nextState <= IDLE;
		end case;
	end process;
	
	-- State Machine Outputs
	load <= '1' when (state = LOAD_CMD) else '0';
	txfrPopB <= '1' when (state = LOAD_CMD) else '0';
	complete <= '1' when (state = DONE) else '0';
	busy <= '0' when (state = IDLE) or (state = DONE)   else '1';
		
	
	addrIncWr <= '1' when (state = WRBURST_0) and (app_af_afull_r = '0') and (app_wdf_afull_r = '0') else '0';
	cntIncWr   <= '1' when  ((state = WRBURST_1) and (app_wdf_afull_r = '0')) else '0';	
	dpPreInc <= '1' when (state = DELAY) and (app_af_afull_r = '0') and (app_wdf_afull_r = '0') and op='0' else '0';
	dpIncWr <= addrIncWr or cntIncWr or dpPreInc;
		
	addrIncRd <= '1' when (state = RDBURST_0) and (app_af_afull_r = '0') else '0'; 
	cntIncRd <= addrIncRd; 
	dpIncRd <= '1' when (((state = RDBURST_0)or(state = RDBURST_1)) and rd_data_valid_r='1') else '0';
		
	addrInc <= addrIncWr or addrIncRd;
	cntInc <= cntIncWr or cntIncRd;
	dpInc <= dpIncWr or dpIncRd;		

	app_wdf_wrenD <= addrIncWr or cntIncWr;
						 
	dpWeB <= x"FF" when dpIncRd = '1' else x"00";	
	app_af_wrenD  <= addrInc;
	--app_wdf_wren <= cntIncWr;
	
	op <= cmd(0);
	app_af_cmdD <= cmd;
	
		
	dpAddrBMax <= burstSz & '1';
	-- max address = 01,03,05,07,08,09,0B,0D,0F
	
	app_wdf_mask_dataD <= x"00";
	
	-- address and burst counters
	-- cmd and burst size registers
    p_cnt :	process(clk0)
		variable v_app_af_addr : unsigned(30 downto 0);
		variable v_dpAddrB : unsigned(DP_B_WIDTH-1 downto 0);
		variable v_burstCnt : unsigned(BURST_SZ_WIDTH-1 downto 0);
	begin
		if rising_edge(clk0) then
			if (rst0_r = '1') then
				cmd <= (others => '0');
				burstSz <= (others => '0');
				v_app_af_addr := (others => '0');
				v_dpAddrB := (others => '0');
				v_burstCnt := (others => '0');
			else
				if load = '1' then
					cmd <= txfrCmdB(2 downto 0);
					burstSz <= txfrSzB;					
				end if;
				
				if load = '1' then
					v_app_af_addr := unsigned(txfrAddrB);

				elsif addrInc = '1' then
					v_app_af_addr := v_app_af_addr + 4;
				end if;
				
				if load = '1' then
					v_burstCnt := (others => '0');
				elsif cntInc = '1' then 
					v_burstCnt := v_burstCnt + 1;
				end if;
				
			

				if load = '1' then
					v_dpAddrB := (others => '0');
				elsif dpInc = '1' then 
					v_dpAddrB := v_dpAddrB + 1;
				end if;				
				
			end if;
			
			app_af_addrD <= std_logic_vector(v_app_af_addr);
			dpAddrB <= std_logic_vector(v_dpAddrB);
			burstCnt <= std_logic_vector(v_burstCnt);
		end if;
		
		
	end process;

end architecture rtl;


