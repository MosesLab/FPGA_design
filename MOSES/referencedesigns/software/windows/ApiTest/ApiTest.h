#ifndef APITEST_H
#define APITEST_H

#include "PlxInit.h"
#include "FPGAReg.h"

/**********************************************
 *               Functions
 *********************************************/
U8 TestChipTypeGet( PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected );
void TestPlxRegister( PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected );
void TestPciBarMap( PLX_DEVICE_OBJECT *pDevice );
U8 TestPhysicalMemAllocate( PLX_DEVICE_OBJECT *pDevice );
U8 TestEeprom( PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected );
U8 TestInterruptNotification( PLX_DEVICE_OBJECT *pDevice, U32 ChipTypeSelected );
void TestPortInfo( PLX_DEVICE_OBJECT *pDevice );
U8 APITest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif