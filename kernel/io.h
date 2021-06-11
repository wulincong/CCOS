#ifndef __LIB_IO_H
#define __LIB_IO_H
#include "stdint.h"
static inline void outb(uint16_t port, uint8_t data){
    asm volatile("outb %b0, %w1"::"a"(data),"Nd"(port));
}
static inline void outw(uint16_t port, const void* addr, uint32_t word_cnt){
    asm volatile("cld; rep outw":"+S"(addr),"+c"(word_cnt):"d"(port));
}
static inline void insw(uint16_t port, void* addr, uint32_t word_cnt){
    asm volatile("cld; rep insw":"+D"(addr),"+c"(word_cnt):"d"(port):"memory");
}

#endif