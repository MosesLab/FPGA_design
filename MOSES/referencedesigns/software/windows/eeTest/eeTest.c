/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			eetest.c
Description:	Program to test eeprom; built from VHDL test bench
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-04-18	MF		Created
2008-04-21	MF		Changing display messages
2008-06-04	MF		Separate test() from main(), for use in one large test app
2008-08-28	MF		Disable some of the operations for manufacturing test
2009-03-19	MF		Cleanup include file ordering
2012-02-16	MF		Some improvements for running under Linux
*******************************************************************************/

/*===============
  HEADERS
===============*/
#include "eeTest.h"

/*******************************************************************************
Function:		eeTest
Description:	reads, writes, erase eeprom
*******************************************************************************/
U8  eeTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
	RETURN_CODE	rc;
	U16	wData;
	U16	rData;
	U16 i;
	U8 bPass = TRUE;


	printf("\nEEPROM Erase all: \n");
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwen,0x0,0x0,&rData);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEral,0x0,0x0,&rData);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwds,0x0,0x0,&rData);

	printf("...OK");

	//-------------------------------------------		
	printf("\nEEPROM read all (blank check): \n");

	for (i=0;i<256;i++)
	{
		
		rc = mwOperation(pDevice,BarIndex,c_mwOpRead,(U8)i,0x0, 0x0, &rData);

		wData = 0xFFFF;
		if ( wData != rData )
		{
			printf("\nError: expected %x read %x", wData, rData);
			return(FALSE);
		}
		if (!bVerbose) CTISleep(0); //Delay slightly ; runs too fast under linux
	}
	
	printf("...OK");

	//-------------------------------------------
	printf("\nEEPROM Write test #1: \n");
	
	// EWEN Write enable
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwen,0x0,0x0,&rData);

	for(i=0;i<256;i++)	
	{
		if (bVerbose) printf("  \r Write %d = 0x%02x", i, (0xEF00 | i));		
		rc = mwOperation(pDevice,BarIndex,c_mwOpWrite,(U8)i,(0xEF00 | i), 0x0, &rData);
		
		if (!bVerbose) CTISleep(4); //Delay slightly ; runs too fast under linux; write cycle is max 10 ms
	}

	// EWDS Write Disable
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwds,0x0,0x0,&rData);

	printf("...OK");

	//-------------------------------------------
	printf("\nEEPROM Read test: \n");

	for (i=0;i<256;i++)
	{		
		rc = mwOperation(pDevice,BarIndex,c_mwOpRead,(U8)i,0x0, 0x0, &rData);
		if (bVerbose) printf("\r Read %d =0x%02x", i, rData);

		wData = (0xEF00 | i);
		if ( wData != rData )
		{
			printf("\nError: expected %x read %x", wData, rData);
			return(FALSE);
		}
		if (!bVerbose) CTISleep(0); //Delay slightly ; runs too fast under linux
	}

	printf("...OK");

	//-------------------------------------------		
	printf("\nEEPROM Write test #2: \n");
	
	// EWEN Write enable
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwen,0x0,0x0,&rData);

	for(i=16; i<32; i++)
	{
		if (bVerbose) printf("  \r Write %d = 0x%02x", i, (0xAB00 | i));
		rc = mwOperation(pDevice,BarIndex,c_mwOpWrite,(U8)i,(0xAB00 | i), 0x0, &rData);
		
		if (!bVerbose) CTISleep(4); //Delay slightly ; runs too fast under linux
	}

	// EWDS Write Disable
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwds,0x0,0x0,&rData);

	printf("...OK");

	//-------------------------------------------
	printf("\nEEPROM Read test 2: \n");

	for (i=16;i<32;i++)
	{		
		rc = mwOperation(pDevice,BarIndex,c_mwOpRead,(U8)i,0x0, 0x0, &rData);
		if (bVerbose) printf("\r Read %d =0x%02x", i, rData);

		wData = (0xAB00 | i);
		if ( wData != rData )
		{
			printf("\nError: expected %x read %x", wData, rData);
			return(FALSE);
		}
		if (!bVerbose) CTISleep(0); //Delay slightly ; runs too fast under linux
	}

	printf("...OK");

	//-------------------------------------------		
	printf("\nEEPROM Read 16: \n");
	
	rc = mwOperation(pDevice,BarIndex,c_mwOpRead,16,0x0, 0xF, &rData);

	wData = 0xAB1F;

	if ( wData != rData )
	{
		printf("\nError: expected %x read %x", wData, rData);
		return(FALSE);
	}
		
	printf("...OK");

// Not all oeprations required for manufacturing test, reading / writing is sufficient.
#ifdef TEST_ALL_OPERATIONS
	//-------------------------------------------			
	printf("\nEEPROM Erase all, w/o enable: ");
	//mwOperation(c_mwOp, c_mwAddrEral & "000000", x"0000", x"0", v_di);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEral,0x0,0x0,&rData);

	printf("OK");

	//-------------------------------------------		
	printf("\nEEPROM Erase all, w/ enable: ");
	//mwOperation(c_mwOp, c_mwAddrEwen & "000000", x"0000", x"0", v_di);
	//mwOperation(c_mwOp, c_mwAddrEral & "000000", x"0000", x"0", v_di);
	//mwOperation(c_mwOp, c_mwAddrEwds & "000000", x"0000", x"0", v_di);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwen,0x0,0x0,&rData);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEral,0x0,0x0,&rData);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwds,0x0,0x0,&rData);

	printf("OK");

	//-------------------------------------------		
	printf("\nEEPROM read all: ");

	for (i=0;i<256;i++)
	{
		
		//printf("\r Read %d", i);
		//mwOperation(c_mwOpRead, to_stdlogic(i,8), x"0000", x"0", v_di);
		rc = mwOperation(pDevice,BarIndex,c_mwOpRead,(U8)i,0x0, 0x0, &rData);

		wData = 0xFFFF;
		if ( wData != rData )
		{
			printf("\nError: expected %x read %x", wData, rData);
			return(FALSE);
		}
	}
	
	printf(" Done");

	//-------------------------------------------				
	printf("\nEEPROM write all, w/ enable: ");
	//mwOperation(c_mwOp, c_mwAddrEwen & "000000", x"0000", x"0", v_di);
	//mwOperation(c_mwOp, c_mwAddrWral & "000000", x"B00B", x"0", v_di);
	//mwOperation(c_mwOp, c_mwAddrEwds & "000000", x"0000", x"0", v_di);	
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwen,0x0,0x0,&rData);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrWral,0xB00B,0x0,&rData);
	rc = mwOperation(pDevice,BarIndex,c_mwOp,c_mwAddrEwds,0x0,0x0,&rData);

	printf(" Done");

	//-------------------------------------------		
	printf("\nEEPROM read all: ");

	for (i=0;i<256;i++)
	{
		
		//printf("\r Read %d", i);
		//mwOperation(c_mwOpRead, to_stdlogic(i,8), x"0000", x"0", v_di);
		rc = mwOperation(pDevice,BarIndex,c_mwOpRead,(U8)i,0x0, 0x0, &rData);

		wData = 0xB00B;
		if ( wData != rData )
		{
			printf("\nError: expected %x read %x", wData, rData);
			return(FALSE);
			break;
		}
	}

	printf(" Done");
#endif

	return(bPass);
}


/*******************************************************************************
Function:		mwOperation
Description:	writes microwire command, and waits for completion
*******************************************************************************/
RETURN_CODE  mwOperation ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 op, U8 addr, U16 datao, U8 cnt, U16* datai)
{			
	RETURN_CODE	rc;
	U32	wData;
	U32	rData;
	//constant c_eepromo : std_logic_vector(63 downto 0) := bar_addr(2) + x"50";
	//constant c_eepromi : std_logic_vector(63 downto 0) := bar_addr(2) + x"54";

	wData = 0;
	wData |= (datao << 16); //& 0xFFFF0000;	// wdata(31 downto 16) := do;
	wData |= (addr << 8); //& 0x0000FF00;	// wdata(15 downto 8) := addr;
	wData |= (cnt << 4); //& 0x000000F0;	// wdata(7 downto 4) := cnt;
	wData |= (op << 1); //& 0x00000006;	// wdata(2 downto 1) := op;
	wData |= 0x1;
		
	rc = WriteDword(pDevice, BarIndex, FPGA_EEPROM_CMD_WDATA,  wData);
		if (rc != ApiSuccess) return (rc);

	rData = 0;
	while ((rData & 0x1) != 0x1)
	{
		rc = ReadDword(pDevice, BarIndex, FPGA_EEPROM_STA_RDATA,  &rData);
			if (rc != ApiSuccess) return (rc);
		CTISleep(5);
	}

	*datai = (U16)(rData >> 16);  //rdata(31 downto 16);
				
	wData = 0;

	rc = WriteDword(pDevice, BarIndex, FPGA_EEPROM_CMD_WDATA,  wData);
		if (rc != ApiSuccess) return (rc);

	rData = 0;
	while ((rData & 0x1) != 0x0)
	{
		rc = ReadDword(pDevice, BarIndex, FPGA_EEPROM_STA_RDATA,  &rData);
			if (rc != ApiSuccess) return (rc);
		CTISleep(5);
	}
	
	rc = ApiSuccess;

	return(rc);
}
