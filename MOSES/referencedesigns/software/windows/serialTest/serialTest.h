#ifndef SERIALTEST_H
#define SERIALTEST_H

#include "PlxInit.h"
#include "FPGAReg.h"


/*===============
  CONSTANTS
===============*/
#define	REG_TXDATA 0x0
#define REG_CTRL 0x2
#define REG_RATE 0x3
#define REG_RXDATA 0x0
#define REG_STATUS 0x2

#define WAIT_MS 3

/*===============
  FUNCTIONS
===============*/
U8  serialTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, U8 dir);U8  serialTestBothDir ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif