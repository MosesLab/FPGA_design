/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			SPIInterface.c
Description:	Functions that implement all SPI flash operations
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-12-01	MF		Interrupts are now used for all functions
2008-12-02	MF		Pass full dev pointer to FPGAIntWait, also tweak timeeout
2009-03-19	MF		Cleanup include file ordering
2009-08-19	MF		Add sector offset for page programming
'			'		Add blankCheck
'			'		Add addresss parameters to resetFpga
2010-09-02	MF		Added check for spansion flash
2012-02-13	MF		Minor fixes for linux compilation, replace S8 with char
*******************************************************************************/

/*===============
HEADERS
===============*/
#include "SPIInterface.h"

#if defined(PLX_LINUX)
	// for strupr

	#include <ctype.h>

	void  strupr(char* str)
	{
		while(*str)
		{
			*str = toupper( (unsigned char) *str );
			str++;
		}
	}
#endif

st_flash_info finfoTbl[4] =
{
	{
		0x202015,	//id
		0x14,		//sig
		32,			//numSec	
		256,		//pageSize
		256		//pagePerSec
		//8192,			//numPage = numSec * pagePerSec
		//65536,		//secSize = pageSize *pagePerSec
		//2097152		//devSize = numSec*.secSize

		//2097152 bytes * 8 bits per byte / 1024 b per kb / 1024 kb per mb
		// = 16 Mb
	 },
	{
		0x202016,	//id
		0x15,		//sig
		64,			//numSec	
		256,		//pageSize
		256		//pagePerSec
		//8192,			//numPage = numSec * pagePerSec
		//65536,		//secSize = pageSize *pagePerSec
		//4194304		//devSize = numSec*.secSize

		//2097152 bytes * 8 bits per byte / 1024 b per kb / 1024 kb per mb
		// = 32 Mb
	 },
	{
		0x202017,	//id
		0x16,		//sig
		128,		//numSec
		256,		//pageSize
		256			//pagePerSec
		//32768,		//numPage = numSec * pagePerSec
		//65536,		//secSize = pageSize *pagePerSec
		//8388608		//devSize = numSec*.secSize

		//8388608 bytes * 8 bits per byte / 1024 b per kb / 1024 kb per mb
		// = 64 Mb
	},
	//S25FL064A
	{
		0x010216,	//id
		0x16,		//sig
		128,		//numSec
		256,		//pageSize
		256			//pagePerSec
	}

};

#ifdef METRICS
LARGE_INTEGER tTotalBarWr;
LARGE_INTEGER tTotalIntWait;
extern LARGE_INTEGER tTotalWaitBit;
extern U32 numWait;
extern U32 waitBitIterations;
#endif

/*******************************************************************************
Function:		loopback
Description:	
*******************************************************************************/
RETURN_CODE loopback(PLX_DEVICE_OBJECT* pDevice, U32 lbIn, U32* plbOut)
{
	U32 rVal;
	RETURN_CODE rc;

	rc = waitBitClr(pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	rc = WriteDword (pDevice,SPI_BAR,FPGA_SPI_PARAM,lbIn);
		if (rc != ApiSuccess) return(rc);
	rc = WriteDword (pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_FIFO_LOOPBACK);
		if (rc != ApiSuccess) return(rc);
	rc = waitBitSet(pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);
	rc = ReadDword (pDevice,SPI_BAR,FPGA_SPI_RESULT,&rVal);
		if (rc != ApiSuccess) return(rc);
	rc = WriteDword (pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);

	*plbOut = rVal & 0xFF;

	return (rc);
}

/*******************************************************************************
Function:		readSignature
Description:	reads one byte signature from flash
*******************************************************************************/
RETURN_CODE readSignature(PLX_PTR Dev, U32* pSig)
{
	U32 rVal;

	RETURN_CODE rc;

	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_GET_SIG);
		if (rc != ApiSuccess) return(rc);
		
	#ifdef USE_INTR
		rc = FPGAIntWait(Dev, INTERRUPT_SPI, 5000);
	#else
		rc = waitBitSet(Dev.pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
	#endif		
		if (rc != ApiSuccess) return(rc);
		
	rc = ReadDword (Dev.pDevice,SPI_BAR,FPGA_SPI_RESULT,&rVal);
		if (rc != ApiSuccess) return(rc);
		
	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);
	
	*pSig = 0x000000FF & rVal;

	return(rc);
}

/*******************************************************************************
Function:		readID
Description:	reads three byte id from flash
*******************************************************************************/
RETURN_CODE readID(PLX_PTR Dev, U32* pId)
{
	U32 rVal;
	U32 id;
	RETURN_CODE rc;

	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
	/*
		rc = PlxPci_InterruptEnable(Dev.pDevice,Dev.pInterrupt);
			if (rc != ApiSuccess) return(rc);
	*/		
	#endif

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_GET_ID);
		if (rc != ApiSuccess) return(rc);
	
	#ifdef USE_INTR
		rc = FPGAIntWait(Dev, INTERRUPT_SPI, 5000);
	#else
		rc = waitBitSet(Dev.pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
	#endif
		if (rc != ApiSuccess) return(rc);

	rc = ReadDword (Dev.pDevice,SPI_BAR,FPGA_SPI_RESULT,&rVal);
		if (rc != ApiSuccess) return(rc);
	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);
	
	// result is store such that lower byte is result0.
	id = rVal & 0xFF;	
	id = id << 8;
	id = id | ((rVal >> 8) & 0xFF);
	id = id << 8;
	id = id | ((rVal >> 16) & 0xFF);

	*pId = id;	

	return(rc);
}

/*******************************************************************************
Function:		eraseSector
Description:	erase sector, a byte address
*******************************************************************************/
RETURN_CODE eraseSector(PLX_PTR Dev, U32 addrSector)
{
	//U32 rVal;
	RETURN_CODE rc;

	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
	/*	
		rc = PlxPci_InterruptEnable(Dev.pDevice,Dev.pInterrupt);
			if (rc != ApiSuccess) return(rc);
	*/	
	#endif

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_PARAM,addrSector);
		if (rc != ApiSuccess) return(rc);
	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_SECTOR_ERASE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
		rc = FPGAIntWait(Dev, INTERRUPT_SPI, 6000);
	#else
		rc = waitBitSet(Dev.pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
	#endif

		if (rc != ApiSuccess) return(rc);

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);

	return(rc);
}

/*******************************************************************************
Function:		readPage
Description:	reads a 256 byte page from the flash
*******************************************************************************/
//RETURN_CODE readPage(	PLX_DEVICE_OBJECT* pDevice,U8 addrSector, U8 addrPage, U8 addrByte, U32* pBuf )
RETURN_CODE readPage(	PLX_PTR Dev,U8 addrSector, U8 addrPage, U8 addrByte, U32* pBuf )
{
	U32 readAddr;
	RETURN_CODE rc;

	readAddr = 0;
	readAddr |= addrSector;			// upper address
	readAddr |= addrPage << 8;		// middle address
	readAddr |= addrByte << 16;		// lower address

	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
	/*	
		rc = PlxPci_InterruptEnable(Dev.pDevice,Dev.pInterrupt);
			if (rc != ApiSuccess) return(rc);
	*/	
	#endif

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_PARAM,readAddr);
		if (rc != ApiSuccess) return(rc);
	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_READ_PAGE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
		rc = FPGAIntWait(Dev, INTERRUPT_SPI, 10000);
	#else
		rc = waitBitSet(Dev.pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
	#endif

		if (rc != ApiSuccess) return(rc);

	rc = PlxPci_PciBarSpaceRead(Dev.pDevice,SPI_BAR,FPGA_SPI_PAGE_MEM,pBuf,SIZE_PAGE_BUFFER,BitSize32,FALSE);
		if (rc != ApiSuccess) return(rc);
	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);

	return(rc);
}


//RETURN_CODE writePage(	PLX_DEVICE_OBJECT* pDevice,U8 addrSector, U8 addrPage, U8 addrByte, U32* pBuf, U32 pageSize )
RETURN_CODE writePage(	PLX_PTR Dev, U8 addrSector, U8 addrPage, U8 addrByte, U32* pBuf, U32 pageSize )
{
	U32 param;
	RETURN_CODE rc;
	U8 adjPageSize;

	#ifdef METRICS
		LARGE_INTEGER tStart, tEnd;
	#endif

	if (pageSize >= 256)
	{
		adjPageSize = 0;
	}
	else
	{
		adjPageSize = (U8)pageSize;
		//printf("\n\t\tPage Size is last byte address = %d, adjusted to %d\n", pageSize, adjPageSize);
	}
	
	

	param = 0;
	param |= addrSector;			// upper address
	param |= addrPage << 8;			// middle address
	param |= addrByte << 16;		// lower address
	param |= pageSize << 24;		//	

	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
	/*
		rc = PlxPci_InterruptEnable(Dev.pDevice,Dev.pInterrupt);
			if (rc != ApiSuccess) return(rc);
	*/	
	#endif

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_PARAM,param);
		if (rc != ApiSuccess) return(rc);

	#ifdef METRICS
	QueryPerformanceCounter(&tStart);
	#endif

	rc = PlxPci_PciBarSpaceWrite(Dev.pDevice,SPI_BAR,FPGA_SPI_PAGE_MEM,pBuf,SIZE_PAGE_BUFFER,BitSize32,FALSE);
		if (rc != ApiSuccess) return(rc);

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_WRITE_PAGE);
		if (rc != ApiSuccess) return(rc);

	#ifdef METRICS
	QueryPerformanceCounter(&tEnd);
	tTotalBarWr.QuadPart = tTotalBarWr.QuadPart+(tEnd.QuadPart-tStart.QuadPart);
	#endif


	#ifdef USE_INTR

		#ifdef METRICS
		QueryPerformanceCounter(&tStart);
		#endif

		rc = FPGAIntWait(Dev, INTERRUPT_SPI, 10000);

		#ifdef METRICS
		QueryPerformanceCounter(&tEnd);
		tTotalIntWait.QuadPart = tTotalIntWait.QuadPart+(tEnd.QuadPart-tStart.QuadPart);
		#endif
	#else
		rc = waitBitSet(Dev.pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
	#endif

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);

	return(rc);
}



RETURN_CODE bulkErase(PLX_PTR Dev)
{
	RETURN_CODE rc;
	
	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
	/*	
		rc = PlxPci_InterruptEnable(Dev.pDevice,Dev.pInterrupt);
			if (rc != ApiSuccess) return(rc);
	*/	
	#endif

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_BULK_ERASE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
		rc = FPGAIntWait(Dev, INTERRUPT_SPI, 160000);
	#else
		rc = waitBitSet(Dev.pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
	#endif
	
		if (rc != ApiSuccess) return(rc);

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);
		if (rc != ApiSuccess) return(rc);

	return(rc);
}

RETURN_CODE blankCheck(PLX_PTR Dev, U8* result)
{
	RETURN_CODE rc;
	U32 rVal;
	
	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
	/*	
		rc = PlxPci_InterruptEnable(Dev.pDevice,Dev.pInterrupt);
			if (rc != ApiSuccess) return(rc);
	*/	
	#endif

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_BLANK_CHECK);
		if (rc != ApiSuccess) return(rc);

	#ifdef USE_INTR
		rc = FPGAIntWait(Dev, INTERRUPT_SPI, 160000);
	#else
		rc = waitBitSet(Dev.pDevice, SPI_BAR, FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
	#endif
	
		if (rc != ApiSuccess) return(rc);

	rc = ReadDword (Dev.pDevice,SPI_BAR,FPGA_SPI_RESULT,&rVal);
		if (rc != ApiSuccess) return(rc);
		
	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_CLEAR);
		if (rc != ApiSuccess) return(rc);

	if (rVal == BC_PASS) 
		*result = TRUE;
	else
		*result = FALSE;
		
	return(rc);
}

void processRecord(char* strBuf, HEX_RECORD* rec)
{
	U16 bufLen, i, j;

	bufLen = strlen(strBuf);

	//printf("%s",strBuf);
	i = 1; // colon is first character?
	rec->size = aBytetohByte(strBuf[i],strBuf[i+1]); 	i+=2;
	rec->addrPage = aBytetohByte(strBuf[i],strBuf[i+1]);	i+=2;
	rec->addrByte = aBytetohByte(strBuf[i],strBuf[i+1]); 	i+=2;
	rec->type = aBytetohByte(strBuf[i],strBuf[i+1]); 	i+=2;

	for ( j=0; j < rec->size; j++) // 2*REC_SIZE)
	{
		rec->data[j] = aBytetohByte(strBuf[i],strBuf[i+1]); i+=2;
	}	

	rec->cs = aBytetohByte(strBuf[i],strBuf[i+1]); i+=2;		
}

/*******************************************************************************
Function:		programFlash
Description:	program the flash from the hexfile, secOffset is the expected
				start sector
*******************************************************************************/
//RETURN_CODE programFlash(PLX_DEVICE_OBJECT* pDevice, char* fileName)
RETURN_CODE programFlash(PLX_PTR Dev, char* fileName, U8 secOffset)
{
	U32 numRecords = 0;
	char strBuf[REC_SIZE*2+2];  // 2 extra characters for colon and CR
	U8 pageBuf[256];
	U8 addrSector;
	U8 addrPage;
	U8 addrByte;
	U16 i;
	HEX_RECORD rec;
	
	U32 lines;
	double percentage;
	FILE *fp;
	U8 pageWritePending;
	RETURN_CODE rc = ApiFailed;

	#ifdef METRICS

	//SYSTEMTIME systime;
	//GetSystemTime(&systime);
	//x = systime.milliseconds;


LARGE_INTEGER  lpFrequency;
	LARGE_INTEGER  tProgStart;
	LARGE_INTEGER  tProgEnd;
	LARGE_INTEGER  tProgTotal;
	LARGE_INTEGER  tOpStart;
	LARGE_INTEGER  tOpEnd;
	LARGE_INTEGER  tWrTotal;
	LARGE_INTEGER  tErTotal;
	U32  numWr = 0;
	U32  numEr = 0;
	tErTotal.QuadPart = 0;
	tWrTotal.QuadPart = 0;
	tTotalBarWr.QuadPart = 0;
	tTotalIntWait.QuadPart = 0;
	tTotalWaitBit.QuadPart = 0;
	#endif

	//S8* pstrBuf = (S8*)&strBuf[0];

	#ifdef METRICS
	QueryPerformanceCounter (&tProgStart);
	#endif

	fp = fopen(fileName, "r");

	if (fp == NULL)
	{
		printf("\nFailed to open %s", fileName);
		return(rc);
	}

	lines = 0;

	while ( fscanf(fp,"%s",&strBuf[0]) != EOF )
	{
		lines++;
	}

	rewind(fp);

	addrSector = secOffset;
	addrPage = 0;
	addrByte = 0;
	pageWritePending = FALSE;

	while ( fscanf(fp,"%s",&strBuf[0]) != EOF )
	{
		processRecord(&strBuf[0], &rec);

		switch (rec.type)
		{
			//--------------
			case 0x04:
				
				if (addrSector != rec.data[1] || pageWritePending == TRUE)
				{	
					printf("Sector out of sequence (line %d)\n", numRecords+1);
					printf("Expected %x, read %x\n",addrSector, rec.data[1]);
					return(rc);
				}
				else
				{
					addrPage = 0;
					addrByte = 0;

					#ifdef METRICS
					QueryPerformanceCounter (&tOpStart);
					#endif

					rc = eraseSector(Dev, addrSector);
						if (rc != ApiSuccess) return(rc);

					#ifdef METRICS
					QueryPerformanceCounter(&tOpEnd);

					tErTotal.QuadPart = tErTotal.QuadPart + (tOpEnd.QuadPart - tOpStart.QuadPart);
					numEr++;
					#endif
				}	
				break;

			//--------------
			case 0x00:

				if (addrPage != rec.addrPage || addrByte != rec.addrByte)
				{
					printf("Record address out of sequence (line %d)\n", numRecords+1);
					printf("Expected %x %x, read %x %x\n",
							addrPage, addrByte, rec.addrPage, rec.addrByte);
					return(rc);
				}

				pageWritePending = TRUE;

				for(i=0; i < rec.size; i++)
				{
					pageBuf[addrByte+i] = rec.data[i];
				}

				addrByte += rec.size; // should be 0x10
			
				if (addrByte == 0x00) // 256 bytes have been collected, time to write page
				{
					#ifdef METRICS
					 QueryPerformanceCounter (&tOpStart);
					#endif
					rc = writePage(Dev, addrSector, addrPage, 0, (U32*)&pageBuf, 256);
						if (rc != ApiSuccess) return(rc);

					#ifdef METRICS
					 QueryPerformanceCounter(&tOpEnd);

					tWrTotal.QuadPart = tWrTotal.QuadPart + (tOpEnd.QuadPart - tOpStart.QuadPart);
					numWr++;
					#endif
					//printf("SECT %2x PAGE %2x % BYTE %2x\n", addrSector, addrPage, addrByte);

					pageWritePending = FALSE;
					addrPage++;

					if (addrPage == 0x00) // 256 pages have been written, rollover
					{
						addrSector++;				
					}
				}						
				break;

			//--------------
			case 0x01:
				if (pageWritePending)
				{
					//printf("Unfinished page (%d)\n", numRecords+1);
					writePage(Dev, addrSector, addrPage, 0, (U32*)&pageBuf, addrByte);
					pageWritePending = FALSE;
				}
				break;
			default :
				printf("\nInvalid Record processed (%d)\n", numRecords);
				return(rc);
				break;
		}
			

		numRecords=numRecords+1;				

		percentage = ( (double)numRecords / (double)lines ) * 100;
		printf("%f | 100 %%\r",percentage);
	}

	

	#ifdef METRICS
	QueryPerformanceCounter(&tProgEnd);
	QueryPerformanceFrequency(&lpFrequency); //get frequency in counts/second
	printf("Frequency Time = %d\n", lpFrequency.QuadPart);
	tProgTotal.QuadPart = tProgEnd.QuadPart-tProgStart.QuadPart;

	printf("Total Time = %f\n", (double)tProgTotal.QuadPart / (double)lpFrequency.QuadPart);
	printf("Total Wr Page Time : %f\n",(double)tWrTotal.QuadPart/ (double)lpFrequency.QuadPart );
	printf("Number Wr Page Ops: %d\n", numWr);
	printf("Average Wr Page Time: %f\n", (double)(tWrTotal.QuadPart/numWr) / (double)lpFrequency.QuadPart);

	printf("Total Bar Wr Time : %f\n",(double)tTotalBarWr.QuadPart/ (double)lpFrequency.QuadPart );
	printf("Average Bar Wr Time: %f\n", (double)(tTotalBarWr.QuadPart/numWr) / (double)lpFrequency.QuadPart);

	printf("Total Int Wait Time : %f\n",(double)tTotalIntWait.QuadPart/ (double)lpFrequency.QuadPart );
	printf("Average Int Wait  Time: %f\n", (double)(tTotalIntWait.QuadPart/numWr) / (double)lpFrequency.QuadPart);

	printf("Total Er Sector Time : %f\n",(double)tErTotal.QuadPart / (double)lpFrequency.QuadPart);
	printf("Number Er Sector Ops: %d\n", numEr);
	printf("Average Er Sector Time: %f\n", (double)tErTotal.QuadPart/numEr / (double)lpFrequency.QuadPart);

	printf("Total Wait bit Time : %f\n",(double)tTotalWaitBit.QuadPart/ (double)lpFrequency.QuadPart );
	printf("Number Wait bit: %d, Total Iterations %d\n", numWait, waitBitIterations);
	printf("Average Wait bit  Time: %f\n", (double)(tTotalWaitBit.QuadPart/numWait) / (double)lpFrequency.QuadPart);

	#endif

	printf("...Complete\n");

	fclose(fp);

	return(ApiSuccess);
}

/*******************************************************************************
Function:		resetFPGA
Description:	performs a warm boot reset
*******************************************************************************/
RETURN_CODE resetFPGA(PLX_PTR Dev, U8 addrSector, U8 addrPage, U8 addrByte)
{
	U32 warmBootAddr;
	RETURN_CODE rc;

	warmBootAddr = 0;
	warmBootAddr |= addrSector;			// upper address
	warmBootAddr |= addrPage << 8;		// middle address
	warmBootAddr |= addrByte << 16;		// lower address
	
	printf("resetFPGA: reseting from %x\n", warmBootAddr);

	rc = waitBitClr(Dev.pDevice, SPI_BAR,FPGA_SPI_STATUS, SPI_STATUS_COMPLETE);
		if (rc != ApiSuccess) return(rc);

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_PARAM,warmBootAddr);
		if (rc != ApiSuccess) return(rc);
		
//	outpx (CMD_REG,REPROGRAM);

	rc = WriteDword (Dev.pDevice,SPI_BAR,FPGA_SPI_CMD,SPI_REPROGRAM);
		if (rc != ApiSuccess) return(rc);



	return(rc);
}

U8 aBytetohByte(char a, char b)
{
	U8 newByte;

	newByte = get_digit ( a );
	newByte <<= 4;
	newByte += get_digit ( b );

	return (newByte);
}

//RETURN_CODE readFlash(PLX_DEVICE_OBJECT* pDevice, char* fileName )
RETURN_CODE readFlash(PLX_PTR Dev, char* fileName, st_flash_info* pfinfo )
{

	U16 sec,page,rec,i,j;
	char strBuf[REC_SIZE*2+3];
	U8 byteArr[REC_SIZE];
	U8 dataBuf[SIZE_PAGE_BUFFER];
	U8 cs;
	U32 numPage;
	float percentage;
	FILE *fp;
	//S8* pstrBuf = &strBuf[0];

	numPage = pfinfo->numSec * pfinfo->pagePerSec;

	fp = fopen(fileName, "w");

	for (sec = 0; sec < pfinfo->numSec; sec++)
	{
		// write a new sector record
				byteArr[0] = 0x02; // record data field size
				byteArr[1] = 0x00;
				byteArr[2] = 0x00;
				byteArr[3] = 0x04; // record type
				byteArr[4] = 0x00; 
				byteArr[5] = (U8)sec; 								

				cs = 0;				
				for (i = 0; i < 6; i++)
				{
					cs += byteArr[i];
				}

				cs = ~cs + 1;

				byteArr[6] = cs;

				// convert to string
				strBuf[0] = ':';
				for (i = 0; i < 7; i++)
				{
					sprintf(&strBuf[i*2+1],"%02x", byteArr[i]);
				}
			
				strBuf[2*i+1] = 0;
				
				strupr(&strBuf[0]);
				fprintf(fp,"%s\n",&strBuf[0]);
//				printf("%s\n",&buf);		


		for (page = 0; page < pfinfo->pagePerSec; page++)
		{
			readPage(Dev,(U8)sec,(U8)page,0,(U32*)&dataBuf);

			if (sec == 0 && page == 0)
			{
			for( i = 0; i < 16; i++)
			{
				printf("\n%02x|",i*16);
				for (j=0;j<16;j++)
				{
					printf("%02x",dataBuf[i*16+j]);
				}
			}
				printf("\n");
			}
	
			// records per page
			for (rec = 0; rec < 16; rec++)
			{

				byteArr[0] = 0x10; // record size
				byteArr[1] = (U8)page;
				byteArr[2] = (U8)(rec*0x10);
				byteArr[3] = 0x00; // record type

				cs = byteArr[0]+byteArr[1]+byteArr[2]+byteArr[3];

				// bytes per record
				for (i = 0; i < 16; i++)
				{
					byteArr[i+4] = dataBuf[rec*16+i];					
					cs += byteArr[i+4];
				}

				// take two's compliment
				cs = ~cs + 1;

				byteArr[i+4] = cs;

				// convert to string
				strBuf[0] = ':';
				for (i = 0; i < 21; i++)
				{
					sprintf(&strBuf[i*2+1],"%02x", byteArr[i]);
				}
			
				strBuf[2*i+1] = 0;
				
				strupr(&strBuf[0]);
				fprintf(fp,"%s\n",&strBuf[0]);		
			}

			percentage = (float)(100*(sec * pfinfo->pagePerSec + page + 1)) / (float)(numPage);
			printf("%f | 100%%\r", percentage);
		}
	}


	fprintf(fp,":00000001FF\n");

	printf("Complete\n");
	fclose(fp);

	return(0);
}



void mcsGen(char* fileName, st_flash_info* pfinfo, U32 seed )
{

	U16 sec,page,rec,i, k;
	char strBuf[REC_SIZE*2+3];
	U8 byteArr[REC_SIZE];
	U8 dataBuf[SIZE_PAGE_BUFFER];
	U8 cs;
	U32* pBuf = (U32*)(&dataBuf[0]);
	U32 val, numPage;
	float percentage;
	FILE *fp;
	char* pstrBuf = &strBuf[0];

	numPage = pfinfo->numSec * pfinfo->pagePerSec;

	val = seed;

	fp = fopen(fileName, "w");

	for (sec = 0; sec < pfinfo->numSec; sec++)
	{
		// write a new sector record
				byteArr[0] = 0x02; // record data field size
				byteArr[1] = 0x00;
				byteArr[2] = 0x00;
				byteArr[3] = 0x04; // record type
				byteArr[4] = 0x00; 
				byteArr[5] = (U8)sec; 								

				cs = 0;				
				for (i = 0; i < 6; i++)
				{
					cs += byteArr[i];
				}

				cs = ~cs + 1;

				byteArr[6] = cs;

				// convert to string
				strBuf[0] = ':';
				for (i = 0; i < 7; i++)
				{
					sprintf(&strBuf[i*2+1],"%02x", byteArr[i]);
				}
			
				strBuf[2*i+1] = 0;
				
				strupr(pstrBuf);
				fprintf(fp,"%s\n",pstrBuf);
//				printf("%s\n",&buf);		


		for (page = 0; page < pfinfo->pagePerSec; page++)
		{
			
			for (k=0;k<64;k++)
			{
				pBuf[k] = val;
				val++;
			}
	
			// records per page
			for (rec = 0; rec < 16; rec++)
			{

				byteArr[0] = 0x10; // record size
				byteArr[1] = (U8)page;
				byteArr[2] = (U8)(rec*0x10);
				byteArr[3] = 0x00; // record type

				cs = byteArr[0]+byteArr[1]+byteArr[2]+byteArr[3];

				// bytes per record
				for (i = 0; i < 16; i++)
				{
					byteArr[i+4] = dataBuf[rec*16+i];					
					cs += byteArr[i+4];
				}

				// take two's compliment
				cs = ~cs + 1;

				byteArr[i+4] = cs;

				// convert to string
				strBuf[0] = ':';
				for (i = 0; i < 21; i++)
				{
					sprintf(&strBuf[i*2+1],"%02x", byteArr[i]);
				}
			
				strBuf[2*i+1] = 0;
				
				strupr(pstrBuf);
				fprintf(fp,"%s\n",pstrBuf);		
			}

			percentage = (float)(100*(sec * pfinfo->pagePerSec + page + 1)) / (float)(numPage);
			printf("%f | 100%%\r", percentage);
		}
	}


	fprintf(fp,":00000001FF\n");

	printf("Complete\n");
	fclose(fp);

	return;
}



/*******************************************************************************
Function:		verifyFlash
Description:	
*******************************************************************************/
U8 verifyFlash(PLX_PTR Dev, char* fileName, U8 secOffset)

{
	U32 numRecords = 0;
	char strBuf[REC_SIZE*2+2];  // 2 extra characters for colon and CR
	U8 wrBuf[256];
	U8 rdBuf[256];
	U8 addrSector;
	U8 addrPage;
	U8 addrByte;
	U16 i, j;
	HEX_RECORD rec;
	//time_t tStart;
	//time_t tCur;
	U32 lines;
	double percentage;
	FILE *fp;
	U8 pageComplete;
	RETURN_CODE rc; // = ApiFailed;

	//S8* pstrBuf = (S8*)&strBuf[0];

	//tStart = time(NULL);

	//printf("\nVerifying flash against file: %s",fileName);
	fp = fopen(fileName, "r");

	lines = 0;

	while ( fscanf(fp,"%s",&strBuf[0]) != EOF )
	{
		lines++;
	}

	rewind(fp);

	addrSector = secOffset;
	addrPage = 0;
	addrByte = 0;
	pageComplete = TRUE;

	while ( fscanf(fp,"%s",&strBuf[0]) != EOF )
	{
		processRecord(&strBuf[0], &rec);

		switch (rec.type)
		{
			//--------------
			case 0x04:
				
				if (addrSector != rec.data[1] || pageComplete == FALSE)
				{	
					printf("Sector out of sequence (line %d)\n", numRecords+1);
					printf("Expected %x, read %x\n",addrSector, rec.data[1]);
					return(FALSE);
				}
				else
				{
					addrPage = 0;
					addrByte = 0;
				}	
				break;

			//--------------
			case 0x00:

				if (addrPage != rec.addrPage || addrByte != rec.addrByte)
				{
					printf("Record address out of sequence (line %d)\n", numRecords+1);
					printf("Expected %x %x, read %x %x\n",
							addrPage, addrByte, rec.addrPage, rec.addrByte);
					return(FALSE);
				}

				pageComplete = FALSE;

				for(i=0; i < rec.size; i++)
				{
					wrBuf[addrByte+i] = rec.data[i];
				}

				addrByte += rec.size; // should be 0x10
			
				if (addrByte == 0x00) // 256 bytes have been collected, time to write page
				{
					rc = readPage(Dev, addrSector, addrPage, 0, (U32*)&rdBuf);
						if (rc != ApiSuccess) return(FALSE);
					
					//printf("SECT %2x PAGE %2x % BYTE %2x\n", addrSector, addrPage, addrByte);

					for(j=0; j<=0xFF; j++)
					{
						if(wrBuf[j] != rdBuf[j])
						{
							printf("Read compare error: %2x %2x %2x", addrSector, addrPage, j);
							fclose(fp);
							return(FALSE);
						}
					}

					pageComplete = TRUE;
					addrPage++;

					if (addrPage == 0x00) // 256 pages have been written, rollover
					{
						addrSector++;				
					}
				}						
				break;

			//--------------
			case 0x01:
				if (pageComplete==FALSE)
				{
					rc = readPage(Dev, addrSector, addrPage, 0, (U32*)&rdBuf);
						if (rc != ApiSuccess) return(FALSE);


					pageComplete = TRUE;

					for(j=0;j<addrByte;j++)
					{
						if(wrBuf[j]!=rdBuf[j])
						{
							printf("Read compare error: %2x %2x %2x", addrSector, addrPage, j);
							fclose(fp);
							return(FALSE);
						}

					}
				}
				break;
			default :
				printf("\nInvalid Record processed (%d)\n", numRecords);
				return(FALSE);
				break;
		}
			

		numRecords=numRecords+1;				

		percentage = ( (double)numRecords / (double)lines ) * 100;
		printf("%f | 100 %%\r",percentage);
	}

//	tCur = time(NULL);

	//printf("\nElapsed Time = %d\n", tCur-tStart);
	//printf("\nStart : %s\n",_ctime(&tStart,strBuf) );
	//printf("\nEnd : %s\n",_ctime(&tCur,strBuf) );

	printf("\n...Complete\n");

	fclose(fp);

	return(TRUE);
}
