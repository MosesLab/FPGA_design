
-- VHDL Instantiation Created from source file v5_emac_v1_3_block.vhd -- 13:09:25 03/11/2008
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
	COMPONENT v5_emac_v1_3_block
	PORT(
		TX_CLIENT_CLK_0 : IN std_logic;
		RX_CLIENT_CLK_0 : IN std_logic;
		TX_PHY_CLK_0 : IN std_logic;
		CLIENTEMAC0TXD : IN std_logic_vector(7 downto 0);
		CLIENTEMAC0TXDVLD : IN std_logic;
		CLIENTEMAC0TXFIRSTBYTE : IN std_logic;
		CLIENTEMAC0TXUNDERRUN : IN std_logic;
		CLIENTEMAC0TXIFGDELAY : IN std_logic_vector(7 downto 0);
		CLIENTEMAC0PAUSEREQ : IN std_logic;
		CLIENTEMAC0PAUSEVAL : IN std_logic_vector(15 downto 0);
		MII_COL_0 : IN std_logic;
		MII_CRS_0 : IN std_logic;
		MII_TX_CLK_0 : IN std_logic;
		MII_RXD_0 : IN std_logic_vector(3 downto 0);
		MII_RX_DV_0 : IN std_logic;
		MII_RX_ER_0 : IN std_logic;
		MII_RX_CLK_0 : IN std_logic;
		MDIO_0_I : IN std_logic;
		TX_CLIENT_CLK_1 : IN std_logic;
		RX_CLIENT_CLK_1 : IN std_logic;
		TX_PHY_CLK_1 : IN std_logic;
		CLIENTEMAC1TXD : IN std_logic_vector(7 downto 0);
		CLIENTEMAC1TXDVLD : IN std_logic;
		CLIENTEMAC1TXFIRSTBYTE : IN std_logic;
		CLIENTEMAC1TXUNDERRUN : IN std_logic;
		CLIENTEMAC1TXIFGDELAY : IN std_logic_vector(7 downto 0);
		CLIENTEMAC1PAUSEREQ : IN std_logic;
		CLIENTEMAC1PAUSEVAL : IN std_logic_vector(15 downto 0);
		MII_COL_1 : IN std_logic;
		MII_CRS_1 : IN std_logic;
		MII_TX_CLK_1 : IN std_logic;
		MII_RXD_1 : IN std_logic_vector(3 downto 0);
		MII_RX_DV_1 : IN std_logic;
		MII_RX_ER_1 : IN std_logic;
		MII_RX_CLK_1 : IN std_logic;
		HOSTCLK : IN std_logic;
		HOSTOPCODE : IN std_logic_vector(1 downto 0);
		HOSTREQ : IN std_logic;
		HOSTMIIMSEL : IN std_logic;
		HOSTADDR : IN std_logic_vector(9 downto 0);
		HOSTWRDATA : IN std_logic_vector(31 downto 0);
		HOSTEMAC1SEL : IN std_logic;
		RESET : IN std_logic;          
		TX_CLIENT_CLK_OUT_0 : OUT std_logic;
		RX_CLIENT_CLK_OUT_0 : OUT std_logic;
		TX_PHY_CLK_OUT_0 : OUT std_logic;
		EMAC0CLIENTRXD : OUT std_logic_vector(7 downto 0);
		EMAC0CLIENTRXDVLD : OUT std_logic;
		EMAC0CLIENTRXGOODFRAME : OUT std_logic;
		EMAC0CLIENTRXBADFRAME : OUT std_logic;
		EMAC0CLIENTRXFRAMEDROP : OUT std_logic;
		EMAC0CLIENTRXSTATS : OUT std_logic_vector(6 downto 0);
		EMAC0CLIENTRXSTATSVLD : OUT std_logic;
		EMAC0CLIENTRXSTATSBYTEVLD : OUT std_logic;
		EMAC0CLIENTTXACK : OUT std_logic;
		EMAC0CLIENTTXCOLLISION : OUT std_logic;
		EMAC0CLIENTTXRETRANSMIT : OUT std_logic;
		EMAC0CLIENTTXSTATS : OUT std_logic;
		EMAC0CLIENTTXSTATSVLD : OUT std_logic;
		EMAC0CLIENTTXSTATSBYTEVLD : OUT std_logic;
		MII_TXD_0 : OUT std_logic_vector(3 downto 0);
		MII_TX_EN_0 : OUT std_logic;
		MII_TX_ER_0 : OUT std_logic;
		MDC_0 : OUT std_logic;
		MDIO_0_O : OUT std_logic;
		MDIO_0_T : OUT std_logic;
		TX_CLIENT_CLK_OUT_1 : OUT std_logic;
		RX_CLIENT_CLK_OUT_1 : OUT std_logic;
		TX_PHY_CLK_OUT_1 : OUT std_logic;
		EMAC1CLIENTRXD : OUT std_logic_vector(7 downto 0);
		EMAC1CLIENTRXDVLD : OUT std_logic;
		EMAC1CLIENTRXGOODFRAME : OUT std_logic;
		EMAC1CLIENTRXBADFRAME : OUT std_logic;
		EMAC1CLIENTRXFRAMEDROP : OUT std_logic;
		EMAC1CLIENTRXSTATS : OUT std_logic_vector(6 downto 0);
		EMAC1CLIENTRXSTATSVLD : OUT std_logic;
		EMAC1CLIENTRXSTATSBYTEVLD : OUT std_logic;
		EMAC1CLIENTTXACK : OUT std_logic;
		EMAC1CLIENTTXCOLLISION : OUT std_logic;
		EMAC1CLIENTTXRETRANSMIT : OUT std_logic;
		EMAC1CLIENTTXSTATS : OUT std_logic;
		EMAC1CLIENTTXSTATSVLD : OUT std_logic;
		EMAC1CLIENTTXSTATSBYTEVLD : OUT std_logic;
		MII_TXD_1 : OUT std_logic_vector(3 downto 0);
		MII_TX_EN_1 : OUT std_logic;
		MII_TX_ER_1 : OUT std_logic;
		HOSTMIIMRDY : OUT std_logic;
		HOSTRDDATA : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

-- COMP_TAG_END ------ End COMPONENT Declaration ------------
-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
	Inst_v5_emac_v1_3_block: v5_emac_v1_3_block PORT MAP(
		TX_CLIENT_CLK_OUT_0 => ,
		RX_CLIENT_CLK_OUT_0 => ,
		TX_PHY_CLK_OUT_0 => ,
		TX_CLIENT_CLK_0 => ,
		RX_CLIENT_CLK_0 => ,
		TX_PHY_CLK_0 => ,
		EMAC0CLIENTRXD => ,
		EMAC0CLIENTRXDVLD => ,
		EMAC0CLIENTRXGOODFRAME => ,
		EMAC0CLIENTRXBADFRAME => ,
		EMAC0CLIENTRXFRAMEDROP => ,
		EMAC0CLIENTRXSTATS => ,
		EMAC0CLIENTRXSTATSVLD => ,
		EMAC0CLIENTRXSTATSBYTEVLD => ,
		CLIENTEMAC0TXD => ,
		CLIENTEMAC0TXDVLD => ,
		EMAC0CLIENTTXACK => ,
		CLIENTEMAC0TXFIRSTBYTE => ,
		CLIENTEMAC0TXUNDERRUN => ,
		EMAC0CLIENTTXCOLLISION => ,
		EMAC0CLIENTTXRETRANSMIT => ,
		CLIENTEMAC0TXIFGDELAY => ,
		EMAC0CLIENTTXSTATS => ,
		EMAC0CLIENTTXSTATSVLD => ,
		EMAC0CLIENTTXSTATSBYTEVLD => ,
		CLIENTEMAC0PAUSEREQ => ,
		CLIENTEMAC0PAUSEVAL => ,
		MII_COL_0 => ,
		MII_CRS_0 => ,
		MII_TXD_0 => ,
		MII_TX_EN_0 => ,
		MII_TX_ER_0 => ,
		MII_TX_CLK_0 => ,
		MII_RXD_0 => ,
		MII_RX_DV_0 => ,
		MII_RX_ER_0 => ,
		MII_RX_CLK_0 => ,
		MDC_0 => ,
		MDIO_0_I => ,
		MDIO_0_O => ,
		MDIO_0_T => ,
		TX_CLIENT_CLK_OUT_1 => ,
		RX_CLIENT_CLK_OUT_1 => ,
		TX_PHY_CLK_OUT_1 => ,
		TX_CLIENT_CLK_1 => ,
		RX_CLIENT_CLK_1 => ,
		TX_PHY_CLK_1 => ,
		EMAC1CLIENTRXD => ,
		EMAC1CLIENTRXDVLD => ,
		EMAC1CLIENTRXGOODFRAME => ,
		EMAC1CLIENTRXBADFRAME => ,
		EMAC1CLIENTRXFRAMEDROP => ,
		EMAC1CLIENTRXSTATS => ,
		EMAC1CLIENTRXSTATSVLD => ,
		EMAC1CLIENTRXSTATSBYTEVLD => ,
		CLIENTEMAC1TXD => ,
		CLIENTEMAC1TXDVLD => ,
		EMAC1CLIENTTXACK => ,
		CLIENTEMAC1TXFIRSTBYTE => ,
		CLIENTEMAC1TXUNDERRUN => ,
		EMAC1CLIENTTXCOLLISION => ,
		EMAC1CLIENTTXRETRANSMIT => ,
		CLIENTEMAC1TXIFGDELAY => ,
		EMAC1CLIENTTXSTATS => ,
		EMAC1CLIENTTXSTATSVLD => ,
		EMAC1CLIENTTXSTATSBYTEVLD => ,
		CLIENTEMAC1PAUSEREQ => ,
		CLIENTEMAC1PAUSEVAL => ,
		MII_COL_1 => ,
		MII_CRS_1 => ,
		MII_TXD_1 => ,
		MII_TX_EN_1 => ,
		MII_TX_ER_1 => ,
		MII_TX_CLK_1 => ,
		MII_RXD_1 => ,
		MII_RX_DV_1 => ,
		MII_RX_ER_1 => ,
		MII_RX_CLK_1 => ,
		HOSTCLK => ,
		HOSTOPCODE => ,
		HOSTREQ => ,
		HOSTMIIMSEL => ,
		HOSTADDR => ,
		HOSTWRDATA => ,
		HOSTMIIMRDY => ,
		HOSTRDDATA => ,
		HOSTEMAC1SEL => ,
		RESET => 
	);



-- INST_TAG_END ------ End INSTANTIATION Template ------------

-- You must compile the wrapper file v5_emac_v1_3_block.vhd when simulating
-- the core, v5_emac_v1_3_block. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".
