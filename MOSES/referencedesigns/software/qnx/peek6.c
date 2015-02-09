
/************************************************************
** File: peek6.c
** Author: DJW (from bhw.c & fcg001.c)
**
** Description:
**
** Revision history:
** Original: Jan 26/2008
**
** Revisions:
**
**
**
**
** Copyright (c) 2008 CTI, Connect Tech Inc. All Rights Reserved.
**
** THIS IS THE UNPUBLISHED PROPRIETARY SOURCE CODE OF CONNECT TECH INC.
** The copyright notice above does not evidence any actual or intended
** publication of such source code.
**
** This module contains Proprietary Information of Connect Tech, Inc
** and should be treated as Confidential.
************************************************************/

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <process.h>
#include <hw/pci.h>
#include <sys/mman.h>


#define PLX_VENDOR_ID 0x10b5 // PLX Vendor ID
#define DEVICE_ID 0x9056	// PLX device id for 9056 bridge
#define CTI_SUB_VENDOR_ID 0x12c4 // CTI's Sub Vendor ID

unsigned char verbose = 0; // turn on verbose mode if 1
char *TaskName;

/*
 * FUNCTION: FindBoard
 *
 *  PARAMETERS:
 *
 * DESCRIPTION:
 * Routine to find a FreeForm board and obtain it's setup info
 *
 * RETURNS:
 * Number of boards found (1). Vector _bar[] is populated with the values of the BAR.
 */

int FindBoard( unsigned long _bar[], int _sizes[] )
{
	int i;
	unsigned lastbus, version, hardware, flags;
	int status, handle;
	unsigned busnum, devfuncnum;
	unsigned short SubSystemVendorID, SubSystemID;

	handle = pci_attach(0);
	if (handle < 0) {
		printf("%s: pci_attach failed with error code %d\n", TaskName, handle);
		return(-1);
	}

	status = pci_present( &lastbus, &version, &hardware );
	if (status != PCI_SUCCESS) {
		if (verbose) printf( "%s: pci_present() failed with error code %d\n", TaskName, status );
		return(-1);
	}
	if (verbose) printf( "%s: lastbus %d version %d hardware %d\n", TaskName, lastbus, version, hardware );

	status = pci_find_device( DEVICE_ID, PLX_VENDOR_ID, 0, &busnum, &devfuncnum );
	if (status != PCI_SUCCESS) {
		printf("%s: pci_find_device failed with error code %d\n", TaskName, status );
		return(-1);
	}
	if (verbose) printf("%s: FreeForm found (bus %x dev %x)\n", TaskName, busnum, devfuncnum );

	if((status=pci_read_config16( busnum, devfuncnum,
			offsetof(struct _pci_config_regs, Sub_Vendor_ID),
			1, (char *)&SubSystemVendorID)) != PCI_SUCCESS ) {
		printf("%s: pci_read_config16 (for SubSystemVendorID) failed with error code %d\n", TaskName, status );
		return(-1);
	}

	if((status=pci_read_config16( busnum, devfuncnum,
			offsetof(struct _pci_config_regs, Sub_System_ID),
			1, (char *)&SubSystemID)) != PCI_SUCCESS ) {
		printf("%s: pci_read_config16 (for SubSystemID) failed with error code %d\n", TaskName, status );
		return(-1);
	}
	if (verbose) printf("%s: SubSystemVendorID %x SubSystemID %x\n",
			TaskName, SubSystemVendorID, SubSystemID);

// Everything looks good, read the BARs
	for(i = 0; i < 4; ++i ){
		if(pci_read_config32(busnum, devfuncnum,
			offsetof(struct _pci_config_regs, Base_Address_Regs[i]),
			1, &_bar[i]) != PCI_SUCCESS) {
			printf("%s: reading BAR[%d} failed\n", TaskName, i );
			return(-1);
		}
	}
	return(1);
}

void print_usage()
{
	printf("peek6 [-0 | -1 | -2 | -3] [-n count] [-A format] [-s size] [address]\n");
	printf("defaults: -n 1 -A x -s 4 0\n");
	printf("options:\n");
	printf("-0 .. -3   Base Address Register Select\n" );
	printf("-A format  Display data in following format:\n");
	printf("           x  hex\n");
	printf("           o octal \n");
	printf("           d decimal\n");
	printf("           a ascii\n");
	printf("-n count   Number of values to read\n");
	printf("-s size    Size of values (1, 2 or 4 bytes)\n");
}


display( int size,unsigned char *addr, int fmt, int cnt )
{
	char *fmtstr, prtstr[17];
	unsigned char val8;
	unsigned short val16;
	unsigned long val32;
	int i, j;

	if (verbose) printf("%s: display addr %p\n", TaskName, addr );
	for(i = 0; i < cnt; i += 16, addr += 16) {
		printf("%08lX: ", addr+i ); //Address (offset from beginning)
		prtstr[16] = 0;
		for(j = 0; j < 16; j += size) {
			if (size == 1) {
				val8 = *(addr+j);
				switch (fmt) {
				case 'a':
					if (isprint(val8)) fmtstr = "%c";
					else fmtstr = ".";
					break;
				case 'd':
					fmtstr = "%3d ";
					break;
				case 'o':
					fmtstr = "%03o ";
					break;
				case 'x':
					fmtstr = "%02X ";
					if (isprint(val8)) prtstr[j] = val8;
					else prtstr[j] = '.';
					break;
				} //switch
				printf( fmtstr, val8 );
			}
			if (size == 2) {
				val16 = *((unsigned short *)(addr+j));
				switch (fmt) {
				case 'a':
					if (isprint((val16&0xff))) fmtstr = "%c";
					else fmtstr = ".";
					break;
				case 'd':
					fmtstr = "%4d ";
					break;
				case 'o':
					fmtstr = "%06o ";
					break;
				case 'x':
					fmtstr = "%04X ";
					if (isprint((val16)&0xff)) prtstr[j] = val32;
					else prtstr[j] = '.';
					break;
				} //switch
				printf( fmtstr, val16 );
			}
			if (size == 4) {
				val32 = *((unsigned short *)(addr+j));
				switch (fmt) {
				case 'a':
					if (isprint((val32&0xff))) fmtstr = "%c";
					else fmtstr = ".";
					break;
				case 'd':
					fmtstr = "%12d ";
					break;
				case 'o':
					fmtstr = "%012o ";
					break;
				case 'x':
					fmtstr = "%08X ";
					if (isprint((val32)&0xff)) prtstr[j] = val32;
					else prtstr[j] = '.';
					break;
				} //switch
				printf( fmtstr, val32 );
			}
		} //for j
		if (fmt == 'x' && size == 1) printf("%s\n", prtstr); //print ascii version at right side
		else printf("\n");
	} //for i
	return(0);
}

/*
 *  FUNCTION: main
 *
 *  PARAMETERS:
 * command line arguments
 *
 *  DESCRIPTION:
 * Main line for program
 *
 *  RETURNS:
 * Nothing
 */
 main(int argc, char *argv[])
{
	unsigned long BAR[4];
	int Sizes[4];
	unsigned int NumberOfBoards = 0;
	int i, c;
	int displaycount = 1;
	int displayformat = 'x';
	int displaysize = 4;
	unsigned long displayaddress = 0;
	char *p;
	unsigned short device_seg;
	int BAR_Index = 0;
	unsigned char *BoardPtr;

	TaskName=argv[0];

    while(( c = getopt( argc, argv, "n:A:s:v0123h" )) != -1 ) {
	switch( c ) {
		case 'h':
			print_usage();
			exit(0);
		case '0':
			BAR_Index = 0;
			break;
		case '1':
			BAR_Index = 1;
			break;
		case '2':
			BAR_Index = 2;
			break;
		case '3':
			BAR_Index = 3;
			break;
		case 'n':
		p = optarg;
		if (!isdigit(*p)) {
			printf("%s: Bad count %s\n", TaskName, p );
			return(-1);
		}
		displaycount = atoi(optarg);
		if (verbose) printf("%s: Display count %d\n", TaskName, displaycount );
		break;
	case 'A':
		p = optarg;
		if (*p=='a' || *p=='d' || *p=='o' || *p=='x'){
			displayformat = *p;
			if (verbose) printf("%s: Display format %c\n", TaskName, *p );
		}
		else {
			printf("%s: Bad format %s\n", TaskName, p );
			return(-1);
		}
		break;
	case 's':
		p = optarg;
		if (!isdigit(*p)) {
			printf("%s: Bad size %s\n",TaskName, p );
			return(-1);
		}
		displaysize = atoi(p);
		if (displaysize != 1 && displaysize != 2 && displaysize != 4) {
			printf("%s: Bad display size, must be 1, 2 or 4\n", TaskName, displaysize );
			return(-1);
		}
		if (verbose) printf("%s: Display size %d\n", TaskName, displaysize);
		break;
	case 'v':
		verbose = 1;
		break;
	default:
		break;
      }//switch
    }//while

	if (optind < argc) {
// When the above loop terminates, optind wil point to the address
		displayaddress = atoh(argv[optind]);
	}
	else {
		displayaddress = 0;
	}

	if (verbose) printf("%s: Address %lx Count %d Size %d Fmt %c BAR %d\n",
		TaskName, displayaddress, displaycount,displaysize, displayformat, BAR_Index);

	FindBoard( &BAR[0], &Sizes[0] );
	if (verbose) {
		printf("%s: BAR ", TaskName );
		for(i=0; i < 4; ++i) printf("%lX ", BAR[i]);
		printf("\n");
	}
	
	BoardPtr = mmap_device_memory( 0, 128,
			PROT_READ|PROT_WRITE|PROT_NOCACHE, 0, BAR[BAR_Index] );
	if ( BoardPtr == MAP_FAILED ) {
		printf("%s: mmap_device_memory failed\n", TaskName );
		return(-1);
	}
	display( displaysize, BoardPtr+displayaddress, displayformat, displaycount );
	return(0);
}

//	if (verbose) printf("%s: Address %lx Count %d Size %d Fmt %c BAR %d\n",

#if NEVER
Pre-canned test patterns should they be required
printf("8 bit tests:\n");
	display( 1, "Now is the time \001\002for all good men to come to the aid of the party.", 'x', 20 );
	display( 1, "Now is the time for all good men to come to the aid of the party.", 'a', 20 );
	display( 1, "Now is the time for all good men to come to the aid of the party.", 'o', 20 );
	display( 1, "Now is the time for all good men to come to the aid of the party.", 'd', 20 );

printf("16 bit tests:\n");
	display( 2, "Now is the time \001\002for all good men to come to the aid of the party.", 'x', 20 );
	display( 2, "Now is the time for all good men to come to the aid of the party.", 'a', 20 );
	display( 2, "Now is the time for all good men to come to the aid of the party.", 'o', 20 );
	display( 2, "Now is the time for all good men to come to the aid of the party.", 'd', 20 );

printf("32 bit tests:\n");
	display( 4, "Now is the time \001\002for all good men to come to the aid of the party.", 'x', 20 );
	display( 4, "Now is the time for all good men to come to the aid of the party.", 'a', 20 );
	display( 4, "Now is the time for all good men to come to the aid of the party.", 'o', 20 );
	display( 4, "Now is the time for all good men to come to the aid of the party.", 'd', 20 );
#endif





