/*******************************************************************************
Copyright (c) 2009 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			fpgaDmInt.c
Description:	FPGA direct master and interrupt functions
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2009-02-26	MF		Created
2009-03-11	MF		Moved include dependencies to .h
*******************************************************************************/

#include "fpgaDmInt.h"

RETURN_CODE FPGAIntMask(PLX_DEVICE_OBJECT* pDevice, U32 mask)
{
	RETURN_CODE rc;
	U32			rValue;
				
	rc = ReadDword(pDevice,USR_BAR,FPGA_INTERRUPT_MASK,&rValue);

	if (rc != ApiSuccess)
	{
		printf("*ERROR* - API failed\n");
		PlxSdkErrorDisplay(rc);
	}

	rValue = rValue | INTERRUPT_DM;
	
	rc = WriteDword(pDevice,USR_BAR,FPGA_INTERRUPT_MASK,rValue);
	
	if (rc != ApiSuccess)
	{
		printf("*ERROR* - API failed\n");
		PlxSdkErrorDisplay(rc);
	}

	return(rc);
}

RETURN_CODE FPGAIntUnMask(PLX_DEVICE_OBJECT* pDevice, U32 mask)
{
	RETURN_CODE rc;
	U32			rValue;
				
	rc = ReadDword(pDevice,USR_BAR,FPGA_INTERRUPT_MASK,&rValue);

	if (rc != ApiSuccess)
	{
		//printf("*ERROR* - API failed\n");
		//PlxSdkErrorDisplay(rc);
		return(rc);
	}

	rValue = rValue & ~INTERRUPT_DM;
	
	rc = WriteDword(pDevice,USR_BAR,FPGA_INTERRUPT_MASK,rValue);
	
	//if (rc != ApiSuccess)
	//{
		//printf("*ERROR* - API failed\n");
		//PlxSdkErrorDisplay(rc);
	//}

	return(rc);
}


RETURN_CODE FPGADMSetup(PLX_DEVICE_OBJECT* pDevice, U32 pciAddr, U32 localAddr, U32 dwordCnt, U8 opType) 
{
	RETURN_CODE rc;
	U32			control = 0;
	U32			remap;
	U32			remapNew;
//	U32			rVal;

	// read the remap register first, we don't want to clober any of the settings.
	remap = PlxPci_PlxRegisterRead(pDevice, PCI9056_DM_PCI_MEM_REMAP, &rc);

	remapNew = pciAddr | (0x0000FFFF & remap );

	rc = PlxPci_PlxRegisterWrite(pDevice, PCI9056_DM_PCI_MEM_REMAP, remapNew);
	if (rc != ApiSuccess)
		return(rc);

/*
	rVal  = PlxPci_PlxRegisterRead(pDevice, PCI9056_DM_MEM_BASE, &rc);
  	if (rc != ApiSuccess)
		return(rc);

	printf("\nPCI9056_DM_MEM_BASE (DMLBAM) = %8x", rVal);

	rc = PlxPci_PlxRegisterWrite(pDevice, PCI9056_DM_MEM_BASE, localAddr);
	if (rc != ApiSuccess)
		return(rc);
*/

	// Set local address
	rc = WriteDword(pDevice,USR_BAR,FPGA_DM_ADDR,localAddr); //0x00010000

    if (rc != ApiSuccess)
    {
		return(rc);
    }

	// Set byte count
    //rc = PlxPci_PciBarSpaceWrite(&Device,2,0x38,pBufferSrc,4,BitSize32,FALSE);
	rc = WriteDword(pDevice,USR_BAR,FPGA_DM_CNT,dwordCnt);  // 0x10

    if (rc != ApiSuccess)
    {
		return(rc);
    }

	// Clear command, then set write command
    rc = WriteDword(pDevice,USR_BAR,FPGA_DM_CTRL,0x0);

    if (rc != ApiSuccess)
    {
		return(rc);
    }

	control = DM_OP_START | opType;

	rc = WriteDword(pDevice,USR_BAR,FPGA_DM_CTRL,control);

/*    if (rc != ApiSuccess)
    {
		return(rc);
    }*/

	return (rc);
}


RETURN_CODE FPGAIntWait(PLX_PTR plxPtr, U32 fpgaInterrupt, U32 timeout_ms)
{
	RETURN_CODE rc, rc2;
	U32 rValue;

	rc = PlxPci_InterruptEnable(plxPtr.pDevice,plxPtr.pInterrupt);
			if (rc != ApiSuccess) return(rc);

	rc = PlxPci_NotificationWait(plxPtr.pDevice, plxPtr.pEvent, timeout_ms); // wait for 5000 seconds

	switch (rc)
	{
		case ApiSuccess:
			// Interrupt occurred
			// Read FPGA interrupt source
			rc = ReadDword(plxPtr.pDevice,USR_BAR,FPGA_INTERRUPT_SOURCE,&rValue);

			if (rc != ApiSuccess)
			{
				printf("*ERROR* - API failed\n");
				PlxSdkErrorDisplay(rc);
			}

			if (rValue & fpgaInterrupt)
			{
				//
			}
			else
			{
				printf("Interrupt source = %x\n", rValue);
			}
			break;
		case ApiWaitTimeout:
			printf("*ERROR* - API failed, Timeout waiting for Interrupt Event\n");
			break;
		case ApiWaitCanceled:
		case ApiFailed:
		default:
			printf("*ERROR* - API failed, Failed while waiting for interrupt\n");
			break;
	}

	rc2 = PlxPci_InterruptDisable(plxPtr.pDevice,plxPtr.pInterrupt);
		if (rc2 != ApiSuccess) 	{ 	PlxSdkErrorDisplay(rc2); }

	return (rc);
}