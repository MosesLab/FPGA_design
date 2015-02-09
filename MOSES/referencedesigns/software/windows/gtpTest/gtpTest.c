/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			gtpTest.c
Description:	Program to read & reset gtp counters
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-07-30	MF		Created
2008-08-25	MF		Corrected register reads/writes offsets
2008-09-20	MF		Corrected register reads/writes offsets
2008-11-11	MF		Add hss user io register control
2008-11-19	MF		Fixed GTP User IO sub-test
2009-03-19	MF		Cleanup include file ordering
2012-02-13	MF		Removed unused vars; fixed return types
*******************************************************************************/

/*===============
  HEADERS
===============*/
#include "gtpTest.h"

#define NUM_GTP 4
#define SLEEP_DELAY 10
#define MAX_RETRY 5

#define GTP_LB_NORMAL	0x0
#define GTP_LB_PCS	0x1
#define GTP_LB_PMA	0x2
#define GTP_BUF_SZ  64

U8 gtpRxCnt[NUM_GTP];
U8 gtpRxDone[NUM_GTP];
U8 gtpTxDone[NUM_GTP];
U8 gtpPllOk[NUM_GTP];

U8 gtpTxDoneCnt =0;
U8 gtpRxDoneCnt= 0;
U8 gtpPllOkCnt = 0;

U8 clrBuf[GTP_BUF_SZ];
U8 rxBuf[NUM_GTP][GTP_BUF_SZ];
U8 txBuf[NUM_GTP][GTP_BUF_SZ];
U32 gtpRxErrCnt[NUM_GTP];

#define HSS_USERIO_REGS
#define IO0 1
#define IO1 2
#define IO2 4
#define IO3 8

/*******************************************************************************
Description:	Displays buffer
*******************************************************************************/
void displayBuffer(U8* buf)
{
	U8 x;

	for(x=0;x<GTP_BUF_SZ;x++)
	{
		if ( (x & 0xF) == 0 )
			printf("\n");

		printf(" %2x |", buf[x]);
	}
}

/*******************************************************************************
Description:	Read and display all tx buffers
*******************************************************************************/
RETURN_CODE  readAndDisplayAllTx ( 	PLX_DEVICE_OBJECT* pDevice, U8 bar)
{
	U8 gtp;
		RETURN_CODE	rc;

	for (gtp = 0; gtp<NUM_GTP; gtp++)
	{
		printf("\nGTP %d TX",gtp);
		rc = PlxPci_PciBarSpaceRead(pDevice,bar,(FPGA_GTP_TX0_BUF+(gtp*GTP_BUF_SZ)),txBuf[gtp],GTP_BUF_SZ,BitSize32,FALSE);
			if (rc != ApiSuccess) return (rc);

		displayBuffer(&txBuf[gtp][0]);
	}
	return (rc);
}

/*******************************************************************************
Description:	Read and display all rx buffers
*******************************************************************************/
RETURN_CODE  readAndDisplayAllRx ( 	PLX_DEVICE_OBJECT* pDevice, U8 bar)
{
	U8 gtp;
		RETURN_CODE	rc;

	for (gtp = 0; gtp<NUM_GTP; gtp++)
	{
		printf("\nGTP %d RX",gtp);
		rc = PlxPci_PciBarSpaceRead(pDevice,bar,(FPGA_GTP_RX0_BUF+(gtp*GTP_BUF_SZ)),rxBuf[gtp],GTP_BUF_SZ,BitSize32,FALSE);
			if (rc != ApiSuccess) return (rc);

		displayBuffer(&rxBuf[gtp][0]);
	}
	return (rc);
}

/*******************************************************************************
Description:	Get status of all gtps
*******************************************************************************/
RETURN_CODE  gtpGetStatus ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex)
{
	RETURN_CODE	rc;
	U8 i;
	U32	rData;
	U8 rStatus;

	 gtpTxDoneCnt = 0;
	 gtpRxDoneCnt = 0;
	 gtpPllOkCnt = 0;

	rc = ReadDword(pDevice, BarIndex, FPGA_GTP_STA,  &rData);
					if (rc != ApiSuccess) return (rc);

	//printf("\nAddr%4x = %8x",FPGA_GTP_STA,rData);

	for(i=0; i<NUM_GTP; i++)
	{
		rStatus = (U8)((rData >> (i*8)) & 0xFF);
		gtpPllOk[i] = ((rStatus & GTP_STA_PLLOK) == GTP_STA_PLLOK);
		gtpPllOkCnt += gtpPllOk[i];

		gtpTxDone[i] = ((rStatus & GTP_STA_TX_DONE) == GTP_STA_TX_DONE);
		gtpTxDoneCnt += gtpTxDone[i];

		gtpRxDone[i] = ((rStatus & GTP_STA_RX_DONE) == GTP_STA_RX_DONE);
		gtpRxDoneCnt += gtpRxDone[i];
	}

	return(rc);
}

/*******************************************************************************
Description:	Send the tx packet, given the gtp number
*******************************************************************************/
U8	 gtpSendTxPkt ( 	PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 gtp, U8* txPkt, U8 pktSz,U8 lbMode,U8 bVerbose)
{
	RETURN_CODE	rc;
	U8 numRetry;
	U32	rData;
//	U8 rStatus;
	U8 ctrl;
//	U8 x,y;


	if(bVerbose ==TRUE) printf("\nWriting packet size");
	rc = WriteByte(pDevice, bar, FPGA_GTP_TXSZ + gtp,  pktSz);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	rc = ReadDword(pDevice, bar, FPGA_GTP_TXSZ,  &rData);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	if(bVerbose == TRUE) printf("\nPacket Sizes %4x = %8x", FPGA_GTP_TXSZ, rData);


	rc = ReadByte(pDevice, bar, FPGA_GTP_CTRL + gtp,  &ctrl);
		if (rc != ApiSuccess) return (rc);

	if(bVerbose == TRUE) printf("\nInitial control value= %x",ctrl);

	//ctrl &= (~GTP_CTRL_RX_START);
	//ctrl &= (~GTP_CTRL_TX_START);
	ctrl = 0;

	if(bVerbose == TRUE) printf("\nsetting lb mode");
	ctrl |= lbMode;
	rc = WriteByte(pDevice, bar, FPGA_GTP_CTRL + gtp,  ctrl);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	if(bVerbose == TRUE) printf("\nEnabling rx");
	ctrl |= GTP_CTRL_RX_START;

	rc = WriteByte(pDevice, bar, FPGA_GTP_CTRL + gtp,  ctrl);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	if(bVerbose == TRUE) printf("\nWriting packet to tx buffer");
	//GTP_BUF_SZ is maximum, pktSz is in bytes - 1
	rc = PlxPci_PciBarSpaceWrite(pDevice,bar,(FPGA_GTP_TX0_BUF+(gtp*GTP_BUF_SZ)),txPkt,(pktSz+1),BitSize32,FALSE);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	if(bVerbose == TRUE) printf("\nReading back packet from tx buffer");
	rc = PlxPci_PciBarSpaceRead(pDevice,bar,(FPGA_GTP_TX0_BUF+(gtp*GTP_BUF_SZ)),&txBuf[gtp][0],(pktSz+1),BitSize32,FALSE);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	//printf("\n Displaying tx buffer\n");
	//displayBuffer(&txBuf[gtp][0]);

	if (memcmp(txPkt,&txBuf[gtp][0],(pktSz+1)) != 0)
	{
		printf("failure, buffers not the same");
		readAndDisplayAllTx(pDevice,bar);
		return (FALSE);
	}

	if(bVerbose == TRUE) printf("\nEnabling tx");
	ctrl |= GTP_CTRL_TX_START;
	rc = WriteByte(pDevice, bar, FPGA_GTP_CTRL + gtp,  ctrl);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	if(bVerbose == TRUE) printf("\nWaiting for tx done");

	numRetry = 0; 
	do
	{
		rc = gtpGetStatus (pDevice,bar);
		CTISleep(SLEEP_DELAY);
		numRetry++;

	} while ((gtpTxDone[gtp] == 0)  && (rc == ApiSuccess) && (numRetry < MAX_RETRY));

	if (numRetry>=MAX_RETRY)
	{
		printf("\n tx timeout");
		return (FALSE);
	}

	if(bVerbose == TRUE) printf("\nTx Cnt = %d", gtpTxDoneCnt);

	if(bVerbose == TRUE) printf("\nDisabling tx");
	ctrl &= (~GTP_CTRL_TX_START);
	rc = WriteByte(pDevice, bar, FPGA_GTP_CTRL + gtp,  ctrl);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	if(bVerbose == TRUE) printf("\nClearing tx buffer");
	rc = PlxPci_PciBarSpaceWrite(pDevice,bar,(FPGA_GTP_TX0_BUF+(gtp*GTP_BUF_SZ)),clrBuf,GTP_BUF_SZ,BitSize32,FALSE);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	return (TRUE);
}

/*******************************************************************************
Description:	verify the rx packet, given the gtp number
*******************************************************************************/
U8	 gtpVerifyRxPkt ( PLX_DEVICE_OBJECT* pDevice, U8 bar, U8 gtp, U8* ptxPkt, U8 pktSz,U32* errCnt,U8 bVerbose)
{
	RETURN_CODE	rc;
	U8 numRetry;
//	U32	rData;
//	U8 rStatus;
//	U8 ctrl = 0;
	U8 i;
//	U32 errCnt = 0;


	if(bVerbose == TRUE) printf("\nWaiting for rx done");

	numRetry = 0; 
	do
	{
		rc = gtpGetStatus (pDevice,bar);
		CTISleep(SLEEP_DELAY);
		numRetry++;

	} while ((gtpRxDone[gtp] == 0)  && (rc == ApiSuccess) && (numRetry < MAX_RETRY));

	if (numRetry>=MAX_RETRY)
	{
		printf("\n rx timeout");
		return (FALSE);

	}

	if(bVerbose == TRUE) printf("\nRx Cnt = %d", gtpRxDoneCnt);

	if(bVerbose == TRUE) printf("\nReading packet from rx buffer");
	rc = PlxPci_PciBarSpaceRead(pDevice,bar,(FPGA_GTP_RX0_BUF+(gtp*GTP_BUF_SZ)),&rxBuf[gtp],(pktSz+1),BitSize32,FALSE);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	for(i = 0; i<(pktSz+1); i++)
	{
		if(ptxPkt[i] != rxBuf[gtp][i])
		{
			if(bVerbose == TRUE) printf("\n   compare error @ element %d",i);
			(*errCnt)++;
		}
	}

	/*if (memcmp(ptxPkt,&rxBuf[gtp][0],GTP_BUF_SZ) != 0)
	{
		printf("\nfailure, buffers not the same");
		printf("\nTX packet");
		displayBuffer(ptxPkt);
		readAndDisplayAllRx(pDevice,bar);

	
		return (ApiFailed);
	}*/
	if ((*errCnt) > 0 )
	{
		printf("\nComparison Error");
		if(bVerbose == TRUE) displayBuffer(&rxBuf[gtp][0]);
	}

	//printf("\nDisplaying rx buffer\n");
	//displayBuffer(&rxBuf[gtp][0]);

	if(bVerbose == TRUE) printf("\nClearing rx buffer");
	rc = PlxPci_PciBarSpaceWrite(pDevice,bar,(FPGA_GTP_RX0_BUF+(gtp*GTP_BUF_SZ)),&clrBuf,GTP_BUF_SZ,BitSize32,FALSE);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}

	if(bVerbose == TRUE) printf("\nDisabling rx");
	//ctrl &= (!GTP_CTRL_RX_START);
	rc = WriteByte(pDevice, bar, FPGA_GTP_CTRL + gtp,  0);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}


	return (TRUE);
	
}

U8 hssUserioTest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
	RETURN_CODE rc;
	#ifdef HSS_USERIO_REGS
	U8	bRval;
#else
	U32 wDWval;
	char selChar;
	int x;
#endif

	// HSS General I/O probing
#ifdef HSS_USERIO_REGS
	// note that hss user io registers are in bar 3 (SPI_BAR)
	// IO 0 is shorted to IO 1
	// IO 2 is shorted to IO 3

	printf("\nHSS User IO test: ");

	// Test 0, 2 out & 1,3 in 

	// set io0 and io2 as outputs
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_DIR,IO0 | IO2);
		if (rc != ApiSuccess) return (FALSE);

	//printf("\n set io0");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,IO0);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != (IO0 | IO1) )
	{
		printf("\n Read back failed, IO0 set = %x", bRval);
		return(FALSE);
	}

	//printf("\n  clr io0");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,0);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != 0)
	{
		printf("\n Read back failed, IO0 clr = %x", bRval);
		return(FALSE);
	}

	//printf("\n  set io2");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,IO2);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != (IO2 | IO3) )
	{
		printf("\n Read back failed, IO2 set = %x", bRval);
		return(FALSE);
	}

	//printf("\n  clr io2");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,0);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != 0)
	{
		printf("\n Read back failed, IO2 clr = %x", bRval);
		return(FALSE);
	}

	// -------------------------------------------
	// Test 0, 2 in & 1,3 out

	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_DIR,IO1 | IO3);
		if (rc != ApiSuccess) return (FALSE);

	//printf("\n  set io1");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,IO1);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != (IO0 | IO1))
	{
		printf("\n Read back failed, IO1 set = %x", bRval);
		return(FALSE);
	}

	//printf("\n  clr io1");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,0);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != 0)
	{
		printf("\n Read back failed, IO1 clr = %x", bRval);
		return(FALSE);
	}

	//printf("\n  set io3");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,IO3);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != (IO2 | IO3))
	{
		printf("\n Read back failed, IO1 set = %x", bRval);
		return(FALSE);
	}

	//printf("\n  clr");
	rc = WriteByte(pDevice,SPI_BAR,FPGA_HSS_OUT,0);
		if (rc != ApiSuccess) return (FALSE);

	// readback
	rc = ReadByte(pDevice,SPI_BAR,FPGA_HSS_IN,&bRval);
		if (rc != ApiSuccess) return (FALSE);

	if (bRval != 0)
	{
		printf("\n Read back failed, IO1 clr = %x", bRval);
		return(FALSE);
	}

	printf("OK");

#else
	printf("\nRemove highspeed loopback; attach test board");
	wDWval = 0x00010000;
	for(x=0;x<=3;x++)
	{
		rc = WriteDword(pDevice,BarIndex,0x2C,wDWval);
			if (rc != ApiSuccess) return (rc);
		printf("\nIs HSS %d on\n",x);
		
		do
		{
			printf("\r>> Enter y or n: ");
			selChar = getchar();
		} while ((selChar != 'y') && (selChar != 'n'));

		if (selChar == 'n')
			return(FALSE);

		rc = WriteDword(pDevice,BarIndex,0x2C,0x0);
			if (rc != ApiSuccess) return (rc);
		printf("\nIs HSS %d off\n",x);

		do
		{
			printf("\r>> Enter y or n: ");
			selChar = getchar();
		} while ((selChar != 'y') && (selChar != 'n'));

		if (selChar == 'n')
			return(FALSE);

		wDWval = wDWval << 1;
	}
#endif
		return(TRUE);
}

/*******************************************************************************
Function:		gtpScan
Description:	Display current GTP errors
*******************************************************************************/
U8  gtpTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
	RETURN_CODE	rc;
	U8 gtp,x,y;
//	U8 bPass = TRUE;
	U32 errCnt;
	U8 txPkt[GTP_BUF_SZ];
//  U8 tmpBuf[GTP_BUF_SZ];



	//rc = WriteDword(pDevice, BarIndex, FPGA_EEPROM_CMD_WDATA,  wData);
	//	if (rc != ApiSuccess) return (rc);



	if (hssUserioTest(pDevice,BarIndex,bVerbose,bi) == FALSE)
		return(FALSE);


	memset(clrBuf,0,GTP_BUF_SZ);

	gtpGetStatus(pDevice, BarIndex);

	printf("\nSTATUS: Pll Ok = %d, Tx Done = %d, Rx Done = %d",gtpPllOkCnt,gtpTxDoneCnt,gtpRxDoneCnt);

	if (gtpPllOkCnt < NUM_GTP)
	{
		printf("\nERROR: All PLLs not ok");
		return(FALSE);
	}
	//getch();

/*	while(!kbhit())
	{


		txPkt[0] =  0xFF;

		rc = gtpSendTxPkt(pDevice, BarIndex,gtp,&txPkt[0],(GTP_BUF_SZ-1),GTP_LB_NORMAL);
			if (rc != ApiSuccess) return(FALSE);
	}
*/
	
	for(gtp=0;gtp<NUM_GTP;gtp++)
	{
		if(bVerbose == TRUE) printf("\nClearing all rx buffers");
		rc = PlxPci_PciBarSpaceWrite(pDevice,BarIndex,(FPGA_GTP_RX0_BUF+(gtp*GTP_BUF_SZ)),&clrBuf[0],GTP_BUF_SZ,BitSize32,FALSE);
		if (rc != ApiSuccess) {PlxSdkErrorDisplay(rc); return (FALSE);}
	}

	//readAndDisplayAllRx(pDevice,BarIndex);
	//getch();


/*	for(x=0;x<256;x++)
	{
		memset(tmpBuf,x,GTP_BUF_SZ);
		rc = PlxPci_PciBarSpaceWrite(pDevice,BarIndex,(FPGA_GTP_RX0_BUF+(1*GTP_BUF_SZ)),&tmpBuf[0],GTP_BUF_SZ,BitSize32,FALSE);
			if (rc != ApiSuccess) return (rc);
		readAndDisplayAllRx(pDevice,BarIndex);
		getch();
	}
*/

	for(gtp=0;gtp<NUM_GTP;gtp++)
	{
		gtpRxErrCnt[gtp] = 0;

		printf("\n GTP %d: ",gtp);

		for (y=0;y<16;y++)
		{
			for(x=1;x<GTP_BUF_SZ;x++)
			{
				if (y > 0)
					txPkt[x] = y;
				else
					txPkt[x] = x;
			}

			txPkt[0] =  0xFF;

			printf(" %d", y);
			
			if ( gtpSendTxPkt(pDevice, BarIndex,gtp,&txPkt[0],((GTP_BUF_SZ)/2-1),GTP_LB_NORMAL,bVerbose) == FALSE)
				return(FALSE);

			errCnt = 0;
			if ( gtpVerifyRxPkt(pDevice, BarIndex,gtp,&txPkt[0],((GTP_BUF_SZ/2)-1), &errCnt,bVerbose) == FALSE )
				return(FALSE);

			gtpRxErrCnt[gtp] += errCnt;
			if ((errCnt > 0) && (bVerbose == TRUE))
			{
				CTIPause();
			}
		}
	}

	for (gtp=0; gtp<NUM_GTP; gtp++)
	{
		if (gtpRxErrCnt[gtp] > 16)
		{
			printf("\nToo many errors on GTP %d",gtp);
			return(FALSE);
		}
	}

	

	return(TRUE);
}

