/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			FPGAReg.h
Description:	Definitions for FPGA reference design registers
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-04-02	MF		Fixed DM register values
2008-04-18	MF		Add EEPROM access registers
2008-04-21	MF		Added serial registers
2008-04-29	MF		Add SPI select register
2008-05-05	MF		Add MII host interface register
2008-07-30	MF		Add gtp status and control registers
2008-09-20	MF		add new gtp controls
2008-11-11	MF		Add hss user io registers
2009-03-11	MF		Add reference to addrMapCfg.h
*******************************************************************************/

#ifndef FPGAREG_H
#define FPGAREG_H

#include "addrMapCfg.h"		
/* Note: for this to work '.\' must be added to include path */

/*------------------------------------------------------------------------------
Address Maps
------------------------------------------------------------------------------*/
#ifdef FPGA_MAP_SWTC
	#include "swtcCIBReg.h"
#endif

//===============================================================
#ifdef FPGA_MAP_REF_DESIGN
#define USR_BAR					2
#define SPI_BAR					3

//BAR 2 = USR BAR Address Map
#define FPGA_BAR2_MAP

#define FPGA_INTERRUPT_MASK		0x000					//0
#define FPGA_INTERRUPT_SOURCE	0x004					//1
#define FPGA_EMAC_CTRL			0x008					//2
									//-- Byte offsets
#define FPGA_EMAC0TX_CTRL			0x008			
#define FPGA_EMAC0RX_CTRL			0x009
#define FPGA_EMAC1TX_CTRL			0x00A
#define FPGA_EMAC1RX_CTRL			0x00B
									//-- Byte offsets
#define FPGA_EMAC_STA			0x00C					//3
#define FPGA_EMAC0TX_STA			0x00C
#define FPGA_EMAC0RX_STA			0x00D
#define FPGA_EMAC1TX_STA			0x00E
#define FPGA_EMAC1RX_STA			0x00F
#define FPGA_GPIO_P_OUT			0x010
#define FPGA_GPIO_P_TRI			0x014
#define FPGA_GPIO_P_IN			0x018
#define FPGA_GPIO_N_OUT			0x01C
#define FPGA_GPIO_N_TRI			0x020
#define FPGA_GPIO_N_IN			0x024
#define FPGA_GTP_TXSZ			0x028					//10
									//-- Byte offsets
#define FPGA_GTP_TXSZ0				0x028
#define FPGA_GTP_TXSZ1				0x029
#define FPGA_GTP_TXSZ2				0x02A
#define FPGA_GTP_TXSZ3				0x02B
#define FPGA_USER_LED			0x02C					//11
#define FPGA_DM_CTRL			0x030					//12
#define FPGA_DM_ADDR			0x034					//13
#define FPGA_DM_CNT				0x038
#define FPGA_REV				0x03C					//15
#define FPGA_DDR2_CTRL			0x040
#define FPGA_DDR2_CMD_SZ		0x044
#define FPGA_DDR2_ADDR			0x048
#define FPGA_DDR2_STATUS		0x04C
#define FPGA_EEPROM_CMD_WDATA	0x050
#define FPGA_EEPROM_STA_RDATA	0x054
#define FPGA_RS0_CTRL_AND_TX	0x058
#define FPGA_RS0_STAT_AND_RX	0x05C
#define FPGA_RS1_CTRL_AND_TX	0x060
#define FPGA_RS1_STAT_AND_RX	0x064
#define FPGA_EMAC_HOST_CTRL		0x068
#define FPGA_EMAC_HOST_WDATA	0x06C
#define FPGA_EMAC_HOST_STATUS	0x070
#define FPGA_EMAC_HOST_RDATA	0x074
#define FPGA_GTP_CTRL			0x078
#define FPGA_GTP_CTRL0				0x078
#define FPGA_GTP_CTRL1				0x079
#define FPGA_GTP_CTRL2				0x07A
#define FPGA_GTP_CTRL3				0x07B
	
#define FPGA_GTP_STA			0x07C
#define FPGA_GTP_STA0				0x07C
#define FPGA_GTP_STA1				0x07D
#define FPGA_GTP_STA2				0x07E
#define FPGA_GTP_STA3				0x07F

#define FPGA_EMAC0TX_BUF		0x080
#define FPGA_EMAC0RX_BUF		0x0A0
#define FPGA_EMAC1TX_BUF		0x0C0
#define FPGA_EMAC1RX_BUF		0x0E0
#define FPGA_MEMORY_LOC_0		0x100
#define FPGA_GTP_TX0_BUF		0x200
#define FPGA_GTP_TX1_BUF		0x240
#define FPGA_GTP_TX2_BUF		0x280
#define FPGA_GTP_TX3_BUF		0x2C0
#define FPGA_GTP_RX0_BUF		0x300
#define FPGA_GTP_RX1_BUF		0x340
#define FPGA_GTP_RX2_BUF		0x380
#define FPGA_GTP_RX3_BUF		0x3C0

//BAR 3 = SPI BAR Address Map
//		Description				Offset	Reg Num
#define FPGA_SPI_CMD			0x00	// 0
#define FPGA_SPI_PARAM			0x04	// 1
#define FPGA_SPI_STATUS			0x08	// 2
#define FPGA_SPI_RESULT			0x0C	// 3
#define FPGA_SPI_SEL			0x10	// 4
#define FPGA_BASE_ADDR_0		0x14	// 5
#define FPGA_HSS				0x18	// 6
	#define FPGA_HSS_OUT		0x18
	#define FPGA_HSS_DIR		0x19
#define FPGA_HSS_IN				0x1C	// 7
#define FPGA_SPI_PAGE_MEM		0x100
#endif

//===============================================================
#ifdef FPGA_MAP_BSP_STANDALONE
#define USR_BAR					2

#define FPGA_REG0				0x000

#define FPGA_INTERRUPT_MASK		0x000		//0
#define FPGA_INTERRUPT_SOURCE	0x004		//1
#define FPGA_PROC_CTRL			0x008		//2
#define FPGA_PROC_STA			0x00C		//3
#define FPGA_DM_CTRL			0x010		//4
#define FPGA_DM_ADDR			0x014		//5
#define FPGA_DM_CNT				0x018		//6
#define FPGA_REV				0x01C		//7

#define FPGA_RAM0_BASE			0x1000
#define FPGA_RAM0_HIGH			0x1FFF  // 4K
#define FPGA_RAM0_SZ			(FPGA_RAM0_HIGH-FPGA_RAM0_BASE+1)

#define FPGA_MEMORY_LOC_0		FPGA_RAM0_BASE
#define FPGA_MEMORY_SZ			FPGA_RAM0_SZ
#endif

//===============================================================
#ifdef FPGA_MAP_BSP_QNX

#define FPGA_REG0		0x000
#define FPGA_REG1		0x004
#define FPGA_REG2		0x008
#define FPGA_REG3		0x00C
#define FPGA_REG4		0x010
#define FPGA_REG5		0x014
#define FPGA_REG6		0x018
#define FPGA_REG7		0x01C

#define FPGA_RAM0_BASE		0x800
#define FPGA_RAM0_HIGH		0xBFF
#define FPGA_RAM0_SZ		(FPGA_RAM0_HIGH-FPGA_RAM0_BASE+1)
#define FPGA_RAM1_BASE		0xC00
#define FPGA_RAM1_HIGH		0xFFF
#define FPGA_RAM1_SZ		(FPGA_RAM1_HIGH-FPGA_RAM1_BASE+1)
#endif

/*------------------------------------------------------------------------------
Constants
------------------------------------------------------------------------------*/

// FPGA interrupt bits
#define INTERRUPT_DM			0x1
#define INTERRUPT_SPI			0x2

// PLX/PCI interrupt control bits
#define INTCSR_PCI_INT_EN		0x0100	// Bit 8
#define INTCSR_PCI_DB_EN		0x0200	// Bit 9
#define INTCSR_PCI_ABORT_EN		0x0400	// Bit 10
#define INTCSR_LINT_EN			0x0800	// Bit 11
#define INTCSR_RETRY_EN			0x1000	// Bit 12
#define INTCSR_PCI_DB_ACTIVE	0x2000	// Bit 13
#define INTCSR_PCI_ABORT_ACTIVE	0x4000	// Bit 14
#define INTCSR_LINT_ACTIVE		0x8000	// Bit 15

// DM control bits
#define	DM_OP_START				0x01	// Bit 0
#define DM_OP_WRITE				0x02	// Bit 1 
#define DM_OP_READ				0x00	// Bit 1

// DDR2 constants
#define DDR2_CMD_WR				0x0
#define DDR2_CMD_RD				0x1
#define DDR2_CTRL_LOAD			0x1
#define DDR2_CTRL_ACK			0x2
#define DDR2_STATUS_COMPLETE	0x01
#define DDR2_STATUS_BUSY		0x02
#define DDR2_STATUS_PHY_DONE	0x04
#define DDR2_STATUS_FIFO_FULL	0x08

//Serial constants
#define RS_CTRL_CLEAR				0x00
#define RS_CTRL_TX_PUSH				0x01
#define RS_CTRL_RX_POP				0x02

#define RS_STATUS_TX_DATA_PRESENT	0x01 //0
#define RS_STATUS_TX_FULL			0x02 //1
#define RS_STATUS_TX_HALF_FULL		0x04 //2
//#define RS_STATUS					0x08 //3
#define RS_STATUS_RX_DATA_PRESENT	0x10 //4
#define RS_STATUS_RX_FULL			0x20 //5
#define RS_STATUS_RX_HALF_FULL		0x40 //6
//#define RS_STATUS					0x80 //7

#endif //FPGAREG_H