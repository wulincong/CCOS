#ifndef __LIB_KERNEL_PRINT_H
#define __LIB_KERNEL_PRINT_H
#include "stdint.h"

extern void put_char(uint8_t char_asci);
extern void put_str(char* message);
extern void put_int(uint32_t num);
#endif
