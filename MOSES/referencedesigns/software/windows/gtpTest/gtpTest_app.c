/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			gtpTest_app.c
Description:	wrapper for gtpTest()
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-07-30	MF		Created
2009-01-12	MF		Allow test to run until keyboard is hit
2009-03-19	MF		Cleanup include file ordering
*******************************************************************************/

/*===============
  HEADERS
===============*/
#include "gtpTest.h"

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
	U8					bVerbose = FALSE;
	U32					cnt;
	U8					bResult = TRUE;
	boardInfo			bi;

    // Get the device....
	pDevice = &Device;

	rc = GetAndOpenDevice(pDevice, 0x9056);

	if (rc != ApiSuccess)
    {
        //printf("*ERROR* - API failed, unable to open PLX Device\n");
        PlxSdkErrorDisplay(rc);
        exit(-1);
    }

    // Set PCI BAR to use
    BarIndex = 2;

	cnt=0;
	// Execute Test
//	while(!kbhit() && bResult)
	{
		printf("\n* #%5d ---------------------------------------------",cnt);
		bResult = gtpTest(pDevice, BarIndex, bVerbose,&bi);
		CTISleep(10);
		cnt++;
	}

//	gtpScan(pDevice, BarIndex, bVerbose);

    // Close the Device
    PlxPci_DeviceClose( &Device );

    //_Pause;
    //Cons_printf("\n\n");
    //ConsoleEnd();

	printf("\n\n[COMPLETE - PRESS ENTER TO QUIT]");
	getch();

	if (rc != ApiSuccess)
		exit(-1);
	else
		exit(0);

}

