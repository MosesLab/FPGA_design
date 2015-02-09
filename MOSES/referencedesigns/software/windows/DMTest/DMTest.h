#ifndef DMTEST_H
#define DMTEST_H

#include "PlxInit.h"
#include "FPGAReg.h"
#include "fpgaDmInt.h"


#define DM_USE_INTR
U8 DMTest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif