#include "PlxApi.h"
#include <Windows.h>
#include <WinBase.h>
    #include <stdio.h>
    #include <conio.h>

#if defined(PLX_MSWINDOWS)
    #include "..\\Shared\\ConsFunc.h"
    #include "..\\Shared\\PlxInit.h"
#endif

#if defined(PLX_LINUX)
    #include "ConsFunc.h"
    #include "PlxInit.h"
#endif

U32		atoh( char *string );
char 	get_digit( char c ) ;

int main( int argc, char* argv[] )
{
    //S8					DeviceSelected;
    RETURN_CODE			rc;
    //PLX_DEVICE_KEY		DevKey;
    PLX_DEVICE_OBJECT	Device;
	U8					BarIndex;
    int					i; //j;
    //U32					DevVenId;
    //U32					LocalAddress;
    U32					*pBufferDest;
	U32					offset;
	U32					szBuffer;
	U32					numDwords;
	PLX_PCI_BAR_PROP	BarProperties;
//	U32					pciAddr;
	U32					lastAddr;
	U32					retVal;
//	U32					offsetAddr;
	U32					gpionHex;
	U32					gpiopHex;
	U8					gpion[32];
	U8					gpiop[32];

	// Get the device....
	rc = GetAndOpenDevice(&Device, 0x9056);

	if (rc != ApiSuccess)
    {
        Cons_printf("*ERROR* - API failed, unable to open PLX Device\n");
        PlxSdkErrorDisplay(rc);
        exit(-1);
    }

	offset = 0x10;
	numDwords = 6;
    BarIndex = 2;
	szBuffer = numDwords * 4;

	rc = PlxPci_PciBarProperties(&Device,BarIndex,&BarProperties);

    if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed\n");
        PlxSdkErrorDisplay(rc);
        //ConsoleEnd();
        exit(-1);
    }

	//printf("\nBar %i: Reading %i DWORDS from offset %x\n", BarIndex, numDwords,offset);

	lastAddr = offset + (szBuffer-4);

	retVal = -1;

	if (lastAddr > BarProperties.Size-4)
	{
        printf("Reading beyond Bar address space.");
    }
	else
	{
		// allocate buffer
		pBufferDest = malloc(szBuffer);

		if (pBufferDest == NULL)
		{
			printf("*ERROR* - Destination buffer allocation failed\n");
			//ConsoleEnd();
			//exit(-1);
		}
		else
		{
			retVal = 0;
			

					
					
			//ungetc('0',stdin);

			while ((retVal == 0) && (kbhit() == 0))
			{
				Cons_clear();

				printf("\n                ");
					// print out the read buffer
					for (i = 31; i >= 0; i--)
					{
						if (i==15) printf("\n                ");
						printf("|%2i",i);
					}
				
				printf("\n----------------------------------------------------------------");

				// Clear destination buffer
				memset(pBufferDest, 0, szBuffer);

				// read from memory space
				rc = PlxPci_PciBarSpaceRead(&Device, BarIndex, offset, pBufferDest, szBuffer, BitSize32, FALSE);

				if (rc != ApiSuccess)
				{
					printf("*ERROR* - API failed\n");
					PlxSdkErrorDisplay(rc);
					//ConsoleEnd();
					retVal = -1;
				}
				else
				{
					retVal = 0;

					gpiopHex = pBufferDest[2];
					printf("\nGPIOp = %08x", gpiopHex);

					for (i = 31; i >= 0; i--)
					{
						gpiop[i] = (U8)((gpiopHex >> i) & 0x1);
						if (i==15) printf("\n                ");
						printf("| %i",gpiop[i]);
					}

					printf("\n----------------------------------------------------------------");;

					gpionHex = pBufferDest[5];
					printf("\nGPIOn = %08x", gpionHex);

					for (i = 31; i >= 0; i--)
					{
						gpion[i] = (U8)((gpionHex >> i) & 0x1);
						if (i==15) printf("\n                ");
						printf("| %i",gpion[i]);
					}
				}

				Sleep(250);
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
