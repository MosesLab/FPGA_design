/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			miiTest.c
Description:	Program to test mii interface and management interface
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-05-05	MF		Created
2008-06-04	MF		Separate test() from main(), for use in one large test app
2008-08-25	MF		Try to reset PHY to cleanout FIFOs.
2008-11-07	MF		Remove printing of PHY registers, just verify IDs
2008-12-09	MF		Add transmit timeout
2009-01-12	MF		Add phy internal loopback test
'			'		Fixed debug messages
'			'		Add functions mdioRestartAutoNeg(), mdioResetPhy(), 
'			'			cleanRxBuffer(), emacTxEx()
2009-03-19	MF		Cleanup include file ordering
2012-02-13	MF		Removed unused vars
*******************************************************************************/

/*===============
  HEADERS
===============*/

#include "miiTest.h"
#define SLEEP_DELAY 10
#define VERIFY_MDIO
#define INTERNAL_LOOPBACK
#define EXTERNAL_LOOPBACK

/*===============
  GLOBALS
===============*/
REG_DESC temacRegSet[12] = 
	{
		{ 0x200, 0xA18B0C00, "Receiver Configuration {Word 0}"},
		{ 0x240, 0x10000000, "Receiver Configuration {Word 1}"},
		{ 0x280, 0x10000000, "Transmitter Configuration"},
		{ 0x2C0, 0x00000000, "Flow Control Configuration"},
		{ 0x300, 0x44000000, "Ethernet MAC Mode Configuration"},
		{ 0x320, 0x00000000, "RGMII/SGMII Configuration"},
		{ 0x340, 0x00000054, "Management Configuration"},
		{ 0x380, 0xA18B0C00, "Unicast Address {Word 0}"},
		{ 0x384, 0x00000000, "Unicast Address {Word 1}"},
		{ 0x388, 0x00000000, "Additional Address Table Access {Word 0}"},
		{ 0x38C, 0x00000000, "Additional Address Table Access {Word 1}"},
		{ 0x390, 0x00000000, "Address Filter Mode"}
	};	

#define NUM_PHY_REG_BASE 12
#define NUM_PHY_REG_PG0 10

REG_DESC phyRegBase[NUM_PHY_REG_BASE] =
	{
		{ 0x00, 0x000, "BMCR"},
		{ 0x01, 0x000, "BMSR"},
		{ 0x02, 0x000, "PHYIDR1"},
		{ 0x03, 0x000, "PHYIDR2"},
		{ 0x04, 0x000, "ANAR"},
		{ 0x07, 0x000, "ANLPAR"},
		{ 0x06, 0x000, "ANER"},
		{ 0x07, 0x000, "ANNPTR"},
		{ 0x10, 0x000, "PHYSTS"},
		{ 0x11, 0x000, "MICR"},
		{ 0x12, 0x000, "MISR"},
		{ 0x13, 0x000, "PARGESEL"},
	};

REG_DESC phyRegPg0[NUM_PHY_REG_PG0] =
	{
		{ 0x14, 0x000, "FCSCR"},
		{ 0x15, 0x000, "RECR"},
		{ 0x16, 0x000, "PCSR"},
		{ 0x17, 0x000, "RBR"},
		{ 0x18, 0x000, "LEDCR"},
		{ 0x19, 0x000, "PHYCR"},
		{ 0x1A, 0x000, "10BTSCR"},
		{ 0x1B, 0x000, "CDCTRL1"},
		{ 0x1C, 0x000, "PHYCR2"},
		{ 0x1D, 0x000, "EDCR"}
	};

#define MDIO_ADDR_PHY_A 2 //2
#define MDIO_ADDR_PHY_B	3 //3

/*******************************************************************************
Function:		emacHostTest
Description:	reads, writes, erase eeprom
*******************************************************************************/
RETURN_CODE  emacHostTest ( PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
	RETURN_CODE	rc;
	U32	rData;
	U16 j;
								
	printf("\nEMAC host interface test");
	printf("\nWaiting for emac init done");

	rData = 0;

	while ((rData & STATUS_POR_COMPLETE) != STATUS_POR_COMPLETE)
	{
		rc = ReadDword(pDevice, BarIndex, FPGA_EMAC_HOST_STATUS,  &rData);
			if (rc != ApiSuccess) return (rc);
			
		//READ_DWORD_PCI(FPGA_EMAC_HOST_STATUS, rdata, MEM_RD, x"0", false);
		CTISleep(2);		
	}
	
	printf("\nemac init is done!");				
		
	


	//getch();
	
	for (j=2;j<=3;j++)
	{
		//MDIORead(pDevice, BarIndex,(U8)j);
		mdioLedDance(pDevice, BarIndex,(U8)j);
	}
		
	return(rc);
}

RETURN_CODE getMacStatus(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 uEmac)
{
		U8 i;
		U32	wData,rData;
		RETURN_CODE rc;

		printf("\nEMAC%d configuration registers\n", uEmac);

		for(i=0; i<=11; i++)
		{
			printf("\n[%d]: %x = %s", i, temacRegSet[i].addr, temacRegSet[i].desc);
			
			wData = makeHostCtrl(uEmac, HOST_OP_READ, temacRegSet[i].addr);

			rc = WriteDword(pDevice, bar, FPGA_EMAC_HOST_CTRL,  wData);
				if (rc != ApiSuccess) return (rc);

			//READ_DWORD_PCI(FPGA_EMAC_HOST_RDATA, rdata, MEM_RD, x"0", false);
			rc = ReadDword(pDevice, bar, FPGA_EMAC_HOST_RDATA,  &rData);
				if (rc != ApiSuccess) return (rc);

			printf(" >> Data = %x", rData);

			if ( rData != temacRegSet[i].exdata )
			{
				printf( "\n\tError: expected %x, read %x", temacRegSet[i].exdata, rData );			
			}
		}

		return (rc);
}

/*******************************************************************************
Function:		mdioLedDance
Description:	Toggles jack LEDs using MDIO
*******************************************************************************/
RETURN_CODE mdioLedDance(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr)
{
//	U32 wData;
//	U32 rData;
	U32 ledData;
	U16 i;
	RETURN_CODE rc;


	// Set page sel
	rc = mdioWriteReg(pDevice,bar,phyAddr,NAT_PHY_PAGESEL,0x0);

	// bit 5 = drv_spdled
	// bit 4 = drv_lnkled
	// bit 2 = spdled value
	// bit 1 = lnkled value

	for(i = 0; i <= 15; i++)
	{
		ledData = 0x0030 | (i & 0x6);
		rc = mdioWriteReg(pDevice,bar,phyAddr,NAT_PHY_LEDCR,ledData);
		CTISleep(500);
	}

	//Return LEDs to normal;
	rc = mdioWriteReg(pDevice,bar,phyAddr,NAT_PHY_LEDCR,0x0);

	return(rc);
}


/*******************************************************************************
Function:		makeHostCtrl
Description:	
*******************************************************************************/
U32  makeHostCtrl (U8 emac1_sel, U8 opcode, U16 addr)
{			
	U32 data;

	/*wdata := (others=>'0');
	wdata(24)			:= '0'; // req, must be pulsed for mii req.  not req'd otherwise
	wdata(19)			:= '0'; // miim_sel
	wdata(18)			:= '0'; // emac1_sel
	wdata(17 downto 16) :=  "11"; // opcode
	wdata(15 downto 0)	:= "000000" & reg_set(i).addr; // address
	WRITE_DWORD_PCI(FPGA_EMAC_HOST_CTRL, wdata, MEM_WR, "0000", false);*/

	data = 0;
	data |= (0 << 24);
	data |= (0 << 19);
	data |= (emac1_sel << 18);
	data |= (opcode << 16);
	data |= addr;
	
	return data;
}

/*******************************************************************************
Function:		makeMiiCtrl
Description:	
*******************************************************************************/
U32  makeMiiCtrl (U8 emac1_sel, U8 opcode, U8 phy, U8 reg)
{
	U32 data;

	/*
	wdata := (others=>'0');
	wdata(24)			:= '1'; // req, must be pulsed for mii req.  not req'd otherwise
	wdata(19)			:= '1'; // miim_sel
	wdata(18)			:= '0'; // emac1_sel
	wdata(17 downto 16) :=  "01"; // opcode; maps to mii opcode
	wdata(15 downto 10)	:= "000000";
	
	wdata(9 downto 5) := "00111"; // PHY select
	wdata(4 downto 0) := "0" & to_stdlogic(i,4); // REG select
	*/

	data = 0;
	data |= (1 << 24);
	data |= (1 << 19);
	data |= (emac1_sel << 18);
	data |= (opcode << 16);
	data |= (phy << 5);
	data |= (reg);

	return(data);
}

/*******************************************************************************
Function:		mdioWriteReg
Description:	writes to PHY registers over managment interface
*******************************************************************************/
RETURN_CODE mdioWriteReg(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr, U8 regAddr, U32 wVal)
{
	U32 wData;
	U32 rData; 
	RETURN_CODE rc;

	// Write data
	rc = WriteDword(pDevice, bar, FPGA_EMAC_HOST_WDATA,  wVal);
			if (rc != ApiSuccess) return (rc);

	wData = makeMiiCtrl(0,MDIO_OP_WRITE,phyAddr,regAddr);
	rc = WriteDword(pDevice, bar, FPGA_EMAC_HOST_CTRL,  wData);
			if (rc != ApiSuccess) return (rc);

	// Wait for write to complete
	rData = 0;

	while ((rData & STATUS_MDIO_COMPLETE) != STATUS_MDIO_COMPLETE)
	{
		rc = ReadDword(pDevice, bar, FPGA_EMAC_HOST_STATUS,  &rData);
			if (rc != ApiSuccess) return (rc);
		CTISleep(2);		
	}

	// Clear Control register
	wData = 0;
	rc = WriteDword(pDevice, bar, FPGA_EMAC_HOST_CTRL,  wData);
			if (rc != ApiSuccess) return (rc);

	return(rc);
}

/*******************************************************************************
Function:		mdioReadReg
Description:	reads PHY registers over managment interface
*******************************************************************************/
RETURN_CODE mdioReadReg(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr, U8 regAddr, U32* rVal)
{
	U32 wData;
	U32 rData; 
	RETURN_CODE rc;

		wData = makeMiiCtrl(0,MDIO_OP_READ,phyAddr,regAddr);

		//NAT_PHY_ADDRA

		//WRITE_DWORD_PCI(FPGA_EMAC_HOST_CTRL, wdata, MEM_WR, "0000", false);
		rc = WriteDword(pDevice, bar, FPGA_EMAC_HOST_CTRL,  wData);
			if (rc != ApiSuccess) return (rc);

		//MII Management Serial Protocol
		//					<idle><start><op code><device addr><reg addr><turnaround><data><idle>
		//Read Operation 	<idle><01>   <10>     <AAAAA>     <RRRRR>     <Z0>       <x*8 ><idle>
		//Write Operation 	<idle><01>   <01>     <AAAAA>     <RRRRR>     <10>       <x*8 ><idle>	
	
		rData = 0;

		while ((rData & STATUS_MDIO_COMPLETE) != STATUS_MDIO_COMPLETE)
		{
			rc = ReadDword(pDevice, bar, FPGA_EMAC_HOST_STATUS,  &rData);
				if (rc != ApiSuccess) return (rc);
				
			//READ_DWORD_PCI(FPGA_EMAC_HOST_STATUS, rdata, MEM_RD, x"0", false);
			CTISleep(2);		
		}

		rc = ReadDword(pDevice, bar, FPGA_EMAC_HOST_RDATA,  &rData);
				if (rc != ApiSuccess) return (rc);

		*rVal = rData;

		//WRITE_DWORD_PCI(FPGA_EMAC_HOST_CTRL, wdata, MEM_WR, "0111", false);
		wData = 0;
		rc = WriteDword(pDevice, bar, FPGA_EMAC_HOST_CTRL,  wData);
			if (rc != ApiSuccess) return (rc);	

		return(ApiSuccess);
}

/*******************************************************************************
Function:		mdioReadAllPhyReg
Description:	reads all PHY registers over managment interface
*******************************************************************************/
RETURN_CODE mdioReadAllPhyReg(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr)
{
	U32 rData; 
	U16 i;
	RETURN_CODE rc;

	printf("\nPhy Status Registsrs [Phy Addr %d]", phyAddr);	
	printf("\nBase Registers");

	for(i=0; i<NUM_PHY_REG_BASE; i++)
	{
		rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[i].addr,&rData);
		printf("\n%3x: %12s = %4x", phyRegBase[i].addr, phyRegBase[i].desc, rData );	
	}

	for(i=0; i<NUM_PHY_REG_PG0; i++)
	{
		rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegPg0[i].addr,&rData);
		printf("\n%3x: %12s = %4x", phyRegPg0[i].addr, phyRegPg0[i].desc, rData );	
	}

	return(rc);
}

/*******************************************************************************
Function:		mdioSetLoopMode
Description:	
*******************************************************************************/
U8 mdioSetLoopMode(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr, U8 mode)
{
	U32 rdVal; 
//	U32 wrVal; 
//	U16 i;
	RETURN_CODE rc;

		
	// setting mode
	if (mode == 1)
	{
		//printf("\n Enabling loopback mode");
		rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,&rdVal);

		rdVal = rdVal | ( 0x2000);	// set to 100 mbps
		rdVal = rdVal & (~0x1000);	// disable auto-negotiation
		rdVal = rdVal | ( 0x0100);	// set full duplex

		rc = mdioWriteReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,rdVal);

		rdVal = rdVal | ( 0x4000);	// enable loopback

		rc = mdioWriteReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,rdVal);
	
		CTISleep(2);

		// read PHYSTS
		rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[8].addr,&rdVal);

		if( (rdVal & 0x0008) == 0x0008)
			return(TRUE); //printf("\n Loopback enable success, PHYSTS = %x", rdVal);
		else
			return(FALSE); //printf("\n Loopback enable failed, PHYSTS = %x", rdVal);
	}
	else
	{
		//printf("\n Disabling loopback mode");
		rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,&rdVal);

		rdVal = rdVal & (~0x4000);	// disable loopback
		
		rc = mdioWriteReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,rdVal);

		rdVal = rdVal | ( 0x1000);	// enable auto-negotiation
		rdVal = rdVal | ( 0x2000);	// set to 100 mbps
		rdVal = rdVal | ( 0x0100);	// set full duplex
		//rdVal = rdVal | ( 0x0200);	// Restart auto-negotiation

		rc = mdioWriteReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,rdVal);

		CTISleep(2);

		// read PHYSTS
		rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[8].addr,&rdVal);

		if( (rdVal & 0x0008) == 0x0000)
			return(TRUE); //printf("\n Loopback disable success, PHYSTS = %x", rdVal);
		else
			return(FALSE); //printf("\n Loopback disable failed, PHYSTS = %x", rdVal);
	}

		/* Don't reset -- it will clear all settings! 
		printf("\n Reseting PHY: ");
		mdioResetPhy(pDevice,bar,phyAddr);
		*/

	
		
	//printf("\n");
	return(TRUE);
}

U8 mdioRestartAutoNeg(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr)
{
	U32 rdVal; 
//	U32 wrVal; 
	U16 retry;
	RETURN_CODE rc;

		

		rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,&rdVal);
	
		rdVal = rdVal | ( 0x0200);	// Restart auto-negotiation

		rc = mdioWriteReg(pDevice,bar,phyAddr,(U8)phyRegBase[0].addr,rdVal);

		CTISleep(2);

		// read BMSR

		retry=0;
		do
		{
			rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[1].addr,&rdVal);
			printf("\nBMSR=%x",rdVal);
			CTISleep(1000);
			retry++;
		} while ( ((rdVal & 0x0020) == 0x0000) && (retry<10));

		if (retry>=10)
			return(FALSE);
		
	//printf("\n");
	return(TRUE);
}

/*******************************************************************************
Function:		mdioVerifyPhyID
Description:	verifys PHY ID over managment interface
*******************************************************************************/
U8 mdioVerifyPhyID(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr)
{
	U32 id1; 
	U32 id2; 
//	U16 i;
	RETURN_CODE rc;

	rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[2].addr,&id1);
	rc = mdioReadReg(pDevice,bar,phyAddr,(U8)phyRegBase[3].addr,&id2);

	// PHYIDR1 == b0010 0000 0000 0000 = 0x2000
	// PHYIDR2 == b0101 1100 1001 0000 = 0x5CA2
	if(id1 == 0x2000 && id2 == 0x5CA2 && rc == ApiSuccess)
	{
		return(TRUE);
	}
	else
	{
		printf("\n* FAILED: id1=%X id2=%X", id1,id2);
		return(FALSE);
	}

	return(TRUE);
}

void mdioResetPhy(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr)
{
	U32 rVal;

	mdioReadReg(pDevice,bar,phyAddr,NAT_PHY_BMCR,&rVal); // bit 15

	rVal = rVal | 0x8000; // set bit 15

	mdioWriteReg(pDevice,bar,phyAddr,NAT_PHY_BMCR,rVal);

	while ((rVal & 0x8000) == 0x8000)
	{
		mdioReadReg(pDevice,bar,phyAddr,NAT_PHY_BMCR,&rVal);
		CTISleep(1);
	}
}

void cleanRxBuffer(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8* rxPkt, U8* rxPktSz, U8 emac)
{
	U8 bClean = FALSE;
	RETURN_CODE rc;

	while(bClean==FALSE)
	{
		rc = emacRx(pDevice, bar,rxPkt,rxPktSz,emac, FALSE, 10);
			if (rc != ApiSuccess) bClean=TRUE;

	}
}

/*******************************************************************************
Function:		emacMiiTest
Description:	main test procedure
*******************************************************************************/
U8  emacMiiTest ( PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
	U8 txPkt[32];
	U8 rxPkt[32];
	U8 numPkt, i, rxPktSz;
	//U8 destMacAddr[6];
	int numEmac;
	U8 bCompare;
	RETURN_CODE rc;

	/*for(i=0;i<4;i++)
	{
		mdioLedDance(pDevice,BarIndex,i);
		mdioGetPhyStatus(pDevice,BarIndex,i);
	}*/
	/*printf("\nReseting PHY A: ");
	mdioWriteReg(pDevice,BarIndex,0,0x1C,0x200);
	CTISleep(1);
	printf("\nReseting PHY B: ");
	mdioWriteReg(pDevice,BarIndex,1,0x1C,0x200); // bit 9
	CTISleep(1);
	*/

	printf("\nEMAC0, Reseting PHY: ");
	mdioResetPhy(pDevice,BarIndex,MDIO_ADDR_PHY_A);
	printf("OK");

	printf("\nEMAC1, Reseting PHY: ");
	mdioResetPhy(pDevice,BarIndex,MDIO_ADDR_PHY_B);
	printf("OK");

	printf("\nEMAC0, Clearing buffer: ");
	cleanRxBuffer(pDevice,BarIndex,&rxPkt[0],&rxPktSz,0);
	printf("OK");

	printf("\nEMAC1, Clearing buffer: ");
	cleanRxBuffer(pDevice,BarIndex,&rxPkt[0],&rxPktSz,1);
	printf("OK");

#ifdef VERIFY_MDIO
	for(numEmac=0; numEmac < 2; numEmac++)
	{
		printf("\nEMAC%d, Verify PHY ID: ", numEmac);	
		if( mdioVerifyPhyID(pDevice,BarIndex,numEmac+MDIO_ADDR_PHY_A) == FALSE)
			return (FALSE);
		printf("OK");

		printf("\nEMAC%d, Led Dance: ", numEmac);	
		mdioLedDance(pDevice,BarIndex,numEmac+MDIO_ADDR_PHY_A);  // should be 2
		printf("OK");
	}
#endif

#ifdef INTERNAL_LOOPBACK

	for(numEmac=0; numEmac < 2; numEmac++)
	{
		printf("\nEMAC%d, Setting enabling loopback mode: ", numEmac);
		mdioSetLoopMode(pDevice,BarIndex,numEmac+MDIO_ADDR_PHY_A,1);
		printf("OK");
	}

	for(numEmac=0; numEmac < 2; numEmac++)
	{
		printf("\nEMAC%d, Clearing buffer: ", numEmac);
		cleanRxBuffer(pDevice,BarIndex,&rxPkt[0],&rxPktSz,numEmac);
		printf("OK");	
	}

	for(numEmac=0; numEmac < 2; numEmac++)
	{
		printf("\nEMAC%d, self loopback: \n",numEmac);	

		//mdioReadAllPhyReg(pDevice,BarIndex,numEmac+MDIO_ADDR_PHY_A); // don't really need this

		for(numPkt=0; numPkt < 16; numPkt++)
		{

			printf(" %d ",numPkt);
			for(i=0;i<16;i++)
			{
				txPkt[16+i] = numPkt*16 + i;
			}

			rc = emacTx(pDevice, BarIndex,&txPkt[0],16,numEmac, bVerbose, 10,1);
				if (rc != ApiSuccess) return (FALSE);

			rc = emacRx(pDevice, BarIndex,&rxPkt[0],&rxPktSz,numEmac, bVerbose, 10);
				if (rc != ApiSuccess) return (FALSE);

			if (rxPktSz != 32 )
			{
				printf("\nError: Packet %d, Improper packet size", numPkt );
				return (FALSE);
			}
			else
			{
				bCompare = TRUE;

				for(i=0;i<32;i++)
				{
					if(txPkt[i] != rxPkt[i])
					{
						bCompare = FALSE;
						printf("\nError: Packet %d, packet compare error at byte %d",numPkt,i);
						//break;
						return(FALSE);
					}
				}

			}

		}
	}


	/*
		printf("\nReseting PHY A: ");
		mdioResetPhy(pDevice,BarIndex,MDIO_ADDR_PHY_A);
		printf("OK");

		printf("\nReseting PHY B: ");
		mdioResetPhy(pDevice,BarIndex,MDIO_ADDR_PHY_B);
		printf("OK");
	*/
		for(numEmac=0; numEmac < 2; numEmac++)
		{
			printf("\nEMAC%d, disabling loopback mode: ", numEmac);
			mdioSetLoopMode(pDevice,BarIndex,numEmac+MDIO_ADDR_PHY_A,0);
			printf("OK");
		}

		CTISleep(2);

		printf("\nEMAC0, Restarting auto-negotiation: ");
		if  ( mdioRestartAutoNeg(pDevice,BarIndex,MDIO_ADDR_PHY_A) == FALSE )
			return(FALSE); 
		printf("OK");

		for(numEmac=0; numEmac < 2; numEmac++)
		{
			printf("\nEMAC%d, Clearing buffer: ", numEmac);
			cleanRxBuffer(pDevice,BarIndex,&rxPkt[0],&rxPktSz,numEmac);
			printf("OK");	
		}

#endif

#ifdef EXTERNAL_LOOPBACK
	for(numEmac=0; numEmac < 2; numEmac++)
	{
		//------------
		printf("\nTest EMAC%d => EMAC%d\n",numEmac,((numEmac+1)&1));	

		//mdioGetPhyStatus(pDevice,BarIndex,0);

		for(numPkt=0; numPkt < 16; numPkt++)
		{

			printf(" %d ",numPkt);
			for(i=0;i<16;i++)
			{
				txPkt[16+i] = numPkt*16 + i;
			}

			rc = emacTx(pDevice, BarIndex,&txPkt[0],16,numEmac, bVerbose, 10,0);
				if (rc != ApiSuccess) return (FALSE);

			rc = emacRx(pDevice, BarIndex,&rxPkt[0],&rxPktSz,((numEmac+1)&1), bVerbose, 10);
				if (rc != ApiSuccess) return (FALSE);

			if (rxPktSz != 32 )
			{
				printf("\nError: Packet %d, Improper packet size", numPkt );
				return (FALSE);
			}
			else
			{
				bCompare = TRUE;

				for(i=0;i<32;i++)
				{
					if(txPkt[i] != rxPkt[i])
					{
						bCompare = FALSE;
						printf("\nError: Packet %d, packet compare error at byte %d",numPkt,i);
						//break;
						return(FALSE);
					}
				}

			}

		}
	}
#else
	for(numEmac=0; numEmac < 2; numEmac++)
	{
		//------------
		printf("\nTest EMAC%d => to external PC",numEmac);	

		//mdioGetPhyStatus(pDevice,BarIndex,0);

		destMacAddr[0]= 0x00;
		destMacAddr[1]= 0x13;
		destMacAddr[2]= 0x72;
		destMacAddr[3]= 0x19;
		destMacAddr[4]= 0x06;
		destMacAddr[5]= 0xA7;

		for(numPkt=0; numPkt < 16; numPkt++)
		{

			printf(" %d ",numPkt);
			for(i=0;i<16;i++)
			{
				txPkt[16+i] = numPkt*16 + i;
			}

			rc = emacTxEx(pDevice, BarIndex,&txPkt[0],16,numEmac, bVerbose, 10, &destMacAddr[0]);
				if (rc != ApiSuccess) return (FALSE);

		}

		CTIPause();
	}
#endif


	return(TRUE);
}


RETURN_CODE emacTx(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8* pkt, U8 pktPayloadSz, U8 emacNum, U8 verbose, U8 numRetry, U8 loopback)
{
	U32 addrTxBuf;
	U32 addrTxCtrl;
	U32 addrTxSta;
	U8 macDest;
	U8 macSrc;
	U8 pktSz;
//	U8 pktTmp[32];
	U8 wData;
	U8 rData;
	U8 i;
	RETURN_CODE rc;

	if (emacNum ==0)
	{
		addrTxBuf = FPGA_EMAC0TX_BUF;
		addrTxCtrl = FPGA_EMAC0TX_CTRL;
		addrTxSta = FPGA_EMAC0TX_STA;
		if(loopback==0)
		{
			macDest = 0xB2;
			macSrc = 0xA1;
		}
		else
		{
			macDest = 0xA1;
			macSrc = 0xA1;
		}
	}
	else
	{
		addrTxBuf = FPGA_EMAC1TX_BUF;
		addrTxCtrl = FPGA_EMAC1TX_CTRL;
		addrTxSta = FPGA_EMAC1TX_STA;
		if(loopback==0)
		{
			macDest = 0xA1;
			macSrc = 0xB2;
		}
		else
		{
			macDest = 0xB2;
			macSrc = 0xB2;
		}
	}
	
	pkt[0]= 0x00; 	// DMAC ADDR0
	pkt[1]= 0x0C; 	// DMAC ADDR1
	pkt[2]= 0x8B; 	// DMAC ADDR2
	pkt[3]= macDest; 	// DMAC ADDR3
	pkt[4]= 0x00; 	// DMAC ADDR4			
	pkt[5]= 0x00; 	// DMAC ADDR5			
	pkt[6]= 0x00; 	// SMAC ADDR0
	pkt[7]= 0x0C; 	// SMAC ADDR1
	pkt[8]= 0x8B; 	// SMAC ADDR2
	pkt[9]= macSrc; 	// SMAC ADDR3
	pkt[10]= 0x00; 	// SMAC ADDR4
	pkt[11]= 0x00; 	// SMAC ADDR5
	pkt[12]= 0x00; 	// Ethertype0
	pkt[13]= 0x00; 	// Ethertype1
	pkt[14]= 0xFF; 	// data0
	pkt[15]= 0xFF; 	// data1
	
	if (verbose) printf("\n EMAC%d: Setting up packet",emacNum);
	// Load pkt into buffer
	pktSz = 16 + pktPayloadSz;

	pkt[13]= pktSz; 	// Ethertype1

	rc = PlxPci_PciBarSpaceWrite(pDevice,bar,addrTxBuf,pkt,pktSz,BitSize32,FALSE);
		if (rc != ApiSuccess) return (rc);

/*	rc = PlxPci_PciBarSpaceRead(pDevice,bar,addrTxBuf,&pktTmp,32,BitSize32,FALSE);
		if (rc != ApiSuccess) return (rc);

	for(i=0;i<32;i++)
		printf("\n%d, %x",i,pktTmp[i]);
*/
	// set up packet size, and set send bit
	wData = 0x80 | pktSz;
		//WRITE_DWORD_PCI(FPGA_EMAC0TX_CTRL, wdata, MEM_WR, "1110", false);
	rc = WriteByte(pDevice, bar, addrTxCtrl,  wData);
		if (rc != ApiSuccess) return (rc);

	if (verbose) printf("\n EMAC%d: Waiting for pkt send complete",emacNum);

	i=0;
	do
	{
		rc = ReadByte (pDevice,bar,addrTxSta,&rData);
//		printf("%x\n",rVal);
		CTISleep(SLEEP_DELAY);
		i++;
	} while (((rData & 0x80) != 0x80)  && (rc == ApiSuccess) && (i < numRetry) );

	if (i>=numRetry)
	{
		if(verbose) printf("\n EMAC%d: Transmit timeout",emacNum);
		return ApiFailed;
	}


	if (verbose) printf("\n EMAC%d: pkt sent",emacNum);

	// Clear send bit
	wData = 0;
	//WRITE_DWORD_PCI(FPGA_EMAC0TX_CTRL, wdata, MEM_WR, "1110", false);
	rc = WriteByte(pDevice, bar, addrTxCtrl,  wData);
		if (rc != ApiSuccess) return (rc);

	if(verbose) printf("\n");

	return(ApiSuccess);
}


RETURN_CODE emacRx(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8* pkt, U8* pktSz, U8 emacNum, U8 verbose, U8 numRetry)
{
	U32 addrRxBuf;
	U32 addrRxCtrl;
	U32 addrRxSta;
	U8 wData;
	U8 rData;
	U8 i;
	RETURN_CODE rc;

	if (emacNum == 0)
	{
		addrRxBuf = FPGA_EMAC0RX_BUF;
		addrRxCtrl = FPGA_EMAC0RX_CTRL;
		addrRxSta = FPGA_EMAC0RX_STA;
	}
	else
	{
		addrRxBuf = FPGA_EMAC1RX_BUF;
		addrRxCtrl = FPGA_EMAC1RX_CTRL;
		addrRxSta = FPGA_EMAC1RX_STA;
	}
	
	if(verbose) printf("\n EMAC%d: waiting for pkt recv complete",emacNum);

	i=1;
	do
	{
		rc = ReadByte (pDevice,bar,addrRxSta,&rData);
//		printf("%x\n",rVal);
		CTISleep(SLEEP_DELAY);
		i++;

	} while (((rData & 0x80) != 0x80)  && rc == ApiSuccess && i < numRetry);

	if (i>=numRetry)
	{
		if(verbose) printf("\n EMAC%d: Recv timeout",emacNum);
		return ApiFailed;
	}

	(*pktSz) = 0x7F & rData;

	if(verbose) printf("\n EMAC%d: packet recv'd, size=%d",emacNum, (*pktSz));

	// read pkt header from buffer
	rc = PlxPci_PciBarSpaceRead(pDevice,bar,addrRxBuf,pkt,32,BitSize32,FALSE);
		if (rc != ApiSuccess) return (rc);

	// set packet processed flag
	wData = 0x80;
	rc = WriteByte(pDevice, bar, addrRxCtrl,  wData);
		if (rc != ApiSuccess) return (rc);

	do
	{
		rc = ReadByte (pDevice,bar,addrRxSta,&rData);
//		printf("%x\n",rVal);
		CTISleep(SLEEP_DELAY);

	} while (((rData & 0x80) != 0x00)  && rc == ApiSuccess);

	// clear flag
	if(verbose) printf("\n EMAC%d: clearing flag",emacNum);

	wData = 0;
	rc = WriteByte(pDevice, bar, addrRxCtrl,  wData);
		if (rc != ApiSuccess) return (rc);

	rc = ReadByte (pDevice,bar,addrRxSta,&rData);

	if(verbose) printf("\n");
	return(ApiSuccess);
}


RETURN_CODE emacTxEx(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8* pkt, U8 pktPayloadSz, U8 emacNum, U8 verbose, U8 numRetry, U8* dstMacAddr)
{
	U32 addrTxBuf;
	U32 addrTxCtrl;
	U32 addrTxSta;
//	U8 macDest;
	U8 macSrc;
	U8 pktSz;
//	U8 pktTmp[32];
	U8 wData;
	U8 rData;
	U8 i;
	RETURN_CODE rc;

	if (emacNum ==0)
	{
		addrTxBuf = FPGA_EMAC0TX_BUF;
		addrTxCtrl = FPGA_EMAC0TX_CTRL;
		addrTxSta = FPGA_EMAC0TX_STA;
		macSrc = 0xA1;
	}
	else
	{
		addrTxBuf = FPGA_EMAC1TX_BUF;
		addrTxCtrl = FPGA_EMAC1TX_CTRL;
		addrTxSta = FPGA_EMAC1TX_STA;
		macSrc = 0xB2;
	}
	
	pkt[0]= dstMacAddr[0]; 	// DMAC ADDR0
	pkt[1]= dstMacAddr[1]; 	// DMAC ADDR1
	pkt[2]= dstMacAddr[2]; 	// DMAC ADDR2
	pkt[3]= dstMacAddr[3]; 	// DMAC ADDR3
	pkt[4]= dstMacAddr[4]; 	// DMAC ADDR4			
	pkt[5]= dstMacAddr[5]; 	// DMAC ADDR5			
	pkt[6]= 0x00; 	// SMAC ADDR0
	pkt[7]= 0x0C; 	// SMAC ADDR1
	pkt[8]= 0x8B; 	// SMAC ADDR2
	pkt[9]= macSrc; 	// SMAC ADDR3
	pkt[10]= 0x00; 	// SMAC ADDR4
	pkt[11]= 0x00; 	// SMAC ADDR5
	pkt[12]= 0x00; 	// Ethertype0
	pkt[13]= 0x00; 	// Ethertype1
	pkt[14]= 0xFF; 	// data0
	pkt[15]= 0xFF; 	// data1
	
	if (verbose) printf("\n EMAC%d: Setting up packet",emacNum);
	// Load pkt into buffer
	pktSz = 16 + pktPayloadSz;

	pkt[13]= pktSz; 	// Ethertype1

	rc = PlxPci_PciBarSpaceWrite(pDevice,bar,addrTxBuf,pkt,pktSz,BitSize32,FALSE);
		if (rc != ApiSuccess) return (rc);

/*	rc = PlxPci_PciBarSpaceRead(pDevice,bar,addrTxBuf,&pktTmp,32,BitSize32,FALSE);
		if (rc != ApiSuccess) return (rc);

	for(i=0;i<32;i++)
		printf("\n%d, %x",i,pktTmp[i]);
*/
	// set up packet size, and set send bit
	wData = 0x80 | pktSz;
		//WRITE_DWORD_PCI(FPGA_EMAC0TX_CTRL, wdata, MEM_WR, "1110", false);
	rc = WriteByte(pDevice, bar, addrTxCtrl,  wData);
		if (rc != ApiSuccess) return (rc);

	if (verbose) printf("\n EMAC%d: Waiting for pkt send complete",emacNum);

	i=0;
	do
	{
		rc = ReadByte (pDevice,bar,addrTxSta,&rData);
//		printf("%x\n",rVal);
		CTISleep(SLEEP_DELAY);
		i++;
	} while (((rData & 0x80) != 0x80)  && (rc == ApiSuccess) && (i < numRetry) );

	if (i>=numRetry)
	{
		if(verbose) printf("\n EMAC%d: Transmit timeout",emacNum);
		return ApiFailed;
	}


	if (verbose) printf("\n EMAC%d: pkt sent",emacNum);

	// Clear send bit
	wData = 0;
	//WRITE_DWORD_PCI(FPGA_EMAC0TX_CTRL, wdata, MEM_WR, "1110", false);
	rc = WriteByte(pDevice, bar, addrTxCtrl,  wData);
		if (rc != ApiSuccess) return (rc);

	if(verbose) printf("\n");

	return(ApiSuccess);
}
