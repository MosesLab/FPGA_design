
/************************************************************
** File: poke6.c
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
#define DEVICE_ID 0x9056
#define CTI_SUB_VENDOR_ID 0x12c4 // CTI's Sub Vendor ID

unsigned char verbose = 0; // turn on verbose mode if 1
char *TaskName; // our task name

/*
 * FUNCTION: FindBoard
 *
 *  PARAMETERS:
 *
 * DESCRIPTION:
 * Routine to find a FreeForm board and obtain it's setup info
 *
 * RETURNS:
 * Number of boards found
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
		printf("%s: pci_attached failed with error code %d\n", TaskName, handle);
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
		return(0);
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
			printf("%s: reading BAR[%d] failed\n", TaskName, i );
			return(-1);
		}
	}
	return(1);
}


void print_usage()
{
	printf("poke6 [-0 | -1 | -2 | -3] [-n count] [address] [data]\n");
	printf("defaults: -0 -n 1 0 0 \n");
	printf("options:\n");
	printf("-0 .. -3     Base Address Register Select\n" );
	printf("-n count     Number of values to write\n");
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
	int i, j, c;
	int writecount = 1;
	unsigned long writeaddress = 0;
	unsigned char writedata[16];
	char *p;
	unsigned short device_seg;
	int BAR_Index = 0;
	volatile unsigned char *BoardPtr;

	TaskName=argv[0];

    while(( c = getopt( argc, argv, "n:v0123h" )) != -1 ) {
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
		writecount = atoi(optarg);
		if ((writecount < 1) || (writecount > 16)) {
			printf("%s: Bad write count (%d). Must be between 1 & 16\n", TaskName, writecount );
			exit(-1);
		}
		if (verbose) printf("%s: Display count %d\n", TaskName, writecount );
		break;
	case 'v':
		verbose = 1;
		break;
	default:
		break;
      }//switch
    }//while

	if (optind >= argc) {
		printf("%s: Insufficient parameters\n", TaskName);
		print_usage();
		exit(-1);
	}
	writeaddress = atoh(argv[optind]);
	for(i = optind+1, j = 0; i < argc; ++i, ++j) {
		writedata[j] = atoh(argv[i]);
	}
	if (j < writecount) {
		printf("%s: Missing data. Write count is %d but only found %d values\n",
				TaskName, writecount, j );
		exit(-1);
	}
	
	if (verbose) {
		printf("%s: Address %lx Count %d BAR %d Data ",
			TaskName, writeaddress, writecount, BAR_Index);
		for(i=0; i < writecount; ++i ) printf("%02X ", writedata[i] );
		printf("\n" );
	}

	FindBoard( &BAR[0], &Sizes[0] );
	if (verbose) {
		printf("%s: BAR ", TaskName );
		for(i=0; i < 4; ++i) printf("%lX ", BAR[i]);
		printf(" Mapping BAR %lX\n", BAR[BAR_Index]);
	}
	
	BoardPtr = mmap_device_memory( 0, 128,
			PROT_READ|PROT_WRITE|PROT_NOCACHE, 0, BAR[BAR_Index] );
	if ( BoardPtr == MAP_FAILED ) {
		printf("%s: mmap_device_memory failed\n", TaskName );
		return(-1);
	}
	if (verbose) printf("%s: BoardPtr %lx\n", TaskName, BoardPtr );
	for(i = 0; i < writecount; ++i )
		*(BoardPtr+writeaddress+i) = writedata[i];
	for(i = 0; i < writecount; ++i )
		if (*(BoardPtr+writeaddress+i) != writedata[i])
			printf("%s: Verify error at %lX wrote %02X read %02X\n",
				TaskName, BoardPtr+writeaddress+i, writedata[i], *(BoardPtr+i));
	return(0);
}


