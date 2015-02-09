/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			flashData.c
Description:	Flash data, memory storage structures
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-02-12	MF 		Created
2008-02-20	MF		Use static allocation
2008-09-24	MF		Converted from Microblaze code to QNX6 code
*******************************************************************************/

//#include "xbasic_types.h"
#include "flashData.h"

#ifdef FD_DYNAMIC
	#include "malloc.h"
#else
	FLASH_DATA	fd;
	FLASH_SEC	secArr[MAX_SEC];
	FLASH_PAGE	pageArr[MAX_TOTAL_PAGE];
	U32 secArrPtr=0;
	U32 pageArrPtr=0;
	??
#endif



#define INIT_PAGE_DATA

FLASH_DATA* new_flash_data()
{
	FLASH_DATA* pfd;
	U16 i;
	
	#ifdef FD_DYNAMIC
		pfd = malloc(sizeof(FLASH_DATA));
	#else
		pfd = &fd;
	#endif
	
	if (pfd == NULL)
		return(NULL);
	
	pfd->numSec=0;
	
	for (i=0;i<MAX_SEC;i++)
		pfd->sec[i] = NULL;
	
	return(pfd);
}

FLASH_SEC* new_flash_sec(FLASH_DATA* pfd, U8 sec)
{
	U16 i;
	U16 curSec = pfd->numSec;
	
	#ifdef FD_DYNAMIC
		pfd->sec[curSec] = malloc(sizeof(FLASH_SEC));
	#else
		if (secArrPtr < MAX_SEC)
			pfd->sec[curSec] = &secArr[secArrPtr++];  //pfd->sec[curSec] = &secArr[curSec];
		else
			return(NULL);
	#endif
	
	if (pfd->sec[curSec] == NULL)
		return (NULL);
	
	(pfd->sec[curSec])->addr = sec;
	(pfd->sec[curSec])->numPage = 0;
	pfd->numSec++;

	for (i=0;i<MAX_PAGE;i++)
		(pfd->sec[curSec])->page[i] = NULL;
			
	return(pfd->sec[curSec]);
}

FLASH_PAGE* new_flash_page(FLASH_SEC* pfsec, U8 page)
{
	U16 i;
	
	U16 curPage = pfsec->numPage;
	
	#ifdef FD_DYNAMIC
		pfsec->page[curPage] = malloc(sizeof(FLASH_PAGE));
	#else
		if (pageArrPtr < MAX_TOTAL_PAGE)
			pfsec->page[curPage] = &pageArr[pageArrPtr++]; //pfsec->page[curPage] = &pageArr[pfsec->addr][curPage];
		else
			return(NULL);
	#endif
	
	(pfsec->page[curPage])->addr = page;
	(pfsec->page[curPage])->numByte = 0;
	
	//#ifdef INIT_PAGE_DATA
	for (i=0;i<256;i++)
		(pfsec->page[curPage])->data[i] = 0xAA;
	//#endif
	
	pfsec->numPage++;
	
	return(pfsec->page[curPage]);
}

void free_flash_data(FLASH_DATA* pfd)
{
	U32 i;
	
	if (pfd != NULL)
	{
		for(i=0;i<pfd->numSec;i++)
		{
			free_flash_sec( pfd->sec[i] );
			pfd->sec[i] = NULL;
			#ifndef FD_DYNAMIC
				secArrPtr--;
			#endif
		}
		
		
		pfd->numSec = 0;
		#ifdef FD_DYNAMIC
			free(pfd);
		#endif
	}
}

void free_flash_sec(FLASH_SEC* pfsec)
{
	U32 j;
	
	if (pfsec != NULL)
	{
		for(j=0;j<pfsec->numPage;j++)
		{
			#ifdef FD_DYNAMIC
				free( pfsec->page[j] );
			#else
				pageArrPtr--;	
			#endif
			
			pfsec->page[j] = NULL;
		}
	}
	
	
	pfsec->addr = 0;
	pfsec->numPage = 0;
	
	#ifdef FD_DYNAMIC
		free(pfsec);
	#endif
}

