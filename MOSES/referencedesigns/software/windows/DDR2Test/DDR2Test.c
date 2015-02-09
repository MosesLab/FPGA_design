/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			DDR2Test.c
Description:	Program to test DDR2 memory, using MIG interface
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-03-05	MF		Created
2008-03-07	MF		Initial development changes
2008-03-07	MF		Change to do a bunch of writes, then reads
2008-03-07	MF		Fixed exponent calc, data calc
2008-06-04	MF		Separate test() from main(), for use in one large test app
2008-11-26	MF		Reduce to the number of row and col addresses tested
2008-12-12	MF		Cleanup messages verbosity
2009-03-19	MF		Cleanup include file ordering
2011-11-14	MF		Restructured return codes
*******************************************************************************/

// HEADERS
#include "DDR2Test.h"

/*******************************************************************************
Function:		DDR2Test
Description:	The main entry point
*******************************************************************************/
U8 DDR2Test(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
    RETURN_CODE			rc;
    U32					i;
//	U32					wData;
	U32					rData;
    U32					*pBufferWr = NULL;
    U32					*pBufferRd = NULL;
    U32					*pBufferClr = NULL;
//	U16					cmd;
//	U16					burstCnt;
	U16					col;
	U16					row;
	U16					bank;
//	U16					maxCol = (U16)pow(2,COL_WIDTH);
//	U16					maxRow = (U16)pow(2,ROW_WIDTH); //2^ROW_WIDTH;
	U16					maxBank = (U16)pow(2,BANK_WIDTH);
	U32					ddr2Addr;
	U8					bCompare;
	U8					bShowData = FALSE;
	U8					bPass = TRUE;

	// Verify that initialization is done.
	for(i=0; i<3; i++)
	{
		rc = ReadDword(pDevice,BarIndex,FPGA_DDR2_STATUS,&rData);
			if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }

		if ((rData & DDR2_STATUS_PHY_DONE) == DDR2_STATUS_PHY_DONE)
			break;
	}

	//printf("rData = %8x ", rData);

	printf("\n200 Mhz Clock check: ");

	if ((rData & 0x10) == 0x10) 
		printf("OK");
	else
		printf("Failed");

	printf("\nShifted Clock check: ");

	if ((rData & 0x20) == 0x20) 
		printf("OK");
	else
		printf("Failed");
		
	//if ((rData & DDR2_STATUS_PHY_DONE) != DDR2_STATUS_PHY_DONE)

	if ((rData & DDR2_STATUS_PHY_DONE) != DDR2_STATUS_PHY_DONE)
	{
		printf("\n*ERROR* - MIG PHY Initialization did not complete");
		return(FALSE);
		//{ bPass=FALSE; goto CLEANUP; }
	}

	// Prepare the buffers and set init them to 0
	printf("\nPreparing buffers: ");

	pBufferRd = malloc(SIZE_DDR2_BUFFER);
	pBufferWr = malloc(SIZE_DDR2_BUFFER);
    pBufferClr = malloc(SIZE_DDR2_BUFFER);

    if (pBufferRd == NULL || pBufferWr == NULL || pBufferClr == NULL) 
    {
        printf("*ERROR* - Buffer allocation failed\n");
        { bPass=FALSE; goto CLEANUP; }
    }

	printf("OK");

	memset(pBufferRd, 0, SIZE_DDR2_BUFFER );
	memset(pBufferWr, 0, SIZE_DDR2_BUFFER );
	memset(pBufferClr, 0, SIZE_DDR2_BUFFER );

	printf("\nWriting Initial data: ");
	row = 0;
	bank = 0;
	col = 0;

				ddr2Addr = makeDDR2Addr(bank,row,col);
				if (bVerbose) printf("\nBANK = %x | ROW = %4x | COL = %4x | ADDR = %8x",bank, row,col,ddr2Addr);

				// Generate data
				//if (bVerbose) printf("Preparing data: ");
				for (i = 0; i < SIZE_DDR2_BUFFER/4; i=i+2)
				{
					pBufferWr[i] = 0x11111111 * i;
				}

				if (bVerbose) printf(" | DATA[last-1] = %8x",pBufferWr[i-2]);

				//if (bVerbose) printf("Ok\n");

				if (bShowData)
				{
					printf("\nWR Buffer\n");
					for (i = 0; i < SIZE_DDR2_BUFFER/4; i++)
					{
						printf("%2x=%8x\n",i,pBufferWr[i]);
					}
				}

				//  Write transfer		
				rc = performDDR2Wr(pDevice, BarIndex, pBufferWr, ddr2Addr, bVerbose);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }



	
	if (!bVerbose) printf("OK");
	/*--------------------------------------------------------------
	Wait
	--------------------------------------------------------------*/
	//printf("\n[PRESS ENTER]\n");
	//getch();

	/*--------------------------------------------------------------
	Read data
	--------------------------------------------------------------*/
	printf("\nReading initial data: ");
	//if (bVerbose) printf("\n");

				ddr2Addr = makeDDR2Addr(bank,row,col);
				if (bVerbose) printf("\nBANK = %x | ROW = %4x | COL = %4x | ADDR = %8x",bank,row,col,ddr2Addr);

				// Generate data
				//if (bVerbose) printf("\nPreparing data: ");
				for (i = 0; i < SIZE_DDR2_BUFFER/4; i=i+2)
				{
					pBufferWr[i] = 0x11111111 * i;
				}		

				if (bVerbose) printf(" | DATA[last-1] = %8x",pBufferWr[i-2]);

				//if (bVerbose) printf("\nOk");

				// Clear the dp memory

				if (bVerbose) printf("\nClearing DP DDR2 Buffer: ");
				rc =  PlxPci_PciBarSpaceWrite(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferClr, SIZE_DDR2_BUFFER, BitSize32, FALSE);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }

				if (bVerbose) printf("OK");

				memset(pBufferRd, 0, SIZE_DDR2_BUFFER );

				// Initiate transfer
				rc = performDDR2Rd(pDevice, BarIndex, pBufferRd, ddr2Addr, FALSE);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }

				// Read data from the buffer
				if (bVerbose) printf("\nReading DP DDR2 Buffer: ");
				rc = PlxPci_PciBarSpaceRead(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferRd, SIZE_DDR2_BUFFER, BitSize32, bVerbose);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }

				printf("OK");

				// Verify data against generated data
	printf("\nVerifying initial data: ");

				bCompare = TRUE;
				for (i = 0; i < SIZE_DDR2_BUFFER/4; i++)
				{
					if (pBufferWr[i] != pBufferRd[i])
					{
						printf("\nMismatch index= 0x%x: WR=%8x, RD=%8x\n",i,pBufferWr[i],pBufferRd[i]);
						bCompare = FALSE;
						break;
					}
					/*
					if (col == maxCol)
					{
						printf("\n%2x: WR=%8x, RD=%8x\n",i,pBufferWr[i],pBufferRd[i]);
					}
					*/
				}	

				bPass &= bCompare;

				//memcmp( pBufferWr, pBufferRd, SIZE_BUFFER ) != 0
				if (bCompare==FALSE)
				{
					printf("*ERROR* - Buffers do not match\n");
					{ bPass=FALSE; goto CLEANUP; }
				}
				else
				{
					printf("OK");
				}

				/*--------------------------------------------------------------
				  View data
				--------------------------------------------------------------*/
				if (FALSE)
				{
					printf("\nRD Buffer\n");
					for (i = 0; i < SIZE_DDR2_BUFFER/4; i++)
					{
						printf("%2x=%8x\n",i,pBufferRd[i]);
					}
				}



	/*--------------------------------------------------------------
	Write data
	note it is ok to start at COL-6; we are still excercising all
	device address bits with row incrementer
	--------------------------------------------------------------*/
	printf("\nWriting to all banks: ");

	for (bank=0; bank < maxBank; bank=bank+1)
	{
		for (row=0; row < ROW_WIDTH; row=row+1)
		{
			for (col=6; col < COL_WIDTH; col=col+1)
			{

				ddr2Addr = makeDDR2Addr(bank,1<<row,1<<col);
				if (bVerbose) printf("\nBANK = %x | ROW = %4x | COL = %4x | ADDR = %8x",bank, row,col,ddr2Addr);

				// Generate data
				//if (bVerbose) printf("Preparing data: ");
				for (i = 0; i < SIZE_DDR2_BUFFER/4; i=i+2)
				{
					pBufferWr[i] = (U32)row;
					pBufferWr[i] = (pBufferWr[i] << COL_WIDTH) | (U32)col;
					pBufferWr[i] = (pBufferWr[i] << 8) | ((U32)i+3);
					pBufferWr[i+1] = ~(pBufferWr[i]);
				}

				if (bVerbose) printf(" | DATA[last-1] = %8x",pBufferWr[i-2]);

				//if (bVerbose) printf("OK\n");

				if (bShowData)
				{
					printf("\nWR Buffer\n");
					for (i = 0; i < SIZE_DDR2_BUFFER/4; i++)
					{
						printf("%2x=%8x\n",i,pBufferWr[i]);
					}
				}

				//  Write transfer	
				rc = performDDR2Wr(pDevice, BarIndex, pBufferWr, ddr2Addr, bVerbose);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }
			
			} // col
		} // row
	} // bank 

	if (bVerbose) printf("\n Writing Complete"); else printf("OK");
	/*--------------------------------------------------------------
	Wait
	--------------------------------------------------------------*/
	//printf("\n[PRESS ENTER]\n");
	//getch();

	/*--------------------------------------------------------------
	Read data
	--------------------------------------------------------------*/
	printf("\nReading and verifying all banks: ");

	for (bank=0; bank < maxBank; bank=bank+1)
	{
		for (row=0; row < ROW_WIDTH; row=row+1)
		{
			for (col=6; col < COL_WIDTH; col=col+1)
			{

				ddr2Addr = makeDDR2Addr(bank,1<<row,1<<col);
				if (bVerbose) printf("\nBANK = %x | ROW = %4x | COL = %4x | ADDR = %8x",bank,row,col,ddr2Addr);

				// Generate data
				//if (bVerbose) printf("Preparing data: ");
				for (i = 0; i < SIZE_DDR2_BUFFER/4; i=i+2)
				{
					pBufferWr[i] = (U32)row;
					pBufferWr[i] = (pBufferWr[i] << COL_WIDTH) | (U32)col;
					pBufferWr[i] = (pBufferWr[i] << 8) | ((U32)i+3);
					pBufferWr[i+1] = ~(pBufferWr[i]);
				}		

				if (bVerbose) printf(" | DATA[last-1] = %8x",pBufferWr[i-2]);
		
				// Clear the dp memory

				if (bVerbose) printf("\nClearing DP DDR2 Buffer: ");
				rc =  PlxPci_PciBarSpaceWrite(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferClr, SIZE_DDR2_BUFFER, BitSize32, FALSE);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }

				if (bVerbose) printf("OK");

				memset(pBufferRd, 0, SIZE_DDR2_BUFFER );

				// Initiate transfer
				rc = performDDR2Rd(pDevice, BarIndex, pBufferRd, ddr2Addr, FALSE);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }

				// Read data from the buffer
				if (bVerbose) printf("\nReading DP DDR2 Buffer: ");
				rc = PlxPci_PciBarSpaceRead(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferRd, SIZE_DDR2_BUFFER, BitSize32, bVerbose);
					if (rc != ApiSuccess) { bPass=FALSE; goto CLEANUP; }

				if (bVerbose) printf("OK");
				
				// Verify data against generated data
				if (bVerbose) printf("\nVerifying data: ");

				bCompare = TRUE;
				for (i = 0; i < SIZE_DDR2_BUFFER/4; i++)
				{
					if (pBufferWr[i] != pBufferRd[i])
					{
						printf("\nMismatch index= 0x%x: WR=%8x, RD=%8x\n",i,pBufferWr[i],pBufferRd[i]);
						bCompare = FALSE;
						break;
					}

					/*if (col == maxCol)
					{
						printf("\n%2x: WR=%8x, RD=%8x\n",i,pBufferWr[i],pBufferRd[i]);
					}*/
				}	

				bPass &= bCompare;

				//memcmp( pBufferWr, pBufferRd, SIZE_BUFFER ) != 0
				if (bCompare==FALSE)
				{
					printf("*ERROR* - Buffers do not match\n");
					{ bPass=FALSE; goto CLEANUP; }
				}
				else
				{
					if (bVerbose) printf("OK");
				}

				/*--------------------------------------------------------------
				  View data
				--------------------------------------------------------------*/
				if (bShowData )
				{
					printf("\nRD Buffer\n");
					for (i = 0; i < SIZE_DDR2_BUFFER/4; i++)
					{
						printf("%2x=%8x\n",i,pBufferRd[i]);
					}
				}
			} // col
		} // row
	} // bank

	if (bVerbose) printf("\nReading Complete"); else printf("OK");

	/*--------------------------------------------------------------
	  Cleanup
	--------------------------------------------------------------*/
CLEANUP:
	if (rc != ApiSuccess)
    {
        //printf("*ERROR* - API failed, unable to open PLX Device\n");
        PlxSdkErrorDisplay(rc);
    }

	printf("\nFreeing buffers: ");
    if (pBufferWr != NULL)
        free(pBufferWr);

    if (pBufferRd != NULL)
        free(pBufferRd);

    if (pBufferClr != NULL)
        free(pBufferClr);

    printf("OK\n");

	return(bPass);
}


/*******************************************************************************
Function:		makeDDR2Addr
Description:	makes a linear address recognized by MIG
*******************************************************************************/
U32 makeDDR2Addr( U16 bank, U16 row, U16 col )
	                           
{
			U32 v_linear;

	              
	      v_linear = col;
	      v_linear = v_linear | ((U32)row << COL_WIDTH);
	      v_linear = v_linear | ((U32)bank << (COL_WIDTH + ROW_WIDTH));
	      return(v_linear);
}

/*******************************************************************************
Function:		performDDR2Wr
Description:	writes data to intermediate buffer, then initials transfer to DDR2
*******************************************************************************/
RETURN_CODE performDDR2Wr(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U32* pBufferWr, U32 ddr2Addr, U8 bVerbose)
{
	RETURN_CODE rc;
	U16 burstCnt;
	U16 cmd;
	U32 wData;

	if (bVerbose) printf("\nLoading DDR2 DP buffer: ");
    rc =  PlxPci_PciBarSpaceWrite(pDevice, BarIndex, FPGA_MEMORY_LOC_0, pBufferWr, SIZE_DDR2_BUFFER, BitSize32, FALSE);

		if (rc != ApiSuccess) return (rc);

	if (bVerbose) printf("OK");

	if (bVerbose) printf("\nSetting up write transfer: ");

	// Set size and cmd 
	cmd = DDR2_CMD_WR;
	burstCnt = 16;
	wData = ((burstCnt-1) << 16 & 0xFFFF0000) | cmd;
	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_CMD_SZ,  wData);

		if (rc != ApiSuccess) return (rc);

	// Set address
	wData = ddr2Addr; 
	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_ADDR,  wData);

		if (rc != ApiSuccess) return (rc);

	// Initiate transfer
	wData = DDR2_CTRL_LOAD;
	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_CTRL, wData );

		if (rc != ApiSuccess) return (rc);

	if (bVerbose) printf("OK");

	// wait for transfer to complete then ack it.
	if (bVerbose) printf("\nWaiting for transfer to complete: ");

	waitBitSet(pDevice,BarIndex,FPGA_DDR2_STATUS, DDR2_STATUS_COMPLETE);

	if (bVerbose) printf("OK");

	if (bVerbose) printf("\nAck'ing completion: ");

	wData = DDR2_CTRL_ACK;

	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_CTRL, wData );

		if (rc != ApiSuccess) return (rc);

	waitBitClr(pDevice,BarIndex,FPGA_DDR2_STATUS, DDR2_STATUS_COMPLETE);

	if (bVerbose) 	printf("OK");

	return(rc);
}

/*******************************************************************************
Function:		performDDR2Rd
Description:	writes data to intermediate buffer, then initials transfer to DDR2
*******************************************************************************/
RETURN_CODE performDDR2Rd(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U32* pBufferRd, U32 ddr2Addr, U8 bVerbose)
{
	RETURN_CODE rc;
	U16 burstCnt;
	U16 cmd;
	U32 wData;

	memset(pBufferRd, 0, SIZE_DDR2_BUFFER );

	if (bVerbose) 	printf("\nSetting up read transfer");

	// Set size and cmd 
	cmd = DDR2_CMD_RD;
	burstCnt = 16;
	wData = ((burstCnt-1) << 16 & 0xFFFF0000) | cmd;
	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_CMD_SZ,  wData);

		if (rc != ApiSuccess) return(rc);

	// Set address
	wData = ddr2Addr;
	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_ADDR,  wData);

		if (rc != ApiSuccess) return(rc);

	// Initiate transfer
	wData = DDR2_CTRL_LOAD;
	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_CTRL, wData );

		if (rc != ApiSuccess) return(rc);

	if (bVerbose) 	printf("OK");

	// wait for transfer to complete then ack it.
	if (bVerbose) 	printf("\nWaiting for transfer to complete: ");

	waitBitSet(pDevice,BarIndex,FPGA_DDR2_STATUS, DDR2_STATUS_COMPLETE);

	if (bVerbose) 	printf("OK");

	if (bVerbose) 	printf("\nAck'ing completion: ");

	wData = DDR2_CTRL_ACK;

	rc = WriteDword(pDevice, BarIndex, FPGA_DDR2_CTRL, wData );

		if (rc != ApiSuccess) return(rc);

	waitBitClr(pDevice,BarIndex,FPGA_DDR2_STATUS, DDR2_STATUS_COMPLETE);

	if (bVerbose) 	printf("OK");

	return(rc);
}
