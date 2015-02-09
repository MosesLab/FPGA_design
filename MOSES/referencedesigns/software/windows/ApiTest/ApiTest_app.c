/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			APITest_app.c
Description:	wrapper for APITest()
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-09-27	MF		Created
2009-03-19	MF		Cleanup include file ordering
2012-02-15	MF		Add function call to open device, formerly in subtests
*******************************************************************************/

// HEADERS
#include "ApiTest.h"

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
	//U8					bPass;
	U8					bVerbose = TRUE;
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

	bi.plxDeviceType = 0x9056;

	// Execute Test
	if 	(APITest(pDevice, BarIndex, bVerbose, &bi) == TRUE)
		printf("\n\n\n PASSED \n");
	else
		printf("\n\n\n FAILED \n");

    // Close the Device
    PlxPci_DeviceClose( &Device );

	CTIPause();
	exit(0);
}
