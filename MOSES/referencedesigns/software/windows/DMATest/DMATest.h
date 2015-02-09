#ifndef DMATEST_H
#define DMATEST_H

#include "PlxApi.h"
#include "Reg9056.h"
#include "PlxInit.h"
#include "FPGAReg.h"


/**********************************************
*               Definitions
**********************************************/
#define SIZE_DS_BUFFER         256           // Number of bytes to transfer

/**********************************************
*               Functions
**********************************************/
U8 DMATest(PLX_DEVICE_OBJECT *pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif
