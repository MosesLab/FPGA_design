/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			flashData.h
Description:	Flash data, memory storage structures
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-02-12	MF 		Created
2009-09-24	MF		Modified from Microblaze code
*******************************************************************************/

#ifndef FLASH_DATA_H
#define FLASH_DATA_H

#include "PlxApi.h"

#define FD_DYNAMIC
/* 
 * Constants
 */
#define MAX_BYTE	256
#define MAX_PAGE	256
#define MAX_SEC		256
#define MAX_TOTAL_PAGE (MAX_SEC*MAX_PAGE)


/*
 * Structures
 */
typedef struct _FLASH_PAGE
{
	U8 addr;
	U16 numByte;
	U8 data[MAX_BYTE];	
} FLASH_PAGE;

typedef struct _FLASH_SEC
{
	U8 addr;
	U16 numPage;
	FLASH_PAGE* page[MAX_PAGE];
} FLASH_SEC;

typedef struct _FLASH_DATA
{
	U16	numSec;
	FLASH_SEC* sec[MAX_SEC];
} FLASH_DATA;

/*
 * Function Prototypes
 */
FLASH_DATA*	new_flash_data();
FLASH_SEC* 	new_flash_sec(FLASH_DATA* pfd, U8 sec);
FLASH_PAGE*	new_flash_page(FLASH_SEC* pfsec, U8 page);
void free_flash_data(FLASH_DATA* pfd);
void free_flash_sec(FLASH_SEC* pfsec);

#endif //FLASH_DATA_H
