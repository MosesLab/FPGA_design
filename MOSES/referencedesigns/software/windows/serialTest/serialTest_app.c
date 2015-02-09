/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			serialTest_app.c
Description:	wrapper for serialTest()
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-06-04	MF		Created
2008-12-01	MF		Corrected GetAndOpenDevice call
2009-03-19	MF		Cleanup include file ordering
*******************************************************************************/

/*===============
  HEADERS
===============*/
#include "serialTest.h"

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
	U8					bResult = TRUE;
	U32					i;
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

	// Execute Test
	i=0;
	//while (!kbhit() && bResult)
	{
		printf("\n * Iteration %d -----------------------------------------------------",i);
		serialTestBothDir( pDevice, BarIndex, bVerbose, &bi );
		i++;
	}	

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

