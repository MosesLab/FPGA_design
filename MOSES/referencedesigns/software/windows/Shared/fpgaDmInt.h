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
2009-03-11	MF		Added include dependencies from .c
*******************************************************************************/

#ifndef FPGADMINT_H
#define FPGADMINT_H

#include "PlxInit.h"
#include "FPGAReg.h"

RETURN_CODE FPGAIntWait(PLX_PTR plxPtr, U32 fpgaInterrupt, U32 timeout_ms);
RETURN_CODE FPGAIntMask(PLX_DEVICE_OBJECT* pDevice, U32 mask);
RETURN_CODE FPGAIntUnMask(PLX_DEVICE_OBJECT* pDevice, U32 mask);
RETURN_CODE FPGADMSetup(PLX_DEVICE_OBJECT* pDevice, U32 pciAddr, U32 localAddr, U32 dwordCnt, U8 opType);

#endif