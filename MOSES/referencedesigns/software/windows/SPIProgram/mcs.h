#ifndef MCS_H
#define MCS_H
#include "PlxApi.h"
#include "SPIInterface.h"
#include "flashData.h"



U8 calcBufCrc (U8 crc, U8* buffer, U16 bufsize );
RETURN_CODE parseMcsFile(char* fileName, U8 secOffset, U8* crc);
#endif //MCS_H