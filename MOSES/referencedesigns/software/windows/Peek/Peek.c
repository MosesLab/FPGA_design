#include "PlxApi.h"
//#include <Windows.h>
//#include <WinBase.h>
//#include <stdio.h>
//#include <conio.h>

#if defined(PLX_MSWINDOWS)
    //#include "..\\Shared\\ConsFunc.h"
    #include "..\\Shared\\PlxInit.h"
#endif

#if defined(PLX_LINUX)
    //#include "ConsFunc.h"
    #include "PlxInit.h"
#endif


int main( int argc, char* argv[] )
{
    //S8					DeviceSelected;
    RETURN_CODE			rc;
    //PLX_DEVICE_KEY		DevKey;
    PLX_DEVICE_OBJECT	Device;
	U8					BarIndex;
    U32					i; //j;
    //U32					DevVenId;
    //U32					LocalAddress;
    U32					*pBufferDest;
	U32					offset;
	U32					szBuffer;
	PLX_PCI_BAR_PROP	BarProperties;
	U32					pciAddr;
	U32					lastAddr;
	U32					lastBarAddr;
	U32					retVal;
	U32					offsetAddr;
	S8					typeChar;
	S8*					typeString;
	S8					strArray[6];
	PLX_ACCESS_TYPE		typeBit;
	U32					numType;
	U32					typeBytes;
	
	U16*				pwordBuf;
	U8*					pbyteBuf;

    //ConsoleInitialize();
    //Cons_clear();

	if (argc < 5)
	{
		printf("use: <bar> <offset in hex> <type> <dwords in integer>");
		return;
	}


	typeString = &strArray[0];

	BarIndex = atoi(argv[1]);
	offset = atoh(argv[2]);
	typeChar = argv[3][0];
	numType = atoi(argv[4]);

	switch( typeChar	)
	{
		case 'b':
		case 'B':
			typeBit = BitSize8;
			typeBytes = 1;
			typeString = "BYTE";
			break;
		case 'w':
		case 'W':
			typeBit = BitSize16;
			typeBytes = 2;
			typeString = "WORD";
			break;
		case 'd':
		case 'D':
			typeBit = BitSize32;
			typeBytes = 4;
			typeString = "DWORD";
			break;
		default:
			printf("\nInvalid type");
			exit(-1);

	}
	
	szBuffer = numType * typeBytes;

	// Get the device....
	rc = GetAndOpenDevice(&Device, 0x9056);

	if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed, unable to open PLX Device\n");
        PlxSdkErrorDisplay(rc);
        exit(-1);
    }

	rc = PlxPci_PciBarProperties(&Device,BarIndex,&BarProperties);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        //ConsoleEnd();
        exit(-1);
    }

	printf("\nBar %i: Reading %i %s(s) from offset %x\n", BarIndex, numType, typeString, offset);

	lastAddr = offset + (szBuffer-typeBytes);
	lastBarAddr = (U32)BarProperties.Size-typeBytes;

	retVal = -1;

	if (lastAddr > lastBarAddr)
	{
        printf("Reading beyond Bar address space.");
    }
	else
	{
		// allocate buffer
		pBufferDest = malloc(szBuffer);

		pwordBuf = (U16*)pBufferDest;
		pbyteBuf = (U8*)pBufferDest;

		if (pBufferDest == NULL)
		{
			printf("*ERROR* - Destination buffer allocation failed\n");
			//ConsoleEnd();
			//exit(-1);
		}
		else
		{
			// Clear destination buffer
			memset(pBufferDest, 0, szBuffer);

			// read from memory space
			rc = PlxPci_PciBarSpaceRead(&Device, BarIndex, offset, pBufferDest, szBuffer, typeBit, FALSE);

			if (rc != ApiSuccess)
			{
				printf("*ERROR* - API failed\n");
				PlxSdkErrorDisplay(rc);
				//ConsoleEnd();
				//exit(-1);
			}
			else
			{
				retVal = 0;

				// print out the read buffer
				for (i = 0; i < numType; i++)
				{
					offsetAddr = offset + i * typeBytes;
					pciAddr = (U32)BarProperties.Physical + offsetAddr;

					switch(typeBit)
					{
						case BitSize32:
								printf("\t(%04x) %08x %08x\n", offsetAddr, pciAddr, pBufferDest[i]);
								break;
						case BitSize16:
								printf("\t(%04x) %08x %04x\n", offsetAddr, pciAddr, pwordBuf[i]);
								break;
						case BitSize8:
						default:
								printf("\t(%04x) %08x %02x\n", offsetAddr, pciAddr, pbyteBuf[i]);
								break;
					}
				}
			}
		 
			// free buffer
			if (pBufferDest != NULL)
				free(pBufferDest);
		}
	}

    // Close the Device
    PlxPci_DeviceClose( &Device );

    //_Pause;
    printf("\n\n");
    //ConsoleEnd();

    exit(retVal);
}