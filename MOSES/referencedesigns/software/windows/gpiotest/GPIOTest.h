#ifndef GPIOTEST_H
#define GPIOTEST_H

#include "PlxInit.h"
#include "FPGAReg.h"


/*===============
  CONSTANTS
===============*/
#define ODD_MASK 0xAAAAAAAA
#define EVEN_MASK 0x55555555

#define FPGA_LVDS_OUT			0x010
#define FPGA_LVDS_IN			0x018

/*===============
  FUNCTIONS
===============*/
U32		atoh( char *string );
char 	get_digit( char c );
U8 GPIOTest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif