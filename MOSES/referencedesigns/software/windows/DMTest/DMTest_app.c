/*******************************************************************************
Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			DMTest_app.c
Description:	wrapper for DMTest()
********************************************************************************
Date		Rev		Author	Modifications
--------------------------------------------------------------------------------
2008-06-04	0.00	MF		Created
*******************************************************************************/

// HEADERS
#include "DMTest.h"

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
	U8 bPass = TRUE;
	int testCnt;

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

	// Execute Test
	for( testCnt = 0; bPass && testCnt < 100; testCnt++ )
		bPass = DMTest(pDevice, BarIndex, bVerbose, &bi); 

    // Close the Device
    PlxPci_DeviceClose( &Device );

	CTIPause();

	if (rc != ApiSuccess)
		exit(-1);
	else
		exit(0);

}

