/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			DSTest.c
Description:	Direct Slave test
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-06-04	MF		Separate test() from main(), for use in one large test app
2008-09-27	MF		Add rotary switch test
2008-12-01	MF		Make LED message standout more
2008-12-02	MF		Add separate LED test, Move Rotary switch to main tester
2009-03-19	MF		Cleanup include file ordering
2012-02-16	MF		Use yesno_loop function
2012-09-07	MF		Add a 32k block ram read/write
 ******************************************************************************/

// HEADERS
#include "DSTest.h"

/*******************************************************************************
Function:		DSTest
Description:	Direct Slave Test
*******************************************************************************/
U8 DSTest(PLX_DEVICE_OBJECT *pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
    U32          i,j;
    U32         *pBufferDest;
    U32         *pBufferSrc;
    RETURN_CODE  rc;
	U8			bPass = FALSE;
	U32			dsAddr;
	U32			rValue;
//	char		selChar;
	U32			bufSz;
	U32			memLoc;

	if (bi->boardType == BOARD_TYPE_FCG011 || bi->boardType == BOARD_TYPE_FCG012)
	{
		bufSz = 32768;
		memLoc = 0x8000; // (bit 15 is on)
	}
	else
	{
		bufSz = SIZE_DS_BUFFER;
		memLoc = FPGA_MEMORY_LOC_0;
	}

	printf("Preparing buffers: ");

    pBufferDest = malloc(bufSz);
    if (pBufferDest == NULL)
    {
        printf("*ERROR* - Destination buffer allocation failed\n");
        return(bPass);
    }

    pBufferSrc  = malloc(bufSz);

    if (pBufferSrc == NULL)
    {
        printf("*ERROR* - Source buffer allocation failed\n");
        return(bPass);
    }

	printf("Ok\n");

	//////
	// this section used to read registers; but not write

	//////
	if (bi->boardType == BOARD_TYPE_FCG011 || bi->boardType == BOARD_TYPE_FCG012)
	{
		for (i=0; i < (bufSz >> 2); i++)
		{	pBufferSrc[i] = ((i & 0xFF) << 24) | ((i & 0xFFF) << 12) | (i & 0xFFF); }
	}
	else
	{
		for (i=0; i < (bufSz >> 2); i++)
		{	pBufferSrc[i] = (( 1 << (i+16) ) | (1 << i)); }
	}
		

    // Clear destination buffer
    memset(pBufferDest, 0, bufSz );
    printf("Ok\n");


    rc =  PlxPci_PciBarSpaceWrite(pDevice, BarIndex, memLoc, pBufferDest, bufSz, BitSize32, FALSE);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return(bPass);
    }

	printf("Writing %d bytes to Local Bus starting @ %x: ", bufSz, memLoc);
    rc =  PlxPci_PciBarSpaceWrite(pDevice, BarIndex, memLoc, pBufferSrc, bufSz, BitSize32, FALSE);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return(bPass);
    }

    printf("Ok\n");


	printf("Reading %d bytes from Local Bus starting @ %x: ", bufSz, memLoc);
    rc = PlxPci_PciBarSpaceRead(pDevice, BarIndex, memLoc, pBufferDest, bufSz, BitSize32, FALSE);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return(bPass);
    }
	else
	{
		printf("Ok\n");
	}

	printf("Verifying data: ");
    if (memcmp( pBufferSrc, pBufferDest, bufSz ) != 0)
    {
        printf("*ERROR* - Buffers do not match\n");
        return(bPass);
    }
	else
	{
		bPass = TRUE;
		printf("Ok\n");
	}
    
	printf("\nBase Addr Change:\n");
	for(j = 1; j<=8; j=j*2)
	{
		// Set direct slave  address all variations
		dsAddr=0;
		for(i=0;i<32;i=i+4)
			dsAddr |= ((j)<<i);

		printf("New DS Addr = %08x\n",dsAddr);

		rc = WriteDword(pDevice,SPI_BAR,FPGA_BASE_ADDR_0,dsAddr);
			if (rc != ApiSuccess) 	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}

		rValue = PlxPci_PlxRegisterRead(pDevice, PCI9056_SPACE0_REMAP, &rc);
			if (rc != ApiSuccess)	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}

		printf("Current DS Addr in FPGA [LASOBA] %08x\n",rValue);

		rValue &= 0x0000000F; // all but 3 downto 0 are cleared
		dsAddr &= 0xFFFFFFF0;
		dsAddr |= rValue;

		rc = PlxPci_PlxRegisterWrite(pDevice, PCI9056_SPACE0_REMAP, dsAddr);
			if (rc != ApiSuccess)	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}
		
		rc = WriteDword(pDevice, USR_BAR, FPGA_USER_LED, dsAddr);
			if (rc != ApiSuccess) 	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}

		rc = ReadDword(pDevice, USR_BAR, FPGA_USER_LED, &rValue);
			if (rc != ApiSuccess) 	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}

		if (rValue != dsAddr)
			{ printf("Error mismatch on read: expected %08x read %08x\n", dsAddr, rValue); bPass = FALSE; }
	}

	printf("Ok\n");

	printf("Freeing buffers: ");
    if (pBufferDest != NULL)
        free(pBufferDest);

    if (pBufferSrc != NULL)
        free(pBufferSrc);
    printf("Ok\n");

	return(bPass);
}


U8 LedTest(PLX_DEVICE_OBJECT *pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
    U32          i;
   // U32         *pBufferDest;
   // U32         *pBufferSrc;
    RETURN_CODE  rc;
	//U8			bPass = FALSE;
	//U32			dsAddr;
//	U32			rValue;
	char		selChar;

	printf("Writing to led register: ");

	for( i = 0; i <= 15; i++)
	{
		//pBufferSrc[0] = i;

		//rc =  PlxPci_PciBarSpaceWrite( pDevice, BarIndex, FPGA_USER_LED, pBufferSrc, 4, BitSize32, FALSE );
		rc = WriteDword(pDevice, USR_BAR, FPGA_USER_LED, i);

		CTISleep(250);
		if (rc != ApiSuccess)
		{
			printf("*ERROR* - API failed\n");
			PlxSdkErrorDisplay(rc);
			return(FALSE);
		}

	}

	selChar = yesno_loop("Did all the Leds turn-on?");
	if (selChar == 'n')
		return(FALSE);
	else
		return(TRUE);
}
