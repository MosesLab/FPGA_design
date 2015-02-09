#include "PlxApi.h"

#if defined(PLX_MSWINDOWS)
    //#include "..\\Shared\\ConsFunc.h"
    #include "..\\Shared\\PlxInit.h"
#endif

#if defined(PLX_LINUX)
    //#include "ConsFunc.h"
    #include "PlxInit.h"
#endif

U32		atoh( char *string );
char 	get_digit( char c ) ;

int main( int argc, char* argv[] )
{
    RETURN_CODE			rc;
    //PLX_DEVICE_KEY		DevKey;
    PLX_DEVICE_OBJECT	Device;
	U8					BarIndex;
    //U32					*pBufferSrc;
	U32					offset;
	U32					szBuffer;
	PLX_PCI_BAR_PROP	BarProperties;
	U32					value;
	U32					retVal;

	S8					typeChar;
	char*					typeString;
	char					strArray[6];
	PLX_ACCESS_TYPE		typeBit;
	//U32					numType;
	U32					typeBytes;

    //ConsoleInitialize();
    //Cons_clear();

	retVal = -1;

	if (argc < 5)
	{
		printf("use: <bar in decimal> <offset in hex> <type b=byte,w=word,d=dword> <value in hex>\n");
		//_Pause;
        //ConsoleEnd();
        exit(-1);
	}

	typeString = &strArray[0];
	
	BarIndex = (U8)atoh(argv[1]);
	offset = atoh(argv[2]);
	typeChar = argv[3][0];
	value = atoh(argv[4]);

	switch( typeChar	)
	{
		case 'b':
		case 'B':
			typeBit = BitSize8;
			typeBytes = 1;
			typeString = "BYTE";

			if (value > 0xFF )
			{
				printf("\nValue > 0xFF, truncating\n");
				value = value & 0xFF;
			}

			break;
		case 'w':
		case 'W':
			typeBit = BitSize16;
			typeBytes = 2;
			typeString = "WORD";

			if (value > 0xFFFF )
			{
				printf("\nValue > 0xFFFF, truncating\n");
				value = value & 0xFFFF;
			}

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
	
	szBuffer = typeBytes;

  	// Get the device....
	rc = GetAndOpenDevice(&Device, 0x9056);

	if (rc != ApiSuccess)
    {
        printf("*ERROR* - API failed, unable to open PLX Device\n");
        PlxSdkErrorDisplay(rc);
        //goto _Exit_App;
    }
	else 
	{


		rc = PlxPci_PciBarProperties(&Device,BarIndex,&BarProperties);

		if (rc != ApiSuccess)
		{
			printf("*ERROR* - API failed\n");
			PlxSdkErrorDisplay(rc);
			//ConsoleEnd();
			//exit(-1);
		}
		else
		{
			if (offset >= BarProperties.Size)
			{
				printf("\nBar %i: offset outside of bar range\n",BarIndex);
			}
			else
			{
				printf("\nBar %i: Writing %x to offset %x\n", BarIndex, value, offset);

				//rc = WriteDword(&Device,BarIndex,offset,value);
				rc = PlxPci_PciBarSpaceWrite(&Device,BarIndex,offset,&value,szBuffer,typeBit,FALSE);

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
				}
			} // Check Address
		} // Bar Properties
		
		// Close the Device
		PlxPci_DeviceClose( &Device );
	} // Device Open
    
	//_Pause;
    printf("\n");
    //ConsoleEnd();

    exit(retVal);
}
