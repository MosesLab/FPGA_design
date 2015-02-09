#ifndef GTPTEST_H
#define GTPTEST_H

#include "PlxInit.h"
#include "FPGAReg.h"

/*===============
  CONSTANTS
===============*/
#define GTP_CTRL_RX_RST		0x40000000 // bit 
#define GTP_CTRL_TX_RST		0x80000000 // bit 

#define	GTP_CTRL_RX_START	0x10 // bit 4
#define GTP_CTRL_TX_START	0x08 // bit 3
#define GTP_CTRL_LB			0x07 // bit 2 to 0

#define GTP_STA_SZ			0xF8 // bit 7 to 3
#define GTP_STA_RX_DONE		0x04 // bit 2
#define GTP_STA_TX_DONE		0x02 // bit 1
#define GTP_STA_PLLOK		0x01 // bit 0

#define GTP_STA_SZ_sr			0x03


/*===============
  FUNCTIONS
===============*/
U8  gtpTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif