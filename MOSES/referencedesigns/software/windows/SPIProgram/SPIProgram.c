/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			SPIProgram.c
Description:	Tests the SPI Flash
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-04-29	MF		Add SPI select register, flash info table
2008-06-04	MF		Separate test() from main(), for use in one large test app
2008-08-25	MF		Change all exit() to return(), add retry on signature read
2008-12-01	MF		All SPI functions use interrupts, add bulk erase step when 
					programming
2008-12-02	MF		progAndRb, pass device pointer to interface functions
2009-03-19	MF		Cleanup include file ordering
2009-07-27	MF		spiTest to check for two different ids for flash A
					progAndRb no longer requires flash info
2010-09-02	MF		Added check for spansion flash
2012-02-13	MF		Linux compilation fixes
2012-09-07	MF		Add delay after FPGA resets
*******************************************************************************/

/*====================
HEADERS
====================*/
#include "SPIInterface.h" 
#include "SPIProgram.h"

	// Program and Readback
	//printf("\n-----------------------------------------------");
	//progAndRb(plxPtr,FPGA_FLASH, "m25p16_test.mcs", "m25p16_rb.mcs", &finfoTbl[0], FALSE, FALSE);
	//printf("\n-----------------------------------------------");
	//progAndRb(plxPtr,SW_FLASH,   "m25p64_test.mcs", "m25p64_rb.mcs", &finfoTbl[1], FALSE, FALSE);	
	
/*******************************************************************************
Function:		SPITest
Description:	Test for both SPI flashes
*******************************************************************************/
U8 SPITest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
    RETURN_CODE       rc;
	U32 rVal;
	PLX_PTR				plxPtr;
	PLX_INTERRUPT		plxIntr;
	PLX_NOTIFY_OBJECT	plxEvent;
	U8 bPass = TRUE;

	#ifdef USE_INTR
		// Clear interrupt structure, and enable local interrupt
		memset(&plxIntr, 0, sizeof(PLX_INTERRUPT));
		#if PLX_SDK_VERSION_MAJOR == 5 && PLX_SDK_VERSION_MINOR == 1
			plxIntr.LocalToPci_1 = 1;	// Bit 11
		#else
			plxIntr.LocalToPci = 1;	// Bit 11
		#endif
		//PlxIntr.PciMain = 1;		// Bit 8 -- should already been on

		// register for interrupt	
		printf("\nRegistering Interrupt: ");
		rc = PlxPci_NotificationRegisterFor(pDevice,&plxIntr, &plxEvent);
			if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }

		printf("OK\n");
	
	#endif

	plxPtr.pDevice = pDevice;
	plxPtr.pInterrupt = &plxIntr;
	plxPtr.pEvent = &plxEvent;
/*	if (argc < 3)
	{
		printf("Specify base address and programming file\n");
		return 1;
	}
*/

	rc = WriteDword (plxPtr.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);
		if (rc != ApiSuccess) return(FALSE);

	// Perform Loopback
	printf("\nLoopback Value (0xAB): ");
	rc = loopback(pDevice, 0xAB, &rVal);
	if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

	if (rVal == 0xAB)
		printf("Success");
	else
	{
		printf("Failure, read %x", rVal);
		return (FALSE);
	}

	// Flash Test
	printf("\n-----------------------------------------------");
	bPass = bPass & InitFlashTest(plxPtr, FPGA_FLASH, &finfoTbl[M25P16], &finfoTbl[M25P32]);
	printf("\n-----------------------------------------------");
	
	if ( (InitFlashTest(plxPtr, SW_FLASH, &finfoTbl[M25P64], NULL) ) == FALSE )
	{	
		printf("\nFailed to find ST M25P64, retrying with Spansion cross");
		bPass = bPass & InitFlashTest(plxPtr, SW_FLASH, &finfoTbl[S25FL064], NULL);
	}

	#ifdef USE_INTR
	printf("\nUn-registering Interrupt: ");
	rc = PlxPci_NotificationCancel( pDevice, &plxEvent);
		if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }

		printf("OK\n");
	#endif


	return(bPass);
}

/*******************************************************************************
Function:		InitFlashTest
Description:	Verifies flash signature, ID, initial formating, write and read
*******************************************************************************/
U8 InitFlashTest(PLX_PTR plxPtr, U8 flashSel, st_flash_info* pfinfoA, st_flash_info* pfinfoB) 
{
	RETURN_CODE       rc;
	U16 i, j;
	U8 testSectorNum;
	U8 testPageNum;
	U8 dataBuf[SIZE_PAGE_BUFFER];
	U32* pdataBuf = (U32*)(&dataBuf);
	U8 bOk;
	//U8 firstsec = 0;
	U32 rVal;
	U8 retry;
//	U8 ansChar;
	st_flash_info* pfinfo;

	// Selecting Flash

	printf("\nTesting flash %d\n", flashSel);
/*	printf("\nContinue: y or n: ");

	ansChar = getch();

	if (ansChar != 'y' && ansChar != 'Y')
		return;*/

	rc = WriteDword(plxPtr.pDevice, 3, FPGA_SPI_SEL, flashSel);
		if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }

	// Read Signature
	printf("\nRead Signature: " );

	pfinfo = NULL;
	for(retry=0;retry<4;retry++)
	{
		rc = readSignature(plxPtr, &rVal);
			if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

		if (rVal == pfinfoA->sig)
		{
			printf("Success");
			pfinfo = pfinfoA;
			retry = 4;
		}
		else if(pfinfoB != NULL)
		{
			if (rVal == pfinfoB->sig)
			{
				printf("Success");
				pfinfo = pfinfoB;
				retry = 4;
			}
		}
	}

	if (pfinfo == NULL)
	{
		printf("Failure, read %x", rVal);
		return(FALSE);
	}

	//printf("\n[PRESS ENTER TO CONTINUE]");
	//xgetch();

	// Read ID
	printf("\nRead ID (%x): ", pfinfo->id);
	rc = readID(plxPtr, &rVal );
		if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

	if (rVal == pfinfo->id)
		printf("Success");
	else
	{
		printf("Failure, read %x", rVal);
	return(FALSE);
	}

	//printf("\n[PRESS ENTER TO CONTINUE]");
	//xgetch();

	// Verifying page is erased
	printf("\nReading first page 00|00|00, is 0xFF? : ");

	rc = readPage(plxPtr,0,0,0,pdataBuf);
	if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

	bOk = TRUE;
	for (i = 0; (i < 16) && (bOk == TRUE); i++)
	{
		//printf("%02x:",i*16);
		for (j = 0; (j < 16) && (bOk == TRUE); j++)
		{
			//printf("%02x", dataBuf[i*16+j]);
			if (dataBuf[i*16+j] != 0xFF)
				bOk = FALSE;
		}
		//printf("\n");
	}

	if (bOk == TRUE)
		printf("Yes");
	else
	{
		printf("No");
		//return(FALSE);
	}
	
	//printf("\n[PRESS ENTER TO CONTINUE]");
	//xgetch();


	// Erase Sector
	testSectorNum = pfinfo->numSec-1;
	testPageNum = 0x11;
	printf("\nErasing Sector %x: ", testSectorNum);

	rc = eraseSector(plxPtr,testSectorNum);
	if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

	printf("Success");

	//xgetch();

	// Verifying page is erased
	printf("\nVerify page %x|%x|00 erased: ", testSectorNum,testPageNum);

	rc = readPage(plxPtr,testSectorNum,testPageNum,0,pdataBuf);
	if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

	bOk = TRUE;
	for (i = 0; (i < 16) && (bOk == TRUE); i++)
	{
		for (j = 0; (j < 16) && (bOk == TRUE); j++)
		{
			//printf("%x ", dataBuf[i*16+j]);
			if (dataBuf[i*16+j] != 0xFF)
				bOk = FALSE;
		}
	}

	if (bOk == TRUE)
		printf("Success");
	else
	{
		printf("Failure, at byte %d", i*j);
		return(FALSE);
	}
	
	//xgetch();

	// Write Page
	printf("\nWriting data to page %x|%x|00: ", testSectorNum,testPageNum);	

	for (i = 0; i < 16; i++)
	{
		for (j = 0; j < 16; j++)
		{
			dataBuf[i*16+j] = (U8)(i*16+j);
		}
	}

	rc = writePage(plxPtr,testSectorNum,testPageNum,0,pdataBuf,256);
	if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }
	printf("Success");

	//xgetch();
	
	printf("\nClear Buffer: ");
	//memset(dataBuf,0,);
	for (i = 0; i < 256; i++) 
		dataBuf[i] = 0;

	rc = PlxPci_PciBarSpaceWrite(plxPtr.pDevice, SPI_BAR, FPGA_SPI_PAGE_MEM, pdataBuf, SIZE_PAGE_BUFFER, BitSize32, FALSE);
	if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }


	printf("Success");
	//xgetch();

	printf("\nVerify data on page %x|%x|00: ", testSectorNum,testPageNum);

	rc = readPage(plxPtr,testSectorNum,testPageNum,0,pdataBuf);
	if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }

	bOk = TRUE;
	for (i = 0; (i < 16) && (bOk == TRUE); i++)
	{
		for (j = 0; (j < 16) && (bOk == TRUE); j++)
		{
			//printf("%2x ", dataBuf[i*16+j]);
			if (dataBuf[i*16+j] != (U8)(i*16+j))
			{
				bOk = FALSE;
			}
		}
		//printf("\n");
	}
	
	if (bOk == TRUE) 
		printf("Success");
	else
	{
		printf("Failure, at byte %d", i*16 + j);
		return(FALSE);
	}

	//xgetch();

//#endif
	return(TRUE);
}


/*******************************************************************************
Function:		progAndRb
Description:	Programs flash from file, then reads back flash to another file
*******************************************************************************/
U8 progAndRb(PLX_DEVICE_OBJECT* pDevice, U8 flashSel, char* progFile, char* rbFile, U8 program, U8 reset, U8 bulkerase, U8 verify)
{
	RETURN_CODE       rc;
	PLX_PTR				plxPtr;
	PLX_INTERRUPT		plxIntr;
	PLX_NOTIFY_OBJECT	plxEvent;
	U8					bPass = FALSE;
	U32					rVal;
	int i;
	#ifdef USE_INTR
		// Clear interrupt structure, and enable local interrupt
		memset(&plxIntr, 0, sizeof(PLX_INTERRUPT));
		plxIntr.PciMain = 1;		// Bit 8 -- should already been on

		// enable the main pci interrupt
		PlxPci_InterruptEnable(pDevice,&plxIntr);
		
		// Setup the interrupt structure for later interrupts
		plxIntr.PciMain = 0;
		#if PLX_SDK_VERSION_MAJOR == 5 && PLX_SDK_VERSION_MINOR == 1
		plxIntr.LocalToPci_1 = 1;	// Bit 11
		#else
		plxIntr.LocalToPci = 1;	// Bit 11
		#endif

		// register for interrupt	
		printf("\nRegistering Interrupt: ");
		rc = PlxPci_NotificationRegisterFor(pDevice,&plxIntr, &plxEvent);
			if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }

		printf("OK\n");
	
	#endif

	plxPtr.pDevice = pDevice;
	plxPtr.pInterrupt = &plxIntr;
	plxPtr.pEvent = &plxEvent;

	rc = WriteDword(plxPtr.pDevice, 3, FPGA_SPI_SEL, flashSel);
		if (rc != ApiSuccess) { return(FALSE); }

	rc = WriteDword (plxPtr.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);
		if (rc != ApiSuccess) return(rc);


	rc = readSignature(plxPtr, &rVal);
		if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

	printf("Signature = %x\n",rVal);


	rc = readID(plxPtr, &rVal );
		if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc);  return(FALSE);  }

	printf("ID = %x\n",rVal);
	
	if (bulkerase==TRUE)
	{
		printf("\nErasing flash:");
		rc = bulkErase(plxPtr);
			if (rc != ApiSuccess) { return(FALSE); }
	}

	printf("OK");

	if (program==TRUE)
	{
		printf("\nPrograming flash\n");
		rc = programFlash(plxPtr,progFile,0);
			if (rc != ApiSuccess) { return(FALSE); }
	}
	//xgetch();

	if (verify==TRUE)
	{
		printf("\nVerifying flash\n");
		//readFlash(plxPtr,rbFile, pfinfo);
		bPass = verifyFlash(plxPtr, progFile,0);
	}
	else
	{
		bPass = TRUE;
	}

	#ifdef USE_INTR
	printf("\nUn-registering Interrupt: ");
	rc = PlxPci_NotificationCancel( pDevice, &plxEvent);
		if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }

		printf("OK\n");
	#endif


	if ((bPass == TRUE) && (reset==TRUE))
	{
		resetFPGA(plxPtr,0,0,0);
	}
	printf("\nDelaying while FPGA loads\n");
	for(i=0;i<4;i++)
	{	
	printf("..\n");
	CTISleep(5000);	
	}
/*
	#ifdef USE_INTR
	printf("\nUn-registering Interrupt: ");
	rc = PlxPci_NotificationCancel( pDevice, &plxEvent);
		if (rc != ApiSuccess) { PlxSdkErrorDisplay(rc); return(FALSE);  }

		printf("OK\n");
	#endif
*/
	return(bPass);

}
