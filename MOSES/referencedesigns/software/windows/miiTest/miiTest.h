/*******************************************************************************
Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			miiTest.h
Description:	Program to test mii interface and management interface
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-12-09	MF		Add transmit timeout
2009-01-12	MF		Add phy internal loopback test
'			'		Add functions to transmit to a specific mac addr emacTxEx()
2009-03-19	MF		Cleanup include file ordering
*******************************************************************************/

#ifndef MIITEST_H
#define MIITEST_H

#include "PlxInit.h"
#include "FPGAReg.h"


/*===============
CONSTANTS
===============*/
#define HOST_OP_WRITE			0x1	// 01
#define HOST_OP_READ			0x3	// 11
#define MDIO_OP_WRITE			0x1 // 01
#define MDIO_OP_READ			0x2 // 10
#define STATUS_POR_COMPLETE		0x2
#define STATUS_MDIO_COMPLETE	0x1

typedef struct _REG_DESC
{
	U16 addr;
	U32 exdata;
	char* desc;

} REG_DESC;

		

/* phy strapping settings
	-- strap values
	phy_ad1_rxd0_A <= '1';
	phy_ad2_rxd1_A <= '0';
	phy_ad3_rxd0_B <= '0';
	phy_ad4_rxd1_B <= '0'; 

	see page 19 of phy data sheet
*/

#define NAT_PHY_ADDRA 0x2 // 0001_0
#define NAT_PHY_ADDRB 0x3 //0001_1

// National Phy registers
#define NAT_PHY_BMCR 0x0 // Basic Mode Control Register
#define NAT_PHY_BMSR 0x1 // Basic Mode Status Register
#define NAT_PHY_PHYIDR1 0x2 // PHY Identifier Register #1
#define NAT_PHY_PHYIDR2 0x3 // PHY Identifier Register #2
#define NAT_PHY_ANAR 0x4 // Auto-Negotiation Advertisement Register
#define NAT_PHY_ANLPAR 0x5 // Auto-Negotiation Link Partner Ability Register (Base Page)
#define NAT_PHY_ANLPARNP 0x5 // Auto-Negotiation Link Partner Ability Register (Next Page)
#define NAT_PHY_ANER 0x6 // Auto-Negotiation Expansion Register
#define NAT_PHY_ANNPTR 0x7 // Auto-Negotiation Next Page TX
//#define NAT_PHY_RESERVED 0x8-0xf // RESERVED
#define NAT_PHY_PHYSTS 0x10 // PHY Status Register
#define NAT_PHY_MICR 0x11 // MII Interrupt Control Register
#define NAT_PHY_MISR 0x12 // MII Interrupt Status Register
#define NAT_PHY_PAGESEL 0x13 // Page Select Register

// Extended registers. Page 0 // 
#define NAT_PHY_FCSCR 0x14 // False Carrier Sense Counter Register
#define NAT_PHY_RECR 0x15 // Receive Error Counter Register
#define NAT_PHY_PCSR 0x16 // PCS Sub-Layer Configuration and Status Register
#define NAT_PHY_RBR 0x17 // RMII and Bypass Register
#define NAT_PHY_LEDCR 0x18 // LED Direct Control Register
#define NAT_PHY_PHYCR 0x19 // PHY Control Register
#define NAT_PHY_10BTSCR 0x1A // 10Base-T Status/Control Register
#define NAT_PHY_CDCTRL1 0x1B // CD Test Control Register and BIST Extensions Register
#define NAT_PHY_PHYCR2 0x1C // Phy Control Register 2
#define NAT_PHY_EDCR 0x1D // Energy Detect Control Register
//#define NAT_PHY_RESERVED 0x1E // RESERVED
//#define NAT_PHY_RESERVED 0x1F // RESERVED

// Extended registers. Page 1 // 
//#define NAT_PHY_RESERVED 0x14-1F // RESERVED

// Extended registers. Page 2 // 
#define NAT_PHY_LEN100_DET 0x14 // 100Mb Length Detect Register
#define NAT_PHY_FREQ100 0x15 // 100Mb Frequency Offset Indication Register
#define NAT_PHY_TDR_CTRL 0x16 // TDR Control Register
#define NAT_PHY_TDR_WIN 0x17 // TDR Window Register
#define NAT_PHY_TDR_PEAK 0x18 // TDR Peak Measurement Register
#define NAT_PHY_TDR_THR 0x19 // TDR Threshold Measurement Register
#define NAT_PHY_VAR_CTRL 0x1A // Variance Control Register
#define NAT_PHY_VAR_DAT 0x1B // Variance Data Register
//#define NAT_PHY_RESERVED 0x1C // RESERVED
#define NAT_PHY_LQMR 0x1D // Link Quality Monitor Register
#define NAT_PHY_LQDR 0x1E // Link Quality Data Register
//#define NAT_PHY_RESERVED 0x1F // RESERVED

			
/*===============
FUNCTIONS
===============*/
RETURN_CODE  emacHostTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);
U8  emacMiiTest ( PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);
U32  makeHostCtrl (U8 emac1_sel, U8 opcode, U16 addr);
U32  makeMiiCtrl (U8 emac1_sel, U8 opcode, U8 phy, U8 reg);
U32 MDIORead(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 phyAddr);
RETURN_CODE mdioLedDance(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 phyAddr);
RETURN_CODE emacTx(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8* pkt, U8 pktPayloadSz, U8 emacNum, U8 bVerbose, U8 numRetry, U8 loopback);
RETURN_CODE emacRx(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8* pkt, U8* pktSz, U8 emacNum, U8 bVerbose, U8 numRetry);
RETURN_CODE mdioReadReg(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr, U8 regAddr, U32* rVal);
RETURN_CODE mdioWriteReg(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr, U8 regAddr, U32 wVal);
void mdioResetPhy(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 phyAddr);
RETURN_CODE emacTxEx(PLX_DEVICE_OBJECT* pDevice, U8 bar, U8* pkt, U8 pktPayloadSz, U8 emacNum, U8 verbose, U8 numRetry, U8* dstMacAddr );

#endif