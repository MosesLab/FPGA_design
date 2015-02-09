/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			SPIProgram.h
Description:	Definitions for SPI flash programming interface
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-12-01	MF		Modify function SPITest
2009-03-19	MF		Cleanup include file ordering
2009-07-27	MF		spiTest to check for two different ids for flash A
*******************************************************************************/

#ifndef SPI_PROGRAM_H
#define SPI_PROGRAM_H

#include "PlxApi.h"
#include "FPGAReg.h"
#include "SPIInterface.h"

/*====================
  CONSTANTS
====================*/
#define FPGA_FLASH	0
#define SW_FLASH	1

/*====================
  FUNCTIONS
====================*/
U8 InitFlashTest(PLX_PTR plxPtr, U8 flashSel, st_flash_info* pfinfoA, st_flash_info* pfinfoB); 
U8 progAndRb(PLX_DEVICE_OBJECT* pDevice, 
			 U8 flashSel, 
			 char* progFile, 
			 char* rbFile, 
			 U8 program, 
			 U8 reset, 
			 U8 bulkerase, 
			 U8 verify);
U8 SPITest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif