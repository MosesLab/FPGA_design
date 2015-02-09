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
-- Module:		emac_init
-- Parent:		emac_plx
-- Description: Initializes the V5 tri-mode EMAC; and sets PHY address
--********************************************************************************
-- Date			Author	Modifications
----------------------------------------------------------------------------------
-- 2008-03-11	MF		Created
-- 2008-03-13	MF		Simulation corrections
-- 2008-03-14	MF		Correct phy reset, was always held low. drive power down 
--							pins high
-- 2008-03-14	MF		Add generic for loopback test
-- 2008-03-19	MF		Remove cfgAddr from 2nd SM
-- 2008-05-01	MF		Add local bus interface to host interface
-- 2008-05-05	MF		Change reset procedure
--********************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ctiUtil.all;
--use work.ctiSim.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
entity emac_init is
----------------------------------------------------------------------------------
	generic ( 	c_porCntBit : natural := 24; 
				c_lbtest : boolean := FALSE );
	 -- was 24
    port(
		clk							: in std_logic;
		lb_lresetn					: in std_logic;
		
		-- emac interface
		temac_rstni					: in std_logic;
		temac_rsto                  : out std_logic;

		-- Host Interface
		host_clk                    : out std_logic;
		host_opcode                 : out std_logic_vector(1 downto 0);
		host_req                    : out std_logic;
		host_miim_sel               : out std_logic;
		host_addr                   : out std_logic_vector(9 downto 0);
		host_wr_data                : out std_logic_vector(31 downto 0);
		host_miim_rdy               : in  std_logic;
		host_rd_data                : in  std_logic_vector(31 downto 0);
		host_emac1_sel              : out std_logic;
		
		-- Local Bus interface to host interface
		busi_opcode                 : in std_logic_vector(1 downto 0);
		busi_req                    : in std_logic;
		busi_miim_sel               : in std_logic;
		busi_addr                   : in std_logic_vector(9 downto 0);
		busi_wr_data                : in std_logic_vector(31 downto 0);
		buso_miim_rdy               : out std_logic;
		buso_rd_data                : out  std_logic_vector(31 downto 0);
		busi_emac1_sel              : in std_logic;		
		
		-- National Phy strapping
		phy_strap					: out std_logic;
		phy_resetn					: out std_logic;
		phy_ad1_rxd0_A				: out std_logic;
		phy_ad2_rxd1_A				: out std_logic;
		phy_ad3_rxd0_B				: out std_logic;
		phy_ad4_rxd1_B				: out std_logic;
		phya_pwrDown				: out std_logic;
		phyb_pwrDown				: out std_logic;
		
		done						: out std_logic
      );
end emac_init;

----------------------------------------------------------------------------------
architecture rtl of emac_init is
----------------------------------------------------------------------------------

	type emacState is (	POR, 
						RESET,
						STRAP_HOLD,
						CFG_START,
						CFG_WRITE,
						CFG_DONE );
						
	signal state : emacState;
	signal nextState : emacState;
	
	signal porCnt : std_logic_vector(24 downto 0);
	signal porDone : std_logic;
	
	constant c_strapCntWidth : natural := 9;
	signal strapCnt : std_logic_vector(c_strapCntWidth-1 downto 0);
	signal strapCntEn : std_logic;
	
	constant c_2us : std_logic_vector(c_strapCntWidth-1 downto 0) := to_stdlogic(16#064#,c_strapCntWidth);
	constant c_6us : std_logic_vector(c_strapCntWidth-1 downto 0) := to_stdlogic(16#12C#,c_strapCntWidth);
	
	signal rstn : std_logic;
	--signal rstn_m : std_logic;	
	
	constant c_RomSize : natural := 17; --24;
	constant c_RomAddrWidth : natural := powerOfTwo(c_RomSize); -- powerOfTwo(x) >= 2^x
	constant c_maxAddr : std_logic_vector (c_RomAddrWidth-1 downto 0) := to_stdlogic(c_romSize-1,c_RomAddrWidth);
	
	type rom is array (0 to c_romSize-1) of std_logic_vector (43 downto 0);
	
	signal cfgRomOut : std_logic_vector (43 downto 0);
	signal cfgRomAddr : std_logic_vector (c_RomAddrWidth-1 downto 0);
	
	signal cfgRomAddrEn : std_logic;
	
	constant c_emac0Addr : std_logic_vector(47 downto 0) := x"0000A18B0C00";
	constant c_emac1Addr : std_logic_vector(47 downto 0) := x"0000B28B0C00";
	
	constant cfgRomArr : rom :=
			--	emac	mii		addr						data
			(	
				'0'	&	'0' &	to_stdlogic(16#200#,10) &	c_emac0Addr(31 downto 0), 
					-- "Receiver Configuration (Word 0)
					-- [31:0] EMAC#_PAUSEADDR[31:0] R/W
				'0'	&	'0' &	to_stdlogic(16#240#,10) &	x"1000" & c_emac0Addr(47 downto 32), 
					-- "Receiver Configuration (Word 1)   
					-- [15:0] EMAC#_PAUSEADDR[47:32] R/W
					-- [24:16] Reserved. –
					-- [25]  EMAC#_LTCHECK_DISABLE R/W
					-- [26] EMAC#_RXHALFDUPLEX R/W
					-- [27] EMAC#_RXVLAN_ENABLE R/W
					-- [28] EMAC#_RX_ENABLE R/W
					-- [29] EMAC#_RXINBANDFCS_ENABLE R/W
					-- [30] EMAC#_RXJUMBOFRAME_ENABLE R/W
					-- [31] EMAC#_RXRESET R/W
				'0'	&	'0' &	to_stdlogic(16#280#,10) &	x"10000000", 
					-- "Transmitter Configuration
					-- [24:0] Reserved. –
					-- [25] EMAC#_TXIFGADJUST_ENABLE R/W
					-- [26] EMAC#_TXHALFDUPLEX R/W
					-- [27] EMAC#_TXVLAN_ENABLE R/W
					-- [28] EMAC#_TX_ENABLE R/W
					-- [29] EMAC#_TXINBANDFCS_ENABLE R/W
					-- [30] EMAC#_TXJUMBOFRAME_ENABLE R/W
					-- [31] EMAC#_TXRESET R/W				
				'0'	&	'0' &	to_stdlogic(16#2C0#,10) &	x"00000000", 
					-- "Flow Control Configuration 
					-- [28:0] Reserved. –
					-- [29] EMAC#_RXFLOWCTRL_ENABLE R/W
					-- [30] EMAC#_TXFLOWCTRL_ENABLE R/W
					-- [31] Reserved.				
				'0'	&	'0' &	to_stdlogic(16#300#,10) &	x"44000000", 
					-- "Ethernet MAC Mode Configuration
					-- [23:0] Reserved. –
					-- [24] EMAC#_RX16BITCLIENT_ENABLE R
					-- [25] EMAC#_TX16BITCLIENT_ENABLE R
					-- [26] EMAC#_HOST_ENABLE R
					-- [27] EMAC#_1000BASEX_ENABLE R
					-- [28] EMAC#_SGMII_ENABLE R
					-- [29] EMAC#_RGMII_ENABLE R
					-- [31:30] {EMAC#_SPEED_MSB,EMAC#_SPEED_LSB} R/W				
--				'0'	&	'0' &	to_stdlogic(16#320#,10) &	x"00000000", 
					-- "RGMII/SGMII Configuration 
				'0'	&	'0' &	to_stdlogic(16#340#,10) &	x"00000054", 
					-- "Management Configuration
					--[5:0] Clock divide R/W		= x14
					--[6] EMAC#_MDIO_ENABLE R/W		= 1	
				'0'	&	'0' &	to_stdlogic(16#380#,10) &	c_emac0Addr(31 downto 0),  
					-- "Unicast Address (Word 0)
					--[31:0] EMAC#_UNICASTADDR[31:0] R/W				
				'0'	&	'0' &	to_stdlogic(16#384#,10) &	x"0000" & c_emac0Addr(47 downto 32), 
					-- "Unicast Address (Word 1)
					--[15:0] EMAC#_UNICASTADDR[47:32] R/W				
--				'0'	&	'0' &	to_stdlogic(16#388#,10) &	x"00000000", 
					-- "Additional Address Table Access (Word 0)	 	
--				'0'	&	'0' &	to_stdlogic(16#38C#,10) &	x"00000000", 
					-- "Additional Address Table Access (Word 1)								
				'0'	&	'0' &	to_stdlogic(16#390#,10) &	x"00000000", 
					--	"Address Filter Mode
					-- [30:0] Reserved. –
					-- [31] 1: When EMAC#_ADDRFILTERENABLE
					-- 		0: When EMAC#_ADDRFILTERENABLE
					
				'1'	&	'0' &	to_stdlogic(16#200#,10) &	c_emac1Addr(31 downto 0), 
				'1'	&	'0' &	to_stdlogic(16#240#,10) &	x"1000" & c_emac1Addr(47 downto 32), 
				'1'	&	'0' &	to_stdlogic(16#280#,10) &	x"10000000", 
				'1'	&	'0' &	to_stdlogic(16#2C0#,10) &	x"00000000", 
				'1'	&	'0' &	to_stdlogic(16#300#,10) &	x"44000000", 
				--'1'	&	'0' &	to_stdlogic(16#320#,10) &	x"00000000",
				--'1'	&	'0' &	to_stdlogic(16#340#,10) &	x"00000000",
				'1'	&	'0' &	to_stdlogic(16#380#,10) &	c_emac1Addr(31 downto 0),
				'1'	&	'0' &	to_stdlogic(16#384#,10) &	x"0000" & c_emac0Addr(47 downto 32),
				--'1'	&	'0' &	to_stdlogic(16#388#,10) &	x"00000000",				
				--'1'	&	'0' &	to_stdlogic(16#38C#,10) &	x"00000000",								
				'1'	&	'0' &	to_stdlogic(16#390#,10) &	x"00000000"					
			);  
			
			
		signal reqPulse : std_logic;
		signal busi_req_prev : std_logic;
		signal cfgDone : std_logic;
		signal tmpOpCode : std_logic_vector(1 downto 0);
		signal porInProgress : std_logic;
begin
	
g_lbrstY: if c_lbtest = TRUE generate
	rstn <= lb_lresetn;
end generate;

g_lbrstN: if c_lbtest = FALSE generate
	rstn <= temac_rstni;
end generate;
	
	phya_pwrDown <= '1';
	phyb_pwrDown <= '1';

	--The default function of this pin is POWER DOWN.
	--
	--POWER DOWN: The pin is an active low input in this mode 
	--and should be asserted low to put the device in a Power Down mode.
	--
	--INTERRUPT: The pin is an open drain output in this mode and will 
	--be asserted low when an interrupt condition occurs. Although the pin 
	--has a weak internal pull-up, some applications may require an external 
	--pull-up resister. Register access is required for the pin to be used as 
	--an interrupt mechanism. See Section 5.5.2 Interrupt Mechanism for 
	--more details on the interrupt mechanisms.	

	--p_synchrst : process(clk)
	--begin
	--	rstn_m <= lb_lresetn;
	--	rstn <= rst_n;
	--end if;

	-- state register
	p_stateReg : process(clk,rstn)
	begin
		if rstn = '0' then
			state <= POR;
		elsif rising_edge(clk) then
			state<= nextState;
		end if;
	end process;
	
g_lbSMY : if c_lbtest = TRUE generate
	-- next state logic
	p_SM : process(state, porDone, strapCnt, cfgRomAddr)
	begin
		case state is
			-------------------------------
			-- need to wait at least 167 ms for phy clk to stabilize.
			when POR =>
				if porDone = '1' then
					nextState <= RESET;
				else
					nextState <= POR;
				end if;
		
			-------------------------------
			-- hold the PHY in reset for 2 us 
			when  RESET =>
				if strapCnt >= c_2us then
					nextState <= STRAP_HOLD;
				else
					nextState <= RESET;
				end if;
				
			-------------------------------
			-- hold the strap values for 4 us
			when  STRAP_HOLD => 
				if strapCnt >= c_6us then
					nextState <= CFG_START;
				else
					nextState <= STRAP_HOLD;				
				end if;
			
			-------------------------------
			when  CFG_START =>
				nextState <= CFG_WRITE;					
				
			-------------------------------
			when  CFG_WRITE =>
				if cfgRomAddr <= c_maxAddr then
					nextState <= CFG_WRITE;					
				else
					nextState <= CFG_DONE;					
				end if;
						
			-------------------------------
			when  CFG_DONE =>
				nextState <= CFG_DONE;					
			
			-------------------------------
			when others =>
				nextState <= POR;		
				
		end case;
	end process;
	
	-- state machine outputs specific to lb test
	cfgRomAddrEn <= '1' when (state = CFG_START) or (state = CFG_WRITE) else '0';
end generate g_lbSMY;

	-- common state machine outputs
	phy_resetn <= '0' when (state = RESET) else '1';
	temac_rsto <= '1' when (state = RESET) else '0';
	strapCntEn <= '1' when (state = RESET) or (state = STRAP_HOLD) else '0';
	phy_strap <= '1' when (state = RESET) or (state = STRAP_HOLD) else '0';
	cfgDone <= '1' when (state = CFG_DONE) else '0';
	porInProgress <='1' when (state=POR) else '0';
	
	done <= cfgDone;

g_lbSMN : if c_lbtest = FALSE generate
	-- next state logic
	p_SM : process(state, 
	               porDone, 
	               strapCnt)
	               --cfgRomAddr)
	begin
		case state is
			-------------------------------
			-- need to wait at least 167 ms for phy clk to stabilize.
			when POR =>
				if porDone = '1' then
					nextState <= RESET;
				else
					nextState <= POR;
				end if;
		
			-------------------------------
			-- hold the PHY in reset for 2 us 
			when  RESET =>
				if strapCnt >= c_2us then
					nextState <= STRAP_HOLD;
				else
					nextState <= RESET;
				end if;
				
			-------------------------------
			-- hold the strap values for 4 us
			when  STRAP_HOLD => 
				if strapCnt >= c_6us then
					nextState <= CFG_DONE;
				else
					nextState <= STRAP_HOLD;				
				end if;
									
			-------------------------------
			when  CFG_DONE =>
				nextState <= CFG_DONE;					
			
			-------------------------------
			when others =>
				nextState <= POR;		
				
		end case;
	end process;
end generate g_lbSMN;
	
	-- strap values
	phy_ad1_rxd0_A <= '1';
	phy_ad2_rxd1_A <= '0';
	phy_ad3_rxd0_B <= '0';
	phy_ad4_rxd1_B <= '0';
	
	-- por counter
	p_porcnt : process(clk)
		variable v_cnt : unsigned(24 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			-- 0x0100_0000	
			if v_cnt(c_porCntBit) = '0' then
				v_cnt := v_cnt + 1;
			end if;
		end if;
		
		porCnt <= std_logic_vector(v_cnt);
	end process;
	
	porDone <= porCnt(c_porCntBit);
	
	-- strap counter
	p_strapCnt : process(clk)
		variable v_cnt : unsigned(8 downto 0);
	begin			
		if rising_edge(clk) then		
			if porInProgress = '1' then
				v_cnt := (others => '0');
			elsif strapCntEn = '1' then
				v_cnt := v_cnt + 1;
			end if;		
		end if;
		
		strapCnt <= std_logic_vector(v_cnt);
	end process;
	
g_lbcfgY : if c_lbtest = TRUE generate
	-- cfg rom counter
	p_cfgAddr : process (clk)                                                
		variable v_cnt : unsigned(c_RomAddrWidth-1 downto 0);
	begin  
		if rising_edge(clk) then		
			if porInProgress = '1' then		
				v_cnt := (others => '0');			
			elsif cfgRomAddrEn = '1' then
				v_cnt := v_cnt + 1;
			end if;
		end if;  
		
		cfgRomAddr <= std_logic_vector(v_cnt);
	end process; 	
	
	-- Instantiate cfg rom
	-- not really necessary to check maxaddr, already done in state machine
	p_cfgRom : process (clk)                                                
	begin                                                        
		if rising_edge(clk) then                              
			if  cfgRomAddr < c_maxAddr then
				cfgRomOut <= cfgRomArr( to_integer(unsigned(cfgRomAddr)) );   
			else
				cfgRomOut <= cfgRomArr( (c_romSize-1) );   
			end if;
		end if;
	end process; 
	
	-- drive host interface
	
	host_clk 		<= clk;
	host_emac1_sel	<= cfgRomOut(43) 			when cfgDone = '0' else busi_emac1_sel;
	host_miim_sel	<= cfgRomOut(42) 			when cfgDone = '0' else busi_miim_sel;
	host_req		<= cfgRomOut(42) 			when cfgDone = '0' else reqPulse;
	host_addr		<= cfgRomOut(41 downto 32) 	when cfgDone = '0' else busi_addr;
	host_wr_data	<= cfgRomOut(31 downto 0)  	when cfgDone = '0' else busi_wr_data;
	
	tmpOpCode <= "01" when state = CFG_WRITE else "11";
	host_opcode <= tmpOpCode					when cfgDone = '0' else busi_opcode;
	
	buso_miim_rdy <= host_miim_rdy;
	buso_rd_data  <= host_rd_data;	
	
	reqPulse <= busi_req and not busi_req_prev;
	
	process(clk)
	begin
		if rising_edge(clk) then
			busi_req_prev <= busi_req;
		end if;
	end process;
end generate g_lbcfgY;

end rtl;

