#include "init.h"

void init_all(void){
    put_str("init_all\n");
    idt_init();
}