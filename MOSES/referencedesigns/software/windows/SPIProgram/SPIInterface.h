/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			SPIInterface.h
Description:	Definitions for SPI flash programming interface
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-04-29	MF		Add flash info table
2008-12-01	MF		Modify function headers to pass interrupt structure
2009-03-19	MF		Cleanup include file ordering
2009-08-19	MF		Add sector offset for page programming
					Add blankCheck
2010-09-02	MF		Added check for spansion flash
*******************************************************************************/

#ifndef SPI_INTERFACE_H
#define SPI_INTERFACE_H

#include <string.h>
#include "PlxInit.h"
#include "FPGAReg.h"
#include "fpgaDmInt.h"

#define USE_INTR

#define SIZE_PAGE_BUFFER (64*4)

// SPI Programming interface
#define SPI_CLEAR				0x00
#define SPI_BULK_ERASE			0x01
#define SPI_SECTOR_ERASE		0x02
#define SPI_PROGRAM				0x03
#define SPI_WRITE_PAGE_CLOSE	0x04
#define SPI_GET_ID				0x05
#define SPI_WRITE_PAGE			0x06
#define SPI_FIFO_LOOPBACK		0x07
#define SPI_GET_SIG				0x08
#define SPI_DATA_READY			0x10
#define SPI_READ_PAGE			0x11
#define SPI_BLANK_CHECK			0x12
#define SPI_REPROGRAM			0x13

#define M25P16					0
#define M25P32					1
#define M25P64					2
#define S25FL064				3

/*#define M25P16_ID				0x202015
#define	M25P16_SIG				0x14
#define M25P16_NUM_SEC			32
#define M25P16_NUM_PAGE			8192
#define M25P16_PAGE_SIZE		256
#define M25P16_PAGE_PER_SEC		256
#define M25P16_SEC_SIZE			(M25P16_PAGE_SIZE*M25P16_PAGE_PER_SEC)
#define M25P16_DEV_SIZE			(M25P16_NUM_SEC*M25P16_SEC_SIZE)		*/

/*#define M25P64_ID				0x202017
#define	M25P64_SIG				0x16
#define M25P64_NUM_SEC			128
#define M25P64_NUM_PAGE			8192
#define M25P64_PAGE_SIZE		256
#define M25P64_PAGE_PER_SEC		256
#define M25P64_SEC_SIZE			(M25P64_PAGE_SIZE*M25P64_PAGE_PER_SEC)
#define M25P64_DEV_SIZE			(M25P64_NUM_SEC*M25P64_SEC_SIZE)*/


//#define WAIT_DATA 0x02
//#define DATA_AVAILABLE 0x04

#define	REC_FIXED_FIELDS 5
#define	REC_DATA_FIELD 16
#define REC_SIZE (REC_FIXED_FIELDS + REC_DATA_FIELD)

// Results
#define SPI_STATUS_COMPLETE	0x01

#define RW_TEST_PASS	0x11
#define RW_TEST_FAIL	0x12
#define SE_TEST_PASS	0x21
#define SE_TEST_FAIL	0x22
#define BC_PASS			0x31
#define BC_FAIL			0x32

/*====================
Type Declarations
====================*/
typedef struct _st_flash_info
{	U32 id;
	U8 sig;
	U16 numSec;
	//U16 numPage;
	U16 pageSize;
	U16 pagePerSec;
	//U32 secSize;
	//U32 devSize;
} st_flash_info, *p_st_flash_info;

typedef struct _HEX_RECORD
{
	unsigned char size;
	unsigned char addrPage;
	unsigned char addrByte;
	unsigned char type;
	unsigned char data[16];
	unsigned char cs;
} HEX_RECORD, *PHEX_RECORD;

/*====================
Macros
====================*/
#define STFI_SECSIZE(stfi)  ((stfi).pageSize * (stfi).pagePerSec)
#define STFI_DEVSIZE(stfi)  ((stfi).pageSize * (stfi).pagePerSec * (stfi).numSec)

/*====================
Function Declarations
====================*/
RETURN_CODE loopback(PLX_DEVICE_OBJECT* pDevice, U32 lbIn, U32* plbOut);
RETURN_CODE readSignature(PLX_PTR Dev, U32* pSig);
RETURN_CODE readID(PLX_PTR Dev, U32* pID);
RETURN_CODE eraseSector(PLX_PTR Dev, U32 addrSector);
RETURN_CODE readPage(PLX_PTR Dev, U8 addrSector, U8 addrPage, U8 addrByte, U32* pBuf );
RETURN_CODE writePage(PLX_PTR Dev, U8 addrSector, U8 addrPage, U8 addrByte, U32* pBuf, U32 pageSize );
RETURN_CODE bulkErase(PLX_PTR Dev);
void processRecord(char* strBuf, HEX_RECORD* rec);
RETURN_CODE programFlash(PLX_PTR Dev, char* fileName, U8 secOffset);
RETURN_CODE readFlash(PLX_PTR Dev, char* fileName, st_flash_info* pfinfo );
U8 aBytetohByte(char a, char b);
RETURN_CODE resetFPGA(PLX_PTR Dev, U8 addrSector, U8 addrPage, U8 addrByte);
void mcsGen(char* fileName, st_flash_info* pfinfo, U32 seed );
U8 verifyFlash(PLX_PTR Dev, char* fileName, U8 secOffset);
RETURN_CODE blankCheck(PLX_PTR Dev, U8* result);

/*====================
Global Declarations
====================*/
extern st_flash_info finfoTbl[4];

#endif
