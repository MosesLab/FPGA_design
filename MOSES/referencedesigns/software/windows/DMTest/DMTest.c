/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			DMTest.c
Description:	Direct Master test program
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-04-02	MF		Test with larger memory space
2008-06-04	MF		Separate test() from main(), for use in one large test app
2009-03-11	MF		Move all header dependencies to DMTest.h
'			'		Change size to 63 dwords, max possible
2012-02-13	MF		Tweaked printf statements
*******************************************************************************/

// HEADERS
#include "DMTest.h"

/*******************************************************************************
Function:		DMTest
Description:	The main entry point
*******************************************************************************/
U8 DMTest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
    RETURN_CODE       rc;
    U32					i, tmp;
    U32					pciAddr;
    PLX_PHYSICAL_MEM	PciBuffer;
	U32*				pBufferDS;
	U32*				pBufferDM;
	U32					addrDiff;
#ifdef DM_USE_INTR
	PLX_INTERRUPT		PlxIntr;
	PLX_NOTIFY_OBJECT	PlxEvent;
#endif
	U32					rValue;
	U16					numBytes;
	U16					numDwords;
	U8					bPass = FALSE;

	// Clear interrupt structure, and enable local interrupt

#ifdef DM_USE_INTR
	memset(&PlxIntr, 0, sizeof(PLX_INTERRUPT));
	#if PLX_SDK_VERSION_MAJOR==5 && PLX_SDK_VERSION_MINOR==1
		PlxIntr.LocalToPci_1 = 1;	// Bit 11
	#else
		PlxIntr.LocalToPci = 1;	// Bit 11
	#endif
	//PlxIntr.PciMain = 1;		// Bit 8 -- should already been on

	rc = PlxPci_InterruptEnable(pDevice,&PlxIntr);		// sets PCI9056_INT_CTRL_STAT
		if (rc != ApiSuccess) 	{ 	if(bVerbose) PlxSdkErrorDisplay(rc); }
	// register for interrupt	

	rc = PlxPci_NotificationRegisterFor(pDevice,&PlxIntr, &PlxEvent);
		if (rc != ApiSuccess) 	{ 	if(bVerbose) PlxSdkErrorDisplay(rc); }

#endif

	tmp = PlxPci_PlxRegisterRead(pDevice, PCI9056_INT_CTRL_STAT, &rc);
//	if (rc != ApiSuccess) 	{ PlxSdkErrorDisplay(rc);	goto _Exit_App;	}

	if (bVerbose) printf("PCI9056_INT_CTRL_STAT (%x)= %8x\n", PCI9056_INT_CTRL_STAT, tmp);

	// Get a physical buffer
    PciBuffer.Size = (64 *1024) * 2;

	//rc = PlxPci_CommonBufferProperties(pDevice,&PciBuffer );
	rc = PlxPci_PhysicalMemoryAllocate(pDevice,&PciBuffer, FALSE);
	if (rc != ApiSuccess) 	{ 	if(bVerbose) PlxSdkErrorDisplay(rc);	}

	if (bVerbose) printf(
		"Buffer information:\n\tBus Physical Addr= %016llx\n\tCPU Physical Addr= %016llx\n\tSize= %d bytes\n",
		PciBuffer.PhysicalAddr,
		PciBuffer.CpuPhysical,
		PciBuffer.Size
	);

	// PLX only spec PCI addresses in 65,536 (64K) chuncks
	pciAddr = ( (U32)PciBuffer.PhysicalAddr & 0xFFFF0000 ) + 0x00010000;

	// Remember the address diff; hopefully it isn't outside of address space
	addrDiff = pciAddr - (U32)PciBuffer.PhysicalAddr;

	if (bVerbose) printf("\tDM Address Start=%x\n", pciAddr);

	// Set memory contents
	numDwords = 63;
	numBytes = numDwords * 4;

	pBufferDS  = malloc(numBytes);
    
	// Write contents to memory
	printf("\nWriting test data (%d bytes)to FPGA memory: ", numBytes);

	for (i = 0; i < numDwords; i++)
	{
		tmp = 0xD4DE5500 + i;
		pBufferDS[i] = tmp;
		//Cons_printf("%d: %08x\n",i,tmp );
	}	

	printf("OK");

	rc = PlxPci_PciBarSpaceWrite(pDevice,USR_BAR,FPGA_MEMORY_LOC_0,pBufferDS,numBytes,BitSize32,FALSE);
	if (rc != ApiSuccess) 	{	if (bVerbose)  PlxSdkErrorDisplay(rc);	}

	// Read contents from memory
	memset(pBufferDS,0,numBytes);
	rc = PlxPci_PciBarSpaceRead(pDevice,USR_BAR,FPGA_MEMORY_LOC_0,pBufferDS,numBytes,BitSize32,FALSE);
	if (rc != ApiSuccess) 	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}
	
	printf("\nReading back FPGA memory contents: ");

	for (i = 0; i < numDwords; i++)
	{
		//Cons_printf("%d: %08x\n",i,pBufferDS[i] );

		if (0xD4DE5500 + i != pBufferDS[i])
				if (bVerbose) printf("!Error !");
	}	
	
	printf("OK");

	// Setup buffer to physical memory
	// Map memory into virtual address space
	rc =  PlxPci_PhysicalMemoryMap(pDevice, &PciBuffer ); 
	if (rc != ApiSuccess) 	{ PlxSdkErrorDisplay(rc);	}

	//Cons_printf("\tVirtual Address=%x\n", PciBuffer.UserAddr); //(PLX_UINT_PTR)PciBuffer.UserAddr);

	pBufferDM = (U32*)((PLX_UINT_PTR)PciBuffer.UserAddr + addrDiff);

	printf("\nVerify physical mem buffer contents empty: ");

	for (i = 0; i < numDwords; i++)
	{
		//Cons_printf("%d: %08x\n",i,pBufferDM[i] );
		if (pBufferDM[i] != 0x0)
				if (bVerbose) printf("!Error!");
	}

	printf("OK");

	// Setup the direct master write operation
	printf("\nSetup direct master write: ");
	
	rc = FPGADMSetup(pDevice,pciAddr,0x00010000,numDwords,DM_OP_WRITE);
	if (rc != ApiSuccess) 	{ 	if(bVerbose) PlxSdkErrorDisplay(rc);	}

	printf("OK");

	// Wait for operation to complete
	printf("\nWait for transfer to complete: ");

#ifdef DM_USE_INTR

	rc = PlxPci_NotificationWait(pDevice, &PlxEvent, 5000); // wait for 5000 seconds
	if (rc != ApiSuccess) 	{ 	if(bVerbose) PlxSdkErrorDisplay(rc);	}
#else
	xxxxxxxx

	do
	{
		CTISleep(250);
			rc = ReadDword(&Device,USR_BAR,FPGA_INTERRUPT_SOURCE,&rValue);

			if (rc != ApiSuccess)
			{
				printf("*ERROR* - API failed\n");
				PlxSdkErrorDisplay(rc);
			}
	}
	while ( rValue==0 );

	//rc = ApiSuccess;
#endif

	switch (rc)
	{
		case ApiSuccess:
			
			printf("OK");

			// Interrupt occurred
			// Read FPGA interrupt source
			rc = ReadDword(pDevice,USR_BAR,FPGA_INTERRUPT_SOURCE,&rValue);
			if (rc != ApiSuccess) 	{ 	if(bVerbose) PlxSdkErrorDisplay(rc);	}

			if (rValue & INTERRUPT_DM)
			{
				// read and set interrupt mask
				rc = FPGAIntMask(pDevice,INTERRUPT_DM);
				if (rc != ApiSuccess) 	{ 	if(bVerbose) PlxSdkErrorDisplay(rc);	}

				CTISleep(250);

				// Check if Local interrupt cleared.
				tmp = PlxPci_PlxRegisterRead(pDevice, PCI9056_INT_CTRL_STAT, &rc);

				if ( tmp & INTCSR_LINT_ACTIVE )
				{
					if (bVerbose) printf("\n\tLocal interrupt still active");
				}
				
				// read buffer
				printf("\nCompare Buffer contents: ");

				bPass = TRUE;
				for (i = 0; i < numDwords; i++)
				{
					if ( pBufferDS[i] != pBufferDM[i] )
					{
						if (bVerbose) printf("\n\tMismatch %d: %08x %08x",i,pBufferDS[i],pBufferDM[i] );
						bPass = FALSE;
					}
				}

				printf("OK");

					// Read contents from memory
					/*
					memset(pBufferDS,0,numBytes);
					rc = PlxPci_PciBarSpaceRead(&Device,USR_BAR,FPGA_MEMORY_LOC_0,pBufferDS,numBytes,BitSize32,FALSE);
					if (rc != ApiSuccess) 	{ PlxSdkErrorDisplay(rc);	}
					
					Cons_printf("Directly read back FPGA memory contents: ");

					for (i = 0; i < numDwords; i++)
					{
						//Cons_printf("%d: %08x\n",i,pBufferDS[i] );
					}	

					printf("Done");*/

				// Ack the interrupt
				rc = WriteDword(pDevice,USR_BAR,FPGA_DM_CTRL,0x0);
				if (rc != ApiSuccess) 	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}

				// unmask interrupt
				rc = FPGAIntUnMask(pDevice,INTERRUPT_DM);
				if (rc != ApiSuccess) 	{ 	if (bVerbose) PlxSdkErrorDisplay(rc);	}

			}
			else
			{
				if (bVerbose) printf("Interrupt source = %x\n", rValue);
			}
			break;
		case ApiWaitTimeout:
			printf("*ERROR* - API failed, Timeout waiting for Interrupt Event\n");
			bPass = FALSE;
			break;
		case ApiWaitCanceled:
		case ApiFailed:
		default:
			printf("*ERROR* - API failed, Failed while waiting for interrupt\n");
			bPass = FALSE;
			break;
	}

#if 0
	Cons_printf("Change buffer\n");

	memset(pBufferDS,0,16*4);

	// Change buffer contents
	for (i = 0; i < 16; i++)
	{
		tmp = 0xBABE0000 + i;
		//Cons_printf("%d: %8x\n",i,tmp );
		pBufferDM[i] = tmp;
	}

	Cons_printf("  Setup direct master read\n ");

	rc = PlxPci_InterruptEnable(&Device,&PlxIntr);		// sets PCI9056_INT_CTRL_STAT
	
	if (rc != ApiSuccess) 
	{
		Cons_printf("*ERROR* - API failed, Unable to enable interrupts\n");
        PlxSdkErrorDisplay(rc);
		goto _Exit_App;
	}


	// shouldn't have to do again. rc = PlxPci_NotificationRegisterFor(&Device,&PlxIntr, &PlxEvent);

	rc = FPGADMSetup(&Device,pciAddr,0x00010000,0x10,DM_OP_READ);
	if (rc != ApiSuccess)
	{
		Cons_printf("*ERROR* - API failed\n");
		PlxSdkErrorDisplay(rc);
	}

	// Wait for operation to complete
	Cons_printf("Wait for transfer to complete\n");
	//Sleep(2000);

	// Wait for interrupt
	rc = PlxPci_NotificationWait(&Device, &PlxEvent, 5000); // wait for 5000 seconds
	switch (rc)
	{
		case ApiSuccess:
			// Read FPGA interrupt source
			rc = ReadDword(&Device,USR_BAR,FPGA_INTERRUPT_SOURCE,&rValue);

			if (rc != ApiSuccess)
			{
				Cons_printf("*ERROR* - API failed\n");
				PlxSdkErrorDisplay(rc);
			}

			if (rValue & INTERRUPT_DM)
			{
				// mask interrupt
				rc = FPGAIntMask(&Device,INTERRUPT_DM);

				if (rc != ApiSuccess)
				{
					Cons_printf("*ERROR* - API failed\n");
					PlxSdkErrorDisplay(rc);
				}

				Sleep(250);

				// Check if Local interrupt cleared.
				tmp = PlxPci_PlxRegisterRead(&Device, PCI9056_INT_CTRL_STAT, &rc);

				if ( tmp & INTCSR_LINT_ACTIVE )
				{
					Cons_printf("Local interrupt still active");
				}
				
				// read buffer
				
				Cons_printf("Reading FPGA memory directly\n");

				rc = PlxPci_PciBarSpaceRead(&Device,USR_BAR,FPGA_MEMORY_LOC_0,pBufferDS,16*4,BitSize32,FALSE);

				Cons_printf("Compare Buffer contents\n");

				for (i = 0; i < 16; i++)
				{
					tmp = 0xBABE0000 + i;
					if ( pBufferDS[i] != tmp )
						Cons_printf("Mismatch %d: %08x %08x\n",i,pBufferDS[i],tmp );
				}

				// Ack the interrupt
				rc = WriteDword(&Device,USR_BAR,FPGA_DM_CTRL,0x0);

				// unmask interrupt
				rc = FPGAIntUnMask(&Device,INTERRUPT_DM);

				if (rc != ApiSuccess)
				{
					Cons_printf("*ERROR* - API failed\n");
					PlxSdkErrorDisplay(rc);
				}
			}
			else
			{
				Cons_printf("Interrupt source = %x\n", rValue);
			}
			break;
		case ApiWaitTimeout:
			Cons_printf("*ERROR* - API failed, Timeout waiting for Interrupt Event\n");
			break;
		case ApiWaitCanceled:
		case ApiFailed:
		default:
			Cons_printf("*ERROR* - API failed, Failed while waiting for interrupt\n");
			break;
	}
#endif

#ifdef DM_USE_INTR
	// Disable the interrupt
	rc = PlxPci_InterruptDisable(pDevice,&PlxIntr);		// sets PCI9056_INT_CTRL_STAT
#endif

	// Unmap the memory
	rc =  PlxPci_PhysicalMemoryUnmap(pDevice, &PciBuffer ); 

    if (rc != ApiSuccess)
    {
       // printf("*ERROR* - API failed\n");
       if (bVerbose) PlxSdkErrorDisplay(rc);
    }

	rc = PlxPci_PhysicalMemoryFree(pDevice,&PciBuffer);
	//RETURN_CODE PlxPci_PhysicalMemoryFree(     PLX_DEVICE_OBJECT *pDevice,     PLX_PHYSICAL_MEM  *pMemoryInfo     );

	if (rc != ApiSuccess)
    {
        //printf("*ERROR* - API failed\n");
        if (bVerbose) PlxSdkErrorDisplay(rc);
        //return;
    }

    // Release user buffer
    if (pBufferDS != NULL)
        free(pBufferDS);

	// Return result

	return(bPass);
}

