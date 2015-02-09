#include "mcs.h"


/*******************************************************************************
Function:		calcBufCrc
Description:	Calculates CRC on a buffer of data

Use CRC-7 = x7 + x3 + 1, where divisor is 0x09 in hex (the upper bit is always ignored)
Could be any 8 bit polynomial
*******************************************************************************/
/*
U8 calcBufCrc (U8 crc, U8* buffer, U16 bufSize )
{
	U8 poly = 0x09;
	U8 rem = crc;
	U8 j;
	U16 i;
	
	for ( i = 0; i < bufSize; i++)
	{
		rem = rem ^ buffer[i];
		
		for(j = 0; j < 8; j++)
		{		
			// if upper most bit is 1
			if(rem & 0x80)
				rem = (rem << 1)^ poly;
			else
				rem = (rem << 1);
		}
	}
	
	return (rem);
}
*/
/*******************************************************************************
Function:		parseMcsFile
Description:	Parses the hexfile, to determine if it is valid & calculates the CRC
*******************************************************************************/
RETURN_CODE parseMcsFile(char* fileName, U8 secOffset, U8* crc )
{
	U32 numRecords = 0;
	char strBuf[REC_SIZE*2+2];  // 2 extra characters for colon and CR
	//U8 pageBuf[256];
	U8 addrSector;
	U8 addrPage;
	U8 addrByte;
	
	U16 i;
	
	HEX_RECORD rec;
	FLASH_DATA* pfd = new_flash_data(); 
	FLASH_SEC* pfsec = NULL;
	FLASH_PAGE* pfpage = NULL;
	
	
	U32 lines;
	double percentage;
	FILE *fp;
	U8 pageWritePending;
	RETURN_CODE rc = ApiFailed;
	*crc = 0;

	fp = fopen(fileName, "r");

	if (fp == NULL)
	{
		printf("\nFailed to open %s", fileName);
		return(rc);
	}

	lines = 0;

	while ( fscanf(fp,"%s",&strBuf[0]) != EOF )
	{
		lines++;
	}

	rewind(fp);

	addrSector = secOffset;
	addrPage = 0;
	addrByte = 0;
	pageWritePending = FALSE;

	while ( fscanf(fp,"%s",&strBuf[0]) != EOF )
	{
		processRecord(&strBuf[0], &rec);

		switch (rec.type)
		{
			//--------------
			case 0x04:
				
				if (addrSector != rec.data[1] || pageWritePending == TRUE)
				{	
					printf("Sector out of sequence (line %d)\n", numRecords+1);
					printf("Expected %x, read %x\n",addrSector, rec.data[1]);
					return(rc);
				}
				else
				{
					addrPage = 0;
					addrByte = 0;

					// <TODO> store sector
					pfsec = new_flash_sec(pfd, addrSector);
					
					if (pfsec==NULL || ((addrSector > secOffset) && (pfsec == pfd->sec[0]) ))
					{
						printf("*ERROR* Sector %d, not allocated properly mem = %8x\n",addrSector, (unsigned int)pfsec);						
						return(0);
					}					
				}	
				break;

			//--------------
			case 0x00:

				if (addrPage != rec.addrPage || addrByte != rec.addrByte)
				{
					printf("Record address out of sequence (line %d)\n", numRecords+1);
					printf("Expected %x %x, read %x %x\n",
							addrPage, addrByte, rec.addrPage, rec.addrByte);
					return(rc);
				}
				
				if (addrByte == 0x00)
					{			
						pfpage = new_flash_page(pfsec, addrPage);	
						
						if (pfpage==NULL)
						{
							printf("*ERROR* Sector %d, Page%d, not allocated\r\n",addrSector,addrPage);	
							return(FALSE);
						}											
					}				

				pageWritePending = TRUE;

				for(i=0; i < rec.size; i++)
				{
					//pageBuf[addrByte+i] = rec.data[i];
					pfpage->data[addrByte+i] = rec.data[i];
					pfpage->numByte++;					
				}

				addrByte += rec.size; // should be 0x10
			
				if (addrByte == 0x00) // 256 bytes have been collected, time to write page
				{
		
					// <TODO> store page
					//printf("Calculating crc for sec %x, page %x", addrSector, addrPage);
					*crc = calcBufCrc(*crc, pfpage->data, 256);
					pageWritePending = FALSE;
					addrPage++;

					if (addrPage == 0x00) // 256 pages have been written, rollover
					{
						addrSector++;				
					}
				}						
				break;

			//--------------
			case 0x01:
				if (pageWritePending)
				{
					//printf("Unfinished page (%d)\n", numRecords+1);
					// <TODO> store page
					for(i=addrByte; i<256;i++)
						pfpage->data[i] = 0xFF;
						
					//printf("Calculating crc for sec %x, page %x", addrSector, addrPage);
					*crc = calcBufCrc(*crc, pfpage->data, 256);
					pageWritePending = FALSE;
				}
				break;
			default :
				printf("\nInvalid Record processed (%d)\n", numRecords);
				return(rc);
				break;
		}
			

		numRecords=numRecords+1;				

		percentage = ( (double)numRecords / (double)lines ) * 100;
		printf("%f | 100 %%\r",percentage);
	}


	printf("...Complete\n");

	fclose(fp);
	
	free_flash_data(pfd);

	return(ApiSuccess);
}
