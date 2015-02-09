#ifndef DSTEST_H
#define DSTEST_H

#include "PlxInit.h"
#include "FPGAReg.h"

/**********************************************
*               Definitions
**********************************************/
#define SIZE_DS_BUFFER         64           // Number of bytes to transfer

/**********************************************
*               Functions
**********************************************/
U8 DSTest(PLX_DEVICE_OBJECT *pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);
U8 LedTest(PLX_DEVICE_OBJECT *pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif