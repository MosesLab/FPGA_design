/*******************************************************************************
Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			serialTest.c
Description:	Program to test serial ports; built from VHDL test bench
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-04-21	MF		Created
2008-04-21	MF		Add pre-empty of buffers; add rate of 1 mbps
2008-06-04	MF		Separate test() from main(), for use in one large test app
2008-08-25	MF		Cleanup debug / progress statement,add verbosity
2009-03-19	MF		Cleanup include file ordering
*******************************************************************************/

/*===============
HEADERS
===============*/
#include "serialTest.h"

U8  serialTestBothDir ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
	U8 bPass = TRUE;

	bPass = bPass &	serialTest( pDevice, BarIndex, bVerbose, TRUE );
	bPass = bPass &	serialTest( pDevice, BarIndex, bVerbose, FALSE );

	return(bPass);
}

/*******************************************************************************
Function:		serialTest
Description:	writes to Port A, reads from Port B.  A and B determined by dir
*******************************************************************************/
U8  serialTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, U8 dir)
{
	RETURN_CODE	rc;
	//U32	wData;
	U8 wByte;
	U32	rData;
	U8 wChar; 
	U8 rChar; 
	U8 status; 
	U8 i;
	U32 rsa_ctrl_tx;
	U32 rsa_status_rx;
	U32 rsb_ctrl_tx;
	U32 rsb_status_rx;
	U8 bPass = TRUE;

	U8 timeOut;

	if (dir == TRUE)
	{
		printf("\n~~~~~~~~~~~~\nRS0 -> RS1\n");
		rsa_ctrl_tx = FPGA_RS0_CTRL_AND_TX;
		rsa_status_rx = FPGA_RS0_STAT_AND_RX;
		
		rsb_ctrl_tx = FPGA_RS1_CTRL_AND_TX;
		rsb_status_rx = FPGA_RS1_STAT_AND_RX;				
	}
	else
	{
		printf("\n~~~~~~~~~~~~\nRS1 -> RS0\n");
		rsa_ctrl_tx = FPGA_RS1_CTRL_AND_TX;
		rsa_status_rx = FPGA_RS1_STAT_AND_RX;

		rsb_ctrl_tx = FPGA_RS0_CTRL_AND_TX;
		rsb_status_rx = FPGA_RS0_STAT_AND_RX;					
	}

	printf("\nEmptying receive buffers: ");

	while (1)
	{
			CTISleep(WAIT_MS);
			//READ_DWORD_PCI(rsb_status_rx, rdata, MEM_RD,0x"0", false);
			rc = ReadDword(pDevice, BarIndex, rsa_status_rx,  &rData);
				if (rc != ApiSuccess) return (rc);

			status = (U8)((rData >> 16) & 0xFF) ; //rdata(23 downto 16);
			rChar = (U8)(rData & 0xFF);

			if ((status & RS_STATUS_RX_DATA_PRESENT) == RS_STATUS_RX_DATA_PRESENT)
			{
				if (bVerbose) printf("Read = %x\n", rChar);

				rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL,  RS_CTRL_RX_POP);
					if (rc != ApiSuccess) return (rc);
		
				rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL,  RS_CTRL_CLEAR);
					if (rc != ApiSuccess) return (rc);
			}
			else
			{
				break;
			}
	}

	while (1)
	{
			CTISleep(WAIT_MS);
			//READ_DWORD_PCI(rsb_status_rx, rdata, MEM_RD,0x"0", false);
			rc = ReadDword(pDevice, BarIndex, rsb_status_rx,  &rData);
				if (rc != ApiSuccess) return (rc);

			status = (U8)((rData >> 16) & 0xFF) ; //rdata(23 downto 16);
			rChar = (U8)(rData & 0xFF);

			if ((status & RS_STATUS_RX_DATA_PRESENT) == RS_STATUS_RX_DATA_PRESENT)
			{
				if (bVerbose) printf("Read = %x\n", rChar);

				rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL,  RS_CTRL_RX_POP);
					if (rc != ApiSuccess) return (rc);
		
				rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL,  RS_CTRL_CLEAR);
					if (rc != ApiSuccess) return (rc);
			}
			else
			{
				break;
			}
	}
	printf("OK");

	printf("\nChanging transmit rate to 27 factor: ");
	
	//wdata(31 downto 24) =0x"1B";	 -- ctrl
	//WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "0111", false);	
	//WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "0111", false);		
	wByte = 0x1B;
	rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_RATE,  wByte);
		if (rc != ApiSuccess) return (rc);
	rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_RATE,  wByte);
		if (rc != ApiSuccess) return (rc);

	rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL,  RS_CTRL_CLEAR);
			if (rc != ApiSuccess) return (rc);

	printf("OK");

	printf("\nWrite one byte then read one byte, 8 times: ");
	//-- write character
	for (i=0;i<=7;i++)
	{
		wChar = 0x41 + i;
		
		/*wdata(7 downto 0) = wChar;  	-- data
		wdata(15 downto 8) =0x"00"; 	-- nothing
		wdata(23 downto 16) =0x"01";	 -- ctrl
		wdata(31 downto 24) =0x"00";    -- baud mult

		WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "1000", false);*/
		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_TXDATA,  wChar);
			if (rc != ApiSuccess) return (rc);
		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL,  RS_CTRL_TX_PUSH);
			if (rc != ApiSuccess) return (rc);
		
		//-- wait for character to be recv'd
		status = 0;
		
		// check status bit 4


		timeOut = 0;
		
		do
		{
			CTISleep(WAIT_MS);
			//READ_DWORD_PCI(rsb_status_rx, rdata, MEM_RD,0x"0", false);
			rc = ReadDword(pDevice, BarIndex, rsb_status_rx,  &rData); // was rsb_status_rx
				if (rc != ApiSuccess) return (rc);

			status = (U8)((rData >> 16) & 0xFF) ; //rdata(23 downto 16);
			rChar = (U8)(rData & 0xFF);

			timeOut++;

			if (timeOut > 20)
			{
				break;
			}

		} while ((status & RS_STATUS_RX_DATA_PRESENT) != RS_STATUS_RX_DATA_PRESENT);

		if (bVerbose) printf("Read = %x\n", rChar);
		if( rChar != wChar)
		{
			printf( "Error: expected %x, read %x\n",wChar,rChar);
			return(FALSE);
		}

		//-- pop rdata off
		/*wdata = (others => '0');
		wdata(23 downto 16) =0x"02";
		WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "1011", false);*/

		rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL,  RS_CTRL_RX_POP); // rsb_ctrl_tx
			if (rc != ApiSuccess) return (rc);
		
		//-- clear pop, push
		/*wdata = (others => '0');
		WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "1011", false);
		WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "1011", false);*/

		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL,  RS_CTRL_CLEAR);
			if (rc != ApiSuccess) return (rc);
		rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL,  RS_CTRL_CLEAR);
			if (rc != ApiSuccess) return (rc);

		if (timeOut > 20)
			return(FALSE);
	}
	
	printf("OK");
	//--------------------------------------------

//printf("\n[PRESS ENTER TO CONTINUE]\n");
//getch();
	printf("\nChanging transmit rate to 3 factor (1.042 Mbit): ");
	/*wdata = (others =>'0');
	wdata(31 downto 24) =0x"03";	 -- ctrl
	WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "0111", false);	
	WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "0111", false);	*/
	wByte = 0x3;
	rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_RATE,  wByte);
		if (rc != ApiSuccess) return (rc);
	rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_RATE,  wByte);
		if (rc != ApiSuccess) return (rc);

	printf("Ok");

	printf("\nLoad transmit buffer with 16 chars, then wait for half full to read: ");
	//-- load fifo
	for(i=0;i<=15;i++)
	{
		wChar = 0xC0 + i;
		
		/*wdata = (others =>'0');
		wdata(7 downto 0) = wChar;  	-- data
		wdata(23 downto 16) =0x"01";	 -- ctrl
		
		WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "1000", false);	*/

		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_TXDATA, wChar);
			if (rc != ApiSuccess) return (rc);
		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL, RS_CTRL_TX_PUSH);
			if (rc != ApiSuccess) return (rc);

		/*wdata = (others => '0');
		WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "1011", false);		*/

		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL, RS_CTRL_CLEAR);
			if (rc != ApiSuccess) return (rc);
	}
	
	//-- wait for half full
	if (bVerbose) printf("\nWaiting for half full");

	do
	{
		CTISleep(WAIT_MS);
		/*READ_DWORD_PCI(rsb_status_rx, rdata, MEM_RD,0x"0", false);
		status = rdata(23 downto 16);*/
		rc = ReadDword(pDevice, BarIndex, rsb_status_rx,  &rData);
				if (rc != ApiSuccess) return (rc);

		status = (U8)((rData >> 16) & 0xFF) ; //rdata(23 downto 16);
		rChar = (U8)(rData & 0xFF);
	} while ((status & RS_STATUS_RX_HALF_FULL) != RS_STATUS_RX_HALF_FULL);
	
	if (bVerbose) printf("\nReading characters");
	for( i=0; i<=15; i++)
	{

		wChar =0xC0 + i;
		
		do 
		{
			CTISleep(WAIT_MS);

			rc = ReadDword(pDevice, BarIndex, rsb_status_rx,  &rData);
				if (rc != ApiSuccess) return (rc);

			status = (U8)((rData >> 16) & 0xFF) ; //rdata(23 downto 16);
			rChar = (U8)(rData & 0xFF);
		} 
		while ((status & RS_STATUS_RX_DATA_PRESENT) != RS_STATUS_RX_DATA_PRESENT); 
		
		if (bVerbose) printf("\nRead = %x", rChar);
		if( rChar != wChar)
		{
			printf( "\nError: expected %x, read %x",wChar,rChar);
			return(FALSE);
		}
		
		//-- pop rdata off
		/*wdata = (others => '0');
		wdata(23 downto 16) =0x"02";
		WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "1011", false);*/

		rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL, RS_CTRL_RX_POP);
			if (rc != ApiSuccess) return (rc);

		//-- clear pop
		/*wdata = (others => '0');
		WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "1011", false);				*/

		rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL,  RS_CTRL_CLEAR);
			if (rc != ApiSuccess) return (rc);
	}

	printf("OK");

//printf("\n[PRESS ENTER TO CONTINUE]\n");
//getch();
	printf("\nChanging transmit rate, to 1 factor (3.125Mbit): ");
	/*wdata = (others =>'0');
	wdata(31 downto 24) =0x"03";	 -- ctrl
	WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "0111", false);	
	WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "0111", false);	*/
	wByte = 0x1;
	rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_RATE,  wByte);
		if (rc != ApiSuccess) return (rc);
	rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_RATE,  wByte);
		if (rc != ApiSuccess) return (rc);

	printf("OK");
	printf("\nLoad transmit buffer with 16 chars, then wait for half full to read: ");
	//-- load fifo
	for(i=0;i<=15;i++)
	{
		wChar = 0xE0 + i;
		
		/*wdata = (others =>'0');
		wdata(7 downto 0) = wChar;  	-- data
		wdata(23 downto 16) =0x"01";	 -- ctrl
		
		WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "1000", false);	*/

		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_TXDATA, wChar);
			if (rc != ApiSuccess) return (rc);
		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL, RS_CTRL_TX_PUSH);
			if (rc != ApiSuccess) return (rc);

		/*wdata = (others => '0');
		WRITE_DWORD_PCI(rsa_ctrl_tx, wdata, MEM_WR, "1011", false);		*/

		rc = WriteByte(pDevice, BarIndex, rsa_ctrl_tx+REG_CTRL, RS_CTRL_CLEAR);
			if (rc != ApiSuccess) return (rc);
	}
	
	//-- wait for half full
	if (bVerbose) printf("\nWaiting for half full");

	do
	{
		CTISleep(WAIT_MS);
		/*READ_DWORD_PCI(rsb_status_rx, rdata, MEM_RD,0x"0", false);
		status = rdata(23 downto 16);*/
		rc = ReadDword(pDevice, BarIndex, rsb_status_rx,  &rData);
				if (rc != ApiSuccess) return (rc);

		status = (U8)((rData >> 16) & 0xFF) ; //rdata(23 downto 16);
		rChar = (U8)(rData & 0xFF);
	} while ((status & RS_STATUS_RX_HALF_FULL) != RS_STATUS_RX_HALF_FULL);
	
	if (bVerbose) printf("\nReading characters");
	for( i=0; i<=15; i++)
	{

		wChar =0xE0 + i;
		
		do 
		{
			CTISleep(WAIT_MS);

			rc = ReadDword(pDevice, BarIndex, rsb_status_rx,  &rData);
				if (rc != ApiSuccess) return (rc);

			status = (U8)((rData >> 16) & 0xFF) ; //rdata(23 downto 16);
			rChar = (U8)(rData & 0xFF);
		} 
		while ((status & RS_STATUS_RX_DATA_PRESENT) != RS_STATUS_RX_DATA_PRESENT); 
		
		if (bVerbose) printf("\nRead = %x", rChar);
		if( rChar != wChar)
		{
			printf( "\nError: expected %x, read %x",wChar,rChar);
			return(FALSE);
		}
		
		//-- pop rdata off
		/*wdata = (others => '0');
		wdata(23 downto 16) =0x"02";
		WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "1011", false);*/

		rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL, RS_CTRL_RX_POP);
			if (rc != ApiSuccess) return (rc);

		//-- clear pop
		/*wdata = (others => '0');
		WRITE_DWORD_PCI(rsb_ctrl_tx, wdata, MEM_WR, "1011", false);				*/

		rc = WriteByte(pDevice, BarIndex, rsb_ctrl_tx+REG_CTRL,  RS_CTRL_CLEAR);
			if (rc != ApiSuccess) return (rc);
	}

	printf("OK");
	return(bPass);
}

