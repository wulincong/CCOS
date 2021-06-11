#ifndef __KERNEL_INTERRUPT_H
#define __KERNEL_INTERRUPT_H
#include "stdint.h"
#include "global.h"
#include "io.h"

#define IDT_SESC_CNT 0x21  //目前总共支持的中断数
#define PIC_M_CTRL 0x20     
#define PIC_M_DATA 0x21     
#define PIC_S_CTRL 0xa0     
#define PIC_S_DATA 0xa1     

//中断门描述符结构体
struct gate_desc
{
    uint16_t func_offset_low_word;
    uint16_t selector;
    uint8_t dcount;
    uint8_t attribute;
    uint16_t func_offset_high_word;
};

typedef void* intr_handler;

static void make_idt_desc(struct gate_desc* p_gdesc, uint8_t attr, intr_handler function);
static struct gate_desc idt[IDT_SESC_CNT];
extern intr_handler intr_entry_table[IDT_SESC_CNT];

void idt_init(void);
#endif
