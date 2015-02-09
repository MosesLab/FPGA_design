/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			SPITest_app.c
Description:	Programs flash and verifies contents in a loop
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-12-01	MF		Re-defined functionality
2009-03-19	MF		Cleanup include file ordering
*******************************************************************************/

/*===============
  HEADERS
===============*/
#include "SPIProgram.h"


#define _USE_32BIT_TIME_T

/*******************************************************************************
Function:		main
Description:	The main entry point
*******************************************************************************/
int main( void )
{
    RETURN_CODE			rc;
    PLX_DEVICE_OBJECT	Device;
	PLX_DEVICE_OBJECT*	pDevice;
    U8					BarIndex;
	U8					bVerbose = TRUE;
	boardInfo			bi;
	U8 bPass = FALSE;

	time_t				tstart;
	time_t				tend;
//	char				timebuf[26];
	U32					rVal;
	U8					i;

    // Get the device....
	pDevice = &Device;

	rc = GetAndOpenDevice(pDevice,0x9056);

	if (rc != ApiSuccess)
    {
        //printf("*ERROR* - API failed, unable to open PLX Device\n");
        PlxSdkErrorDisplay(rc);
        exit(-1);
    }

    // Set PCI BAR to use
    BarIndex = 2;
	
	SPITest(pDevice, BarIndex, bVerbose, &bi);
/*
for (i=0; i < 6; i++)
{
	rc = WriteDword (pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);
		if (rc != ApiSuccess) return(FALSE);

	rc = ReadDword (pDevice,USR_BAR,FPGA_REV,&rVal);
		if (rc != ApiSuccess) return(FALSE);

	printf("\n==========================================================================");
	printf("\nProgramming and verifying flash #%d, with FPGA revision: %x",i, rVal);
	printf("\n==========================================================================");
	//readFlash(plxPtr,rbFile, pfinfo);
	//bPass = verifyFlash(plxPtr, "C:\\FreeFormPCI104\\fpga_2_1_0\\ref_design_lxt_GPIO25_revc.mcs");

	time(&tstart);
    printf( "\nTime and date: %s", ctime(&tstart) );

	bPass = progAndRb(pDevice, FPGA_FLASH, "C:\\FreeFormPCI104\\fpga\\ise_10-1_projects\\ref_design_fcg003rd\\ref_design_fcg003rd.mcs",NULL, &finfoTbl[0],TRUE, TRUE, TRUE);

	time(&tend);
	printf("\nTime and date: %s", ctime(&tend) );
	printf("\nElapsed time =  %ld - %ld = %ld", (U32)tend, (U32)tstart,(U32)(tend-tstart) );
	
	if (bPass == FALSE)
	{
		printf("\n\nFAILED: verification found mismatch.");
		CTIPause();
	}

	rc = ReadDword (pDevice,USR_BAR,FPGA_REV,&rVal);
		if (rc != ApiSuccess) return(FALSE);

	printf("\nFPGA revision: %x",rVal);
}
*/
    // Close the Device
    PlxPci_DeviceClose( &Device );

	CTIPause();

	if (rc != ApiSuccess)
		exit(-1);
	else
		exit(0);

}
