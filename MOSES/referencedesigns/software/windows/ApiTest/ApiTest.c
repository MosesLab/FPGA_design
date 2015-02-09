/*******************************************************************************
Modified from 
ApiTest.c, 06-29-07 : PLX SDK v5.10
********************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			APITest.c
Description:	
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2009-03-19	MF		Cleanup include file ordering
2012-05-22	MF		Reduce size of phy mem request
*******************************************************************************/

// HEADERS
#include "ApiTest.h"

/******************************************************************************
 *
 * Function   :  main
 *
 * Description:  The main entry point
 *
 *****************************************************************************/
U8 APITest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* pbi)
{
	U8 bPass = TRUE;

	bPass = TestChipTypeGet(pDevice, pbi->plxDeviceType);
	if (!bPass) return (FALSE);

	//TestPlxRegister(pDevice, 0x9056);
	//TestPciBarMap(pDevice);
	bPass = TestPhysicalMemAllocate(pDevice);
	if (!bPass) return (FALSE);

	bPass = TestEeprom(pDevice, pbi->plxDeviceType);
	if (!bPass) return (FALSE);

	//bPass &= TestInterruptNotification(pDevice, 0x9056); << not supported for some reason
	return(TRUE);
}

/******************************************************************************
 *
 * Function   :  TestChipTypeGet
 *
 * Description:  
 *
 *****************************************************************************/
U8 TestChipTypeGet(PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected)
{
    U8          Revision;
    U16         ChipType;
    RETURN_CODE rc;


    printf("  Getting PLX Chip Type.......... ");
    rc = PlxPci_ChipTypeGet(pDevice,&ChipType,&Revision);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf("Ok\n");
    }


    printf("    Chip type:  %04x", ChipType);

    if (ChipType != (U16)ChipTypeSelected)
    {
        printf(" Invalid Chiptype");
		return(FALSE);
    }
    printf("\n");

    printf("    Revision :    %02X\n",Revision);

	return(TRUE);
}




/********************************************************
 *
 *******************************************************/
void
TestPlxRegister(
    PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected
    )
{
    U16         offset;
    U32         RegValue;
    U32         ValueToWrite;
    U32         RegSave;
    RETURN_CODE rc;


    printf("\nPlxPci_PlxRegisterXxx():\n");

    // Set default write value
    ValueToWrite = 0x1235A5A5;

    // Setup test parameters
    switch (ChipTypeSelected)
    {
        case 0x8111:
        case 0x8112:
            offset = 0x1030;
            break;

        case 0x8114:
        case 0x8505:
        case 0x8508:
        case 0x8509:
        case 0x8516:
        case 0x8517:
        case 0x8518:
        case 0x8512:
        case 0x8524:
        case 0x8525:
        case 0x8532:
        case 0x8533:
        case 0x8547:
        case 0x8548:
            offset = 0x210;
            break;

        case 0x9050:
        case 0x9030:
            offset = 0x14;
            ValueToWrite = 0x0235A5A5;   // Upper nibble not writable
            break;

        case 0x9080:
        case 0x9054:
        case 0x9056:
        case 0x9656:
            offset = 0x78;
            break;

        case 0x0:
        default:
            printf(
                "  - Unsupported PLX chip type (%04X), skipping tests\n",
                ChipTypeSelected
                );
            return;
    }


    printf("  Reading PLX-specific reg....... ");
    RegSave =
        PlxPci_PlxRegisterRead(
            pDevice,
            offset,
            &rc
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }
    printf("Ok (Reg %02X = %08X)\n", offset, RegSave);


    printf("  Write to PLX reg............... ");
    rc =
        PlxPci_PlxRegisterWrite(
            pDevice,
            offset,
            ValueToWrite
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }
    printf("Ok (Wrote %08X)\n", ValueToWrite);


    printf("  Verifying register write....... ");
    RegValue =
        PlxPci_PlxRegisterRead(
            pDevice,
            offset,
            &rc
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }

    if (RegValue != ValueToWrite)
    {
        printf("*ERROR* - Wrote %08X  Read %08X\n", ValueToWrite, RegValue);
    }
    else
    {
        printf("Ok (Reg %02X = %08X)\n", offset, RegValue);
    }


    printf("  Restore original value......... ");
    rc =
        PlxPci_PlxRegisterWrite(
            pDevice,
            offset,
            RegSave
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }
    printf("Ok (Wrote %08X)\n", RegSave);


    /***********************************
     * Memory-mapped register accesses
     **********************************/
    printf("  Read mem-mapped PLX reg........ ");
    RegSave =
        PlxPci_PlxMappedRegisterRead(
            pDevice,
            offset,
            &rc
            );

    if (rc != ApiSuccess)
    {
        if ((rc == ApiUnsupportedFunction) &&
            ((ChipTypeSelected == 0x8111) ||
             (ChipTypeSelected == 0x8112)))
        {
            printf("Ok (Expected rc=ApiUnsupportedFunction)\n");
        }
        else
        {
            printf("*ERROR* - API call failed\n");
            PlxSdkErrorDisplay(rc);
        }

        // No need to go further
        return;
    }
    else
    {
        printf("Ok (Reg %02X = %08X)\n", offset, RegSave);
    }


    printf("  Write to mem-mapped PLX reg.... ");
    rc =
        PlxPci_PlxMappedRegisterWrite(
            pDevice,
            offset,
            ValueToWrite
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }
    printf("Ok (Wrote %08X)\n", ValueToWrite);


    printf("  Verifying mapped reg write..... ");
    RegValue =
        PlxPci_PlxMappedRegisterRead(
            pDevice,
            offset,
            &rc
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }

    if (RegValue != ValueToWrite)
    {
        printf("*ERROR* - Wrote %08X  Read %08X\n", ValueToWrite, RegValue);
    }
    else
    {
        printf("Ok (Reg %02X = %08X)\n", offset, RegValue);
    }


    printf("  Restore original mapped value.. ");
    rc =
        PlxPci_PlxMappedRegisterWrite(
            pDevice,
            offset,
            RegSave
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }
    printf("Ok (Wrote %08X)\n", RegSave);
}




/********************************************************
 *
 *******************************************************/
void
TestPciBarMap(
    PLX_DEVICE_OBJECT *pDevice
    )
{
    U8               i;
    U32              Size;
    VOID            *Va[PCI_NUM_BARS_TYPE_00];
    RETURN_CODE      rc;
    PLX_PCI_BAR_PROP BarProp;


    printf("\nPlxPci_PciBarMap()...\n");

    for (i=0; i<PCI_NUM_BARS_TYPE_00; i++)
    {
        printf("  Mapping PCI BAR %d........ ", i);

        // Get BAR size
        PlxPci_PciBarProperties(
            pDevice,
            i,
            &BarProp
            );

        Size = (U32)BarProp.Size;

        rc =
            PlxPci_PciBarMap(
                pDevice,
                i,
                &(Va[i])
                );

        printf(
            "%s (VA=%p  %d %s)\n",
            PlxSdkErrorText(rc),
            Va[i],
            (Size > (10 << 10)) ? (Size >> 10) : Size,
            (Size > (10 << 10)) ? "KB" : "bytes"
            );
    }

    printf("\n");

    for (i=0; i<PCI_NUM_BARS_TYPE_00; i++)
    {
        printf(
            "  Unmapping PCI BAR %d...... ",
            i
            );

        rc =
            PlxPci_PciBarUnmap(
                pDevice,
                &(Va[i])
                );

        printf(
            "Ok (rc = %s)\n",
            PlxSdkErrorText(rc)
            );
    }
}




/********************************************************
 *
 *******************************************************/
U8
TestPhysicalMemAllocate(
    PLX_DEVICE_OBJECT *pDevice
    )
{
    U32              RequestSize;
    RETURN_CODE      rc;
    PLX_PHYSICAL_MEM PhysBuffer;
	U8 bPass = TRUE;

    printf("\nPlxPci_PhysicalMemoryXxx():\n");

    // Set buffer size to request
    RequestSize = 0x10000;


    printf("  Allocate buffer...... ");
    PhysBuffer.Size = RequestSize;
    rc =
        PlxPci_PhysicalMemoryAllocate(
            pDevice,
            &PhysBuffer,
            TRUE             // Smaller buffer ok
            );

    if (rc != ApiSuccess)
    {
        if (rc == ApiUnsupportedFunction)
        {
            printf("*ERROR* - ApiUnsupportedFunction returned\n");
            printf("     -- PLX Service driver used, Physical Mem API not supported --\n");
        }
        else
        {
            printf("*ERROR* - Unable to allocate physical buffer\n");
            PlxSdkErrorDisplay(rc);
        }
        return(FALSE);
    }
    printf("Ok\n");

    printf("  Map buffer........... ");
    rc =
        PlxPci_PhysicalMemoryMap(
            pDevice,
            &PhysBuffer
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - (rc=%s)\n", PlxSdkErrorText(rc));
		bPass = FALSE;
    }
    else
    {
        printf("Ok\n");
    }

    printf(
        "      Bus Physical Addr: 0x%08lx\n"
        "      CPU Physical Addr: 0x%08lx\n"
        "      Virtual Address  : 0x%08lx\n"
        "      Buffer Size      : %d Kb",
        (PLX_UINT_PTR)PhysBuffer.PhysicalAddr,
        (PLX_UINT_PTR)PhysBuffer.CpuPhysical,
        (PLX_UINT_PTR)PhysBuffer.UserAddr,
        (PhysBuffer.Size >> 10)
        );

    if (RequestSize != PhysBuffer.Size)
    {
        printf(
            " (req=%d Kb)\n",
            (RequestSize >> 10)
            );

		bPass = FALSE;
    }
    else
    {
        printf("\n");
    }


    printf("\n");
    printf("  Unmap buffer......... ");
    rc =
        PlxPci_PhysicalMemoryUnmap(
            pDevice,
            &PhysBuffer
            );

    printf("Ok (rc=%s)\n", PlxSdkErrorText(rc));

    printf("  Free buffer.......... ");
    rc =
        PlxPci_PhysicalMemoryFree(
            pDevice,
            &PhysBuffer
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - Unable to free physical buffer\n");
        PlxSdkErrorDisplay(rc);
		bPass = FALSE;
    }
    else
    {
        printf("Ok\n");
    }

	return(bPass);
}




/********************************************************
 *
 *******************************************************/
U8 
TestEeprom(
    PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected
    )
{
//    U8                CrcStatus;
    U16               offset;
    U16               ReadSave_16;
    U16               ReadValue_16;
//    U32               Crc;
    U32               ReadSave;
    U32               ReadValue;
    U32               WriteValue;
//    BOOLEAN           bCrc;
    BOOLEAN           bEepromPresent;
    RETURN_CODE       rc;
    PLX_EEPROM_STATUS EepromStatus;


    printf("\nEEPROM Test\n");

    // Setup test parameters
    switch (ChipTypeSelected)
    {
        case 0x8111:
        case 0x8112:
        case 0x8509:
        case 0x8505:
        case 0x8533:
        case 0x8547:
        case 0x8548:
            offset = 0x0;
//            bCrc   = FALSE;
            break;

        case 0x8114:
        case 0x8508:
        case 0x8516:
        case 0x8517:
        case 0x8518:
        case 0x8512:
        case 0x8524:
        case 0x8525:
        case 0x8532:
            offset = 0x1000;
//            bCrc   = TRUE;
            break;

        case 0x9050:
        case 0x9030:
        case 0x9080:
        case 0x9054:
        case 0x9056:
        case 0x9656:
            offset = 0x0;
//            bCrc   = FALSE;
            break;

        case 0x0:
        default:
            printf(
                "  - Unsupported PLX chip type (%04X), skipping tests\n",
                ChipTypeSelected
                );
            return(FALSE);
    }

    // Set value to write
    WriteValue = 0x12AB06A5;

    printf("  Checking if EEPROM present..... ");
    EepromStatus =
        PlxPci_EepromPresent(
            pDevice,
            &rc
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf("Ok (");

        if (EepromStatus == PLX_EEPROM_STATUS_NONE)
		{    printf("No EEPROM Present)\n"); return(FALSE); }
        else if (EepromStatus == PLX_EEPROM_STATUS_VALID)
            printf("EEPROM present with valid data)\n");
        else if (EepromStatus == PLX_EEPROM_STATUS_INVALID_DATA)
            printf("Present but invalid data/CRC error/blank)\n");
        else
		{ printf("?Unknown? (%d))\n", EepromStatus); return(FALSE);}
    }


    printf("  Probing for EEPROM............. ");
    bEepromPresent =
        PlxPci_EepromProbe(
            pDevice,
            &rc
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        if (bEepromPresent)
            printf("Ok (EEPROM presence detected)\n");
        else
		{
            printf("Ok (EEPROM not detected)\n");
			return(FALSE);
		}
    }

    // Read 16-bit from EEPROM
    printf("  Read EEPROM (16-bit)........... ");

    rc =
        PlxPci_EepromReadByOffset_16(
            pDevice,
            offset,
            &ReadSave_16
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf(
            "Ok  - (val[%02X] = 0x%04x)\n",
            offset, ReadSave_16
            );
    }


    // Write 16-bit to EEPROM
    printf("  Write EEPROM (16-bit).......... ");

    rc =
        PlxPci_EepromWriteByOffset_16(
            pDevice,
            offset,
            (U16)WriteValue
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf(
            "Ok  - (value = 0x%04x)\n",
            (U16)WriteValue
            );
    }


    // Verify Write
    printf("  Verify write................... ");

    rc =
        PlxPci_EepromReadByOffset_16(
            pDevice,
            offset,
            &ReadValue_16
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        if (ReadValue_16 == (U16)WriteValue)
        {
            printf(
                "Ok  - (value = 0x%04x)\n",
                ReadValue_16
                );
        }
        else
        {
            printf(
                "*ERROR* - Rd (0x%04x) != Wr (0x%04x)\n",
                ReadValue_16, (U16)WriteValue
                );
			return(FALSE);
        }
    }


    // Restore Original Value
    printf("  Restore EEPROM................. ");

    rc =
        PlxPci_EepromWriteByOffset_16(
            pDevice,
            offset,
            ReadSave_16
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
        printf("Ok\n");


    // Read from EEPROM by offset
    printf("  Read EEPROM (32-bit)........... ");

    rc =
        PlxPci_EepromReadByOffset(
            pDevice,
            offset,
            &ReadSave
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf(
            "Ok  - (val[%02X] = 0x%08x)\n",
            offset, ReadSave
            );
    }


    // Write to EEPROM by offset
    printf("  Write EEPROM (32-bit).......... ");

    rc =
        PlxPci_EepromWriteByOffset(
            pDevice,
            offset,
            WriteValue
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
    }
    else
    {
        printf(
            "Ok  - (value = 0x%08x)\n",
            WriteValue
            );
    }


    // Verify Write
    printf("  Verify write................... ");

    rc =
        PlxPci_EepromReadByOffset(
            pDevice,
            offset,
            &ReadValue
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
    }
    else
    {
        if (ReadValue == WriteValue)
        {
            printf(
                "Ok  - (value = 0x%04x)\n",
                ReadValue
                );
        }
        else
        {
            printf(
                "*ERROR* - Rd (0x%04x) != Wr (0x%04x)\n",
                ReadValue, WriteValue
                );
			return(FALSE);
        }
    }


    // Restore Original Value
    printf("  Restore EEPROM................. ");

    rc =
        PlxPci_EepromWriteByOffset(
            pDevice,
            offset,
            ReadSave
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API call failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
        printf("Ok\n");
/*

    // Get EEPROM CRC
    printf("  Getting current EEPROM CRC..... ");
    rc =
        PlxPci_EepromCrcGet(
            pDevice,
            &Crc,
            &CrcStatus
            );

    if (rc != ApiSuccess)
    {
        if ((rc == ApiUnsupportedFunction) && (bCrc == FALSE))
        {
            printf("Ok (Expected rc=ApiUnsupportedFunction)\n");
			return(FALSE);
        }
        else
        {
            printf("*ERROR* - API call failed\n");
            PlxSdkErrorDisplay(rc);
			return(FALSE);
        }
    }
    else
    {
        printf(
            "Ok (CRC=%08x  Status=%s)\n",
            Crc,
            (CrcStatus == PLX_CRC_VALID) ? "Valid" : "Invalid"
            );
    }


    // Update EEPROM CRC
    printf("  Update EEPROM CRC.............. ");
    rc =
        PlxPci_EepromCrcUpdate(
            pDevice,
            &Crc,
            FALSE       // Don't update EEPROM
            );

    if (rc != ApiSuccess)
    {
        if ((rc == ApiUnsupportedFunction) && (bCrc == FALSE))
        {
            printf("Ok (Expected rc=ApiUnsupportedFunction)\n");
			return(FALSE);
        }
        else
        {
            printf("*ERROR* - API call failed\n");
            PlxSdkErrorDisplay(rc);
			return(FALSE);
        }
    }
    else
    {
        printf(
            "Ok (New CRC=%08x)\n",
            Crc
            );
    }
*/
	return(TRUE);
}




/********************************************************
 *
 *******************************************************/
U8 TestInterruptNotification( PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected )
{
    U16               DB_Value;
    U16               Offset_IrqSet;
    U16               Offset_IrqMaskSet;
    U16               Offset_IrqMaskClear;
    U32               RegValue;
    U32               RegSave;
    PLX_INTERRUPT     PlxInterrupt;
    RETURN_CODE       rc;
    PLX_NOTIFY_OBJECT NotifyObject;


    printf("\nInterrupt Test\n");

    switch (ChipTypeSelected)
    {
        case 0x8114:
        case 0x8505:
        case 0x8508:
        case 0x8509:
        case 0x8516:
        case 0x8517:
        case 0x8518:
        case 0x8512:
        case 0x8524:
        case 0x8525:
        case 0x8532:
        case 0x8533:
        case 0x8547:
        case 0x8548:
            // Verify device is in NT mode (PCI header type must be 0)
            RegValue =
                PlxPci_PciRegisterReadFast(
                    pDevice,
                    0x0c,       // PCI Header type / Cache line
                    NULL
                    );

            if (((RegValue >> 16) & 0x7F) != 0)
            {
                printf("  ERROR: Device is not in NT mode, interrupts not supported\n");
                return(FALSE);
            }
            break;

        case 0x0:
        default:
            printf(
                "  - Unsupported PLX chip type (%04X), skipping tests\n",
                ChipTypeSelected
                );
            return(FALSE);
    }

    // Check whether link or virtual side (BAR 0 is 0 for virtual side)
    RegValue =
        PlxPci_PciRegisterReadFast(
            pDevice,
            0x10,
            NULL
            );

    if (RegValue == 0)
    {
        Offset_IrqSet       = 0x90;
        Offset_IrqMaskSet   = 0x98;
        Offset_IrqMaskClear = 0x9C;
    }
    else
    {
        Offset_IrqSet       = 0xA0;
        Offset_IrqMaskSet   = 0xA8;
        Offset_IrqMaskClear = 0xAC;
    }


    // Register for interrupt notification
    printf("  Register for Int. notification..... ");

    // Clear interrupt fields
    memset(&PlxInterrupt, 0, sizeof(PLX_INTERRUPT));

    // Seed the random-number generator
    srand( (unsigned)time( NULL ) );

    // Select a random 16-bit number for doorbells
    DB_Value              = rand();
    PlxInterrupt.Doorbell = DB_Value;

    // Register for interrupt notification
    rc =
        PlxPci_NotificationRegisterFor(
            pDevice,
            &PlxInterrupt,
            &NotifyObject
            );

    if (rc != ApiSuccess)
    {
        if (rc == ApiUnsupportedFunction)
        {
            printf("*ERROR* - ApiUnsupportedFunction returned\n");
            printf("     -- PLX Service driver used, Notification API not supported --\n");
            return(FALSE);
        }

        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf(
            "Ok (DB val=%04X)\n",
            PlxInterrupt.Doorbell
            );
    }


    // Save current IRQ mask
    printf("  Save current IRQ mask.............. ");
    RegSave =
        PlxPci_PlxRegisterRead(
            pDevice,
            Offset_IrqMaskSet,
            NULL
            );
    printf("Ok (mask=%04X)\n", RegSave);


    // Enable all doorbell interrupts
    printf("  Enable all doorbell interrupts..... ");
    PlxPci_PlxRegisterWrite(
        pDevice,
        Offset_IrqMaskClear,
        0xFFFF
        );
    printf("Ok\n");


    // Wait for interrupt event
    printf("  Generate and wait for interrupt.... ");

    // Trigger a doorbell interrupt
    PlxPci_PlxRegisterWrite(
        pDevice,
        Offset_IrqSet,
        PlxInterrupt.Doorbell
        );

    rc =
        PlxPci_NotificationWait(
            pDevice,
            &NotifyObject,
            5 * 1000
            );

    switch (rc)
    {
        case ApiSuccess:
            printf("Ok (Int received)\n");
            break;

        case ApiWaitTimeout:
            printf("*ERROR* - Timeout waiting for Int Event\n");
            break;

        case ApiWaitCanceled:
            printf("*ERROR* - Interrupt event cancelled\n");
            break;

        default:
            printf("*ERROR* - API failed\n");
            PlxSdkErrorDisplay(rc);
            break;
    }

    // Get the interrupt status
    printf("  Get Interrupt Status............... ");

    rc =
        PlxPci_NotificationStatus(
            pDevice,
            &NotifyObject,
            &PlxInterrupt
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf(
            "Ok (DB val=%04X)\n",
            PlxInterrupt.Doorbell
            );
    }

    // Release the interrupt wait object
    printf("  Cancelling Int Notification........ ");
    rc =
        PlxPci_NotificationCancel(
            pDevice,
            &NotifyObject
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
		return(FALSE);
    }
    else
    {
        printf("Ok\n");
    }


    // Restore interrupt mask
    printf("  Restore interrupt mask............. ");
    PlxPci_PlxRegisterWrite(
        pDevice,
        Offset_IrqMaskSet,
        RegSave
        );
    printf("Ok\n");

	return(TRUE);
}




/********************************************************
 *
 *******************************************************/
#if 0
void
TestPortInfo(
    PLX_DEVICE_OBJECT *pDevice
    )
{
    RETURN_CODE   rc;
    PLX_PORT_PROP PortProp;


    printf("\nPlxPci_GetPortInfo()...\n");

    printf("  Get Port properties................ ");
    rc =
        PlxPci_GetPortProperties(
            pDevice,
            &PortProp
            );

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        return;
    }

    printf("Ok\n");

    printf(
        "      Port Type  : %02d ",
        PortProp.PortType
        );

    switch (PortProp.PortType)
    {
        case PLX_PORT_UNKNOWN:
            printf("(Unknown?)\n");
            break;

        case PLX_PORT_ENDPOINT:  // PLX_PORT_NON_TRANS
            printf("(Endpoint or NT port)\n");
            break;

        case PLX_PORT_UPSTREAM:
            printf("(Upstream)\n");
            break;

        case PLX_PORT_DOWNSTREAM:
            printf("(Downstream)\n");
            break;

        case PLX_PORT_LEGACY_ENDPOINT:
            printf("(Endpoint)\n");
            break;

        case PLX_PORT_ROOT_PORT:
            printf("(Root Port)\n");
            break;

        case PLX_PORT_PCIE_TO_PCI_BRIDGE:
            printf("(PCIe-to-PCI Bridge)\n");
            break;

        case PLX_PORT_PCI_TO_PCIE_BRIDGE:
            printf("(PCI-to-PCIe Bridge)\n");
            break;

        case PLX_PORT_ROOT_ENDPOINT:
            printf("(Root Complex Endpoint)\n");
            break;

        case PLX_PORT_ROOT_EVENT_COLL:
            printf("(Root Complex Event Collector)\n");
            break;

        default:
            printf("(N/A)\n");
            break;
    }

    printf(
        "      Port Number: %02d\n",
        PortProp.PortNumber
        );

    printf(
        "      Max Payload: %02d\n",
        PortProp.MaxPayloadSize
        );

    printf(
        "      Link Width : %d\n",
        PortProp.LinkWidth
        );
}
#endif
