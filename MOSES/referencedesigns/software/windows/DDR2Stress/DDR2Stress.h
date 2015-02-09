#ifndef DDR2TEST_H
#define DDR2TEST_H

#include "math.h"
#include "PlxInit.h"
#include "FPGAReg.h"

// CONSTANTS
#define SIZE_DDR2_BUFFER         64*4           // Number of bytes to transfer

#define  BANK_WIDTH		2     //-- # of memory bank addr bits
#define  NUM_BANK	       4     //-- # of memory bank addr bits
#define  COL_WIDTH        10     //-- # of memory column bits
#define	NUM_COL			1024
#define  ROW_WIDTH        13     //-- # of memory row & # of addr bits
#define NUM_ROW			8192

// FUNCTIONS
U8 DDR2Stress(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);
U32 makeDDR2Addr( U16 bank, U16 row, U16 col );
RETURN_CODE performDDR2Wr(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U32* pBufferWr, U32 ddr2Addr, U8 bVerbose);
RETURN_CODE performDDR2Rd(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U32* pBufferRd, U32 ddr2Addr, U8 bVerbose);

#endif