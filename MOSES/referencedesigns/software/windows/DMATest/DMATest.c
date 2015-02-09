/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:	FreeForm/PCI-104
Module:		DMATest.c
Description:	Test built-in DMA capabilities of the PLX bridge
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2009-03-19	MF	Cleanup include file ordering
2010-01-27	MF	Add more debug statements, convert to unix EOL format
2012-02-13	MF	Fixed 64 bit printfs
 ******************************************************************************/

// HEADERS
#include "DMATest.h"

/*******************************************************************************
Function:		DMATest
Description:	
*******************************************************************************/
U8 DMATest(PLX_DEVICE_OBJECT *pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
    U32          i;
    U32*		pBufferRd;
    U32*		pBufferWr;
	U32*		pBufferMem;			
    RETURN_CODE  rc;
	U8			bPass = FALSE;
//	U32			dsAddr;
//	U32			rValue;
//	char		selChar;
	PLX_DMA_PROP DmaProp; 
	PLX_DMA_PARAMS   DmaParams; 
    PLX_PHYSICAL_MEM PciBuffer; 
	U8            dmaCh = 0;
	void**		pVa;

	printf(	"-------------------------------------\n"
			"Init\n"
			"-------------------------------------\n");

	printf("\nPreparing buffers: ");

    pBufferRd = malloc(SIZE_DS_BUFFER);
    if (pBufferRd == NULL)
    {
        printf("*ERROR* - Destination buffer allocation failed");
        return(FALSE);
    }

	memset(pBufferRd, 0, SIZE_DS_BUFFER );
//
    pBufferWr  = malloc(SIZE_DS_BUFFER);

    if (pBufferWr == NULL)
    {
        printf("*ERROR* - Source buffer allocation failed");
        return(FALSE);
    }

	memset(pBufferWr, 0, SIZE_DS_BUFFER );
//
	pBufferMem  = malloc(SIZE_DS_BUFFER);

    if (pBufferMem == NULL)
    {
        printf("*ERROR* - Source buffer allocation failed");
        return(FALSE);
    }

	memset(pBufferMem, 0, SIZE_DS_BUFFER );
//
printf("OK");


//	printf("Reading Data from Local Bus: 0x00 -> 0x3C: \n");
//    rc = PlxPci_PciBarSpaceRead(pDevice, BarIndex, 0x0, pBufferRd, SIZE_DS_BUFFER, BitSize32, FALSE);

//	memset(pBufferRd, 0, SIZE_DS_BUFFER );
//	printf("Reading Data from Local Bus: 0x40 -> 0x7C: \n");
 //rc = PlxPci_PciBarSpaceRead(pDevice, BarIndex, 0x40, pBufferRd, SIZE_DS_BUFFER, BitSize32, FALSE);

	//////
printf("\nPreparing random data for source buffer: ");
    for (i=0; i < (SIZE_DS_BUFFER >> 2); i++)
        pBufferWr[i] = (( 1 << (i+16) ) | (1 << i));

    // Clear destination buffer
    
    printf("OK");

	printf("\nWriting Data to Local Bus starting @ %x: ", FPGA_MEMORY_LOC_0);
    rc =  PlxPci_PciBarSpaceWrite(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferWr, SIZE_DS_BUFFER, BitSize32, FALSE);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return(bPass);
    }

    printf("OK");


	printf("\nReading Data from Local Bus starting @ %x: ", FPGA_MEMORY_LOC_0);
    rc = PlxPci_PciBarSpaceRead(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferRd, SIZE_DS_BUFFER, BitSize32, FALSE);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return(FALSE);
    }
	else
	{
		printf("OK");
	}

	printf("\nVerifying data written to FPGA: ");
    if (memcmp( pBufferWr, pBufferRd, SIZE_DS_BUFFER ) != 0)
    {
        printf("*ERROR* - Buffers do not match\n");
        return(FALSE);
    }
	else
	{
		bPass = TRUE;
		printf("OK");
	}
	
	CTIPause();

	printf(	"-------------------------------------\n"
			"DMA Setup\n"
			"-------------------------------------\n");

	printf("\nOpening DMA Channel: ");
 
    // Clear DMA properties 
    memset(&DmaProp, 0, sizeof(PLX_DMA_PROP)); 
 
    // Setup DMA configuration structure 
    DmaProp.ReadyInput    = 1;     // Enable READY# input 
    DmaProp.Burst         = 1;     // Use burst of 4LW 
    DmaProp.LocalBusWidth = 3;     // 2 is indicates 32 bit in API pdf, but is 3 in sample code? 
 
	// Use Channel 0 
    rc = PlxPci_DmaChannelOpen( pDevice, dmaCh, &DmaProp );
		if (rc != ApiSuccess){printf("*ERROR* - API failed\n"); PlxSdkErrorDisplay(rc); return(FALSE);}

	printf("OK"); 
 
	//
	printf("\nGet common buffer properties: ");
    // Get Common buffer information 
    rc = PlxPci_CommonBufferProperties(  pDevice, &PciBuffer ); 
		if (rc != ApiSuccess){printf("*ERROR* - API failed\n"); PlxSdkErrorDisplay(rc); return(FALSE);}
 
	printf("OK");

	printf( "\n	Common buffer information:\n"
			"     Bus Physical Addr:  %016llx\n"
			"     CPU Physical Addr:  %016llx\n" 
			"     Size             :  %d bytes\n", 
				PciBuffer.PhysicalAddr, 
				PciBuffer.CpuPhysical, 
				PciBuffer.Size         );

	printf("\nMapping common buffer to virtual space: ");
	// Map the buffer into user space 

	pVa = (void**)&pBufferMem;
		//pVa = A pointer to a buffer to hold the virtual address 
    rc = PlxPci_CommonBufferMap(pDevice, pVa ); 
		if (rc != ApiSuccess){printf("*ERROR* - API failed\n"); PlxSdkErrorDisplay(rc); return(FALSE);}



	printf("OK");
	CTIPause();

	printf(	"-------------------------------------\n"
			"Transfer FPGA TO MEM\n"
			"-------------------------------------\n");	

    // Fill in DMA transfer parameters 
#if PLX_SDK_VERSION_MAJOR==5 && PLX_SDK_VERSION_MINOR==1
    DmaParams.u.PciAddrLow  = (U32)PciBuffer.PhysicalAddr; 
	DmaParams.PciAddrHigh   = 0x0; 
    DmaParams.LocalAddr     = FPGA_MEMORY_LOC_0; 
    DmaParams.ByteCount = SIZE_DS_BUFFER; 
    DmaParams.LocalToPciDma = 1;   // FPGA to physical mem
#else
	DmaParams.PciAddr  = PciBuffer.PhysicalAddr; 
	DmaParams.LocalAddr     = FPGA_MEMORY_LOC_0; 
    DmaParams.ByteCount = SIZE_DS_BUFFER; 
    DmaParams.Direction = PLX_DMA_LOC_TO_PCI;
#endif
	//
	printf("\nPerforming block transfer, FPGA -> MEM: ");
    rc = PlxPci_DmaTransferBlock( pDevice, dmaCh,&DmaParams,(3 * 1000) );
 
    if (rc != ApiSuccess) 
    { 
        if (rc == ApiWaitTimeout) 
		{
            // Timed out waiting for DMA completion 
			printf("Timeout"); return(FALSE);
		}
        else 
		{
			printf("*ERROR* - API failed\n"); PlxSdkErrorDisplay(rc); return(FALSE);
		}
    }

	printf("OK");

	//
	printf("\nVerifying transferred data: ");

		printf("\n#  FPGA      MEM");
		for (i=0; i < (SIZE_DS_BUFFER >> 2); i++)
			printf("\n%2d: %8x %8x",i,pBufferWr[i],pBufferMem[i]);
	
		printf("\n");

    if (memcmp( pBufferWr, pBufferMem, SIZE_DS_BUFFER ) != 0)
    {
        printf("*ERROR* - Buffers do not match\n");
        return(FALSE);
    }
	else
	{
		bPass = TRUE;
		printf("OK");
	}

	CTIPause();
	
	printf(	"-------------------------------------\n"
			"Trasnsfer MEM to FPGA\n"
			"-------------------------------------\n");
			
	//
	printf("\nClearing buffers: ");
	memset(pBufferRd, 0, SIZE_DS_BUFFER );
	memset(pBufferWr, 0, SIZE_DS_BUFFER );
	memset(pBufferMem, 0, SIZE_DS_BUFFER );
	printf("OK");

	//
	printf("\nClearing FPGA block mem: ");
	rc =  PlxPci_PciBarSpaceWrite(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferWr, SIZE_DS_BUFFER, BitSize32, FALSE);
	printf("OK");

	//
	printf("\nLoading physical memory with random data: ");

	for (i=0; i < (SIZE_DS_BUFFER >> 2); i++)
        pBufferMem[i] = 0x00BB00AA | i<<8 | i<<24;


    // Fill in DMA transfer parameters 
#if PLX_SDK_VERSION_MAJOR==5 && PLX_SDK_VERSION_MINOR==1
    DmaParams.LocalToPciDma = 0;   
#else	
	DmaParams.Direction = PLX_DMA_PCI_TO_LOC;
#endif
 
	//
	printf("\nPerforming block transfer, MEM -> FPGA: ");
    rc = PlxPci_DmaTransferBlock( pDevice, dmaCh,&DmaParams,(3 * 1000) );
 
    if (rc != ApiSuccess) 
    { 
        if (rc == ApiWaitTimeout) 
		{
            // Timed out waiting for DMA completion 
			printf("Timeout"); return(FALSE);
		}
        else 
		{
			printf("*ERROR* - API failed\n"); PlxSdkErrorDisplay(rc); return(FALSE);
		}
    }

	printf("OK");

	//
	printf("\nReading Data from Local Bus starting @ %x: ", FPGA_MEMORY_LOC_0);
    rc = PlxPci_PciBarSpaceRead(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferRd, SIZE_DS_BUFFER, BitSize32, FALSE);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return(FALSE);
    }
	else
	{
		printf("OK");
	}

	//
	printf("\nVerifying transferred data: ");

		printf("\n#  MEM      FPGA");
		for (i=0; i < (SIZE_DS_BUFFER >> 2); i++)
			printf("\n%2d: %8x %8x",i,pBufferMem[i],pBufferRd[i]);

		printf("\n");

    if (memcmp( pBufferRd, pBufferMem, SIZE_DS_BUFFER ) != 0)
    {
        printf("*ERROR* - Buffers do not match\n");
        return(FALSE);
    }
	else
	{
		bPass = TRUE;
		printf("OK");
	}
	
	
	CTIPause();
	
	printf(	"-------------------------------------\n"
			"Cleanup\n"
			"-------------------------------------\n");	

	//
	printf("\nUnmapping virtual buffer: ");
	rc = PlxPci_CommonBufferUnmap( pDevice, pVa );
		if (rc != ApiSuccess){printf("*ERROR* - API failed\n"); PlxSdkErrorDisplay(rc); return(bPass);}

	printf("OK");


	printf("\nClosing DMA Channel: "); 
    rc = PlxPci_DmaChannelClose(pDevice, dmaCh); 
 
    if (rc != ApiSuccess) 
    { 
		printf("API Failed, attempting to reset PLX device");

        // Reset the device if a DMA is in-progress 
        if (rc == ApiDmaInProgress) 
        { 
            PlxPci_DeviceReset(pDevice); 
 
            // Attempt to close again 
            PlxPci_DmaChannelClose(pDevice, 0); 

			return(bPass);
        } 
    } 

	printf("OK");


	printf("\nFreeing buffers: ");
    if (pBufferRd != NULL)
        free(pBufferRd);

    if (pBufferWr != NULL)
        free(pBufferWr);
    printf("OK\n");

	printf("Finished");
	return(bPass);
}
