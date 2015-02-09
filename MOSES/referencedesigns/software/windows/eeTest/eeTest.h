#ifndef EETEST_H
#define EETEST_H

#include "PlxInit.h"
#include "FPGAReg.h"

/*===============
  CONSTANTS
===============*/
#define c_mwAddrEwds 0x00	//: std_logic_vector(1 downto 0) := "00"; & "000000"
#define c_mwAddrWral 0x40	//: std_logic_vector(1 downto 0) := "01"; & "000000"
#define c_mwAddrEral 0x80	//: std_logic_vector(1 downto 0) := "10"; & "000000"
#define c_mwAddrEwen 0xC0	//: std_logic_vector(1 downto 0) := "11"; & "000000"
	
#define c_mwOp		0x0		//: std_logic_vector(1 downto 0) := "00"; 
#define c_mwOpWrite	0x1		//: std_logic_vector(1 downto 0) := "01";
#define c_mwOpRead	0x2		//: std_logic_vector(1 downto 0) := "10";
#define c_mwOpErase	0x3		//: std_logic_vector(1 downto 0) := "11";


/*===============
  FUNCTIONS
===============*/
U8  eeTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);
RETURN_CODE  eepromTest ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex);
RETURN_CODE  mwOperation ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 op, U8 addr, U16 datao, U8 cnt, U16* datai);
U8  cibEELoader ( 	PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi);

#endif