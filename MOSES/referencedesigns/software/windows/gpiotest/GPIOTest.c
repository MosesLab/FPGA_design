/*******************************************************************************
Copyright (c) 2012 CTI, Connect Tech Inc. All Rights Reserved.

THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
The copyright notice above does not evidence any actual or intended
publication of such source code.

This module contains Proprietary Information of Connect Tech, Inc
and should be treated as Confidential.
********************************************************************************
Project:		FreeForm/PCI-104
Module:			gpiotest.c
Description:	Program to test gpio
********************************************************************************
Date		Author	Modifications
--------------------------------------------------------------------------------
2008-05-23	MF		Add option to test LVDS I/O - register setting are diff.
2008-06-04	MF		Separate test() from main(), for use in one large test app
2008-08-25	MF		Removed references to LVDS
2009-03-19	MF		Cleanup include file ordering
2012-02-13	MF	REmoved unused variable
*******************************************************************************/

/*====================
  HEADERS
====================*/
#include "GPIOTest.h"

#define GPIO_WRAP

/*******************************************************************************
Function:		GPIOTest
Description:	GPIO loopback test
*******************************************************************************/
U8 GPIOTest(PLX_DEVICE_OBJECT* pDevice, U8 BarIndex, U8 bVerbose, boardInfo* bi)
{
    RETURN_CODE			rc;
    U32					i,j;
	U32					rVal;
	U32					wVal;
//	U8					cLVDS;
//	U8					bPass = TRUE;

	U32					aMask;
	U32					bMask;
#ifdef GPIO_WRAP
	printf("\nUsing GPIO Wrapboard");

	printf("\nP: A >> B\n");
		
	aMask = 0x33333333;
	bMask = 0xCCCCCCCC;

	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_TRI,  aMask);
	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, 0x0 );

	for(i=0; i<=7;i++)
	{
		for(j=0;j<=1;j++)
		{
			printf("%d ",(i*4 + j));

			wVal = 1 << (i*4 + j);
			//printf("\nwVal=%x",wVal);

			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_P_IN, &rVal );

			//printf("\nrVal = %x",rVal);
			rVal = rVal & bMask;
			//printf("\nrVal = %x",rVal);

			wVal = 1 << (i*4 + j+2);
			wVal = wVal & bMask;
			//printf("\nexVal = %x",wVal);

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}
		}
	}

	printf("\nN: A >> B\n");

	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_TRI,  aMask);
	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, 0x0 );

	for(i=0; i<=7;i++)
	{
		for(j=0;j<=1;j++)
		{
			printf("%d ",(i*4 + j));

			wVal = 1 << (i*4 + j);
			//printf("\nwVal=%x",wVal);

			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_N_IN, &rVal );

			//printf("\nrVal = %x",rVal);
			rVal = rVal & bMask;
			//printf("\nrVal = %x",rVal);

			wVal = 1 << (i*4 + j+2);
			wVal = wVal & bMask;
			//printf("\nexVal = %x",wVal);

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}
		}
	}


	printf("\nP: B >> A\n");
		


	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_TRI,  bMask);
	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, 0x0 );

	for(i=0; i<=7;i++)
	{
		for(j=2;j<=3;j++)
		{
			printf("%d ",(i*4 + j));

			wVal = 1 << (i*4 + j);
			//printf("\nwVal=%x",wVal);

			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_P_IN, &rVal );

			//printf("\nrVal = %x",rVal);
			rVal = rVal & aMask;
			//printf("\nrVal = %x",rVal);

			wVal = 1 << (i*4 + j-2);
			wVal = wVal & aMask;
			//printf("\nexVal = %x",wVal);

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}
		}
	}

	printf("\nN: B >> A\n");

	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_TRI,  bMask);
	rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, 0x0 );

	for(i=0; i<=7;i++)
	{
		for(j=2;j<=3;j++)
		{
			printf("%d ",(i*4 + j));

			wVal = 1 << (i*4 + j);
			//printf("\nwVal=%x",wVal);

			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_N_IN, &rVal );

			//printf("\nrVal = %x",rVal);
			rVal = rVal & aMask;
			//printf("\nrVal = %x",rVal);

			wVal = 1 << (i*4 + j-2);
			wVal = wVal & aMask;
			//printf("\nexVal = %x",wVal);

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}
		}
	}
#else
		// Setup gpio p

		// 1010 = A odd bit mask
		// 0101 = 5 even bit mask

		printf("\nP: Write Odd bits, read even bits\n");
		
		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_TRI, ODD_MASK );
		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, 0x0 );

		for (i=1;i<32;i=i+2)
		{
			printf("%d ",i);

			wVal = 1 << i;
			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_P_IN, &rVal );

			rVal = rVal & EVEN_MASK;
			wVal = wVal >> 1;
			wVal = wVal & EVEN_MASK;

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}

			//CTISleep(500);
		}

		printf("\nP: Write even bits, read odd bits\n");

		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_TRI, EVEN_MASK );
		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, 0x0 );

		for (i=0;i<32;i=i+2)
		{
			printf("%d ",i);

			wVal = 1 << i;
			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_P_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_P_IN, &rVal );

			rVal = rVal & ODD_MASK;
			wVal = wVal << 1;
			wVal = wVal & ODD_MASK;

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}

			//CTISleep(500);
		}

		printf("\nN: Write Odd bits, read even bits\n");
		
		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_TRI, ODD_MASK );
		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, 0x0 );

		for (i=1;i<32;i=i+2)
		{
			printf("%d ",i);

			wVal = 1 << i;
			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_N_IN, &rVal );

			rVal = rVal & EVEN_MASK;
			wVal = wVal >> 1;
			wVal = wVal & EVEN_MASK;

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}

			//CTISleep(500);
		}

		printf("\nN: Write even bits, read odd bits\n");

		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_TRI, EVEN_MASK );
		rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, 0x0 );

		for (i=0;i<32;i=i+2)
		{
			printf("%d ",i);

			wVal = 1 << i;
			rc = WriteDword(pDevice, BarIndex, FPGA_GPIO_N_OUT, wVal );
			rc = ReadDword(pDevice, BarIndex, FPGA_GPIO_N_IN, &rVal );

			rVal = rVal & ODD_MASK;
			wVal = wVal << 1;
			wVal = wVal & ODD_MASK;

			if (rVal != wVal)
			{
				printf("\nError");
				return(FALSE);
			}

			//CTISleep(500);
		}
#endif

	return(TRUE);
}
