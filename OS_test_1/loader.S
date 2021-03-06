%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR

;构建gdt及其内部的描述符
   GDT_BASE:   dd    0x00000000 
	       dd    0x00000000

   CODE_DESC:  dd    0x0000FFFF 
	       dd    DESC_CODE_HIGH4

   DATA_STACK_DESC:  dd    0x0000FFFF
		     dd    DESC_DATA_HIGH4

   VIDEO_DESC: dd    0x80000007	       ; limit=(0xbffff-0xb8000)/4k=0x7
	       dd    DESC_VIDEO_HIGH4  ; 此时dpl为0

   GDT_SIZE   equ   $ - GDT_BASE
   GDT_LIMIT   equ   GDT_SIZE -	1 
gdt_ptr dw 





    call cls
    call show_CCOS
    call show_loader

    mov si,message_a
    mov cx,12
    call GPU_print_string

    call enter_protect_mod

    mov si,protect_mod
    mov cx,21
    call GPU_print_string


jmp $

show_CCOS:
    mov si,message
    mov cx,16
    call GPU_print_string
    ret

show_loader:

    mov si,b_loader
    mov cx,8
    call GPU_print_string
    ret

enter_protect_mod:
    ;准备进入保护模式
    ;打开A20
    in al,0x92
    or al,0000_0010B
    out 0x92,al
    ;加载GDT
    ;lgdt [gdt_ptr]

    ret 


%include "util.S"
message db "Welcome to CCOS!"
b_loader db "2 loader"
message_a db "Hello World!"
protect_mod db "Enter protected mode!"