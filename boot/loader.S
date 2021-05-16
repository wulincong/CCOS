[bits 16]
%include "./include/boot.inc"

section loader vstart=LOADER_BASE_ADDR
    ;LOADER_STACK_TOP equ LOADER_BASE_ADDR
    jmp l_start
    db 0x00 
;构建gdt及其内部的描述符,这里是从LOADER_BASE_ADDR开始构建我们的GDT
    GDT_BASE:   dd    0x00000000
	            dd    0x00000000

    CODE_DESC:  dd    0x0000FFFF 
	            dd    DESC_CODE_HIGH4

    DATA_STACK_DESC:  dd    0x0000FFFF
		              dd    DESC_DATA_HIGH4

    VIDEO_DESC: dd    0x80000007	       ; limit=(0xbffff-0xb8000)/4k=0x7
	            dd    DESC_VIDEO_HIGH4  ; 此时dpl为0

    GDT_SIZE   equ   $ - GDT_BASE
    GDT_LIMIT   equ   GDT_SIZE - 1
    times 60 dq 0  ;预留的位置
;选择子
    SELECTOR_CODE equ (0x01<<3) + TI_GDT + RPL0
    SELECTOR_DATA equ (0x02<<3) + TI_GDT + RPL0
    SELECTOR_VIDEO equ (0x3<<3) + TI_GDT + RPL0
    total_mem_bytes dd 0
    gdt_ptr dw GDT_LIMIT
            dd GDT_BASE
    ards_buf times 244 db 0
    ards_nr dw 0

l_start:
;    mov ax,0600h
;    mov bx,0700h
;    mov cx,0
;    mov dx,184fh
;    int 10h
    
    call cls

    mov byte [gs:0x02],'R'
    mov byte [gs:0x03],0x07
    

    call SHOW_CURSOR
    call show_CCOS
    call show_loader

    mov si,message_a
    mov cx,12
    call GPU_print_string

    ;获取内存地址
;-----------------  int 15h ah = 0x88 获取内存大小,只能获取64M之内  ----------
    ;int 15后，ax存入的是以kb为单位的内存容量
    mov  ah, 0x88
    int  0x15
    and eax,0x0000FFFF
    ;16位乘法，被乘数是ax,积为32位.积的高16位在dx中，积的低16位在ax中
    mov cx, 0x400     ;0x400等于1024,将ax中的内存容量换为以byte为单位
    mul cx
    shl edx, 16	     ;把dx移到高16位
    or edx, eax	     ;把积的低16位组合到edx,为32位的积
    add edx,0x100000  ;0x88子功能只会返回1MB以上的内存,故实际内存大小要加上1MB
  .mem_get_ok:
    mov [total_mem_bytes], edx	 ;将内存换为byte单位后存入total_mem_bytes处。


    ;进入保护模式
    call enter_protect_mod

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
    lgdt [gdt_ptr]

    mov eax,cr0
    or eax,0x0000_0001
    mov cr0,eax
    jmp dword SELECTOR_CODE:p_mode_start   ;刷新流水线


;%include "Getting_E820_Memory_Map.S"
%include "util16.S"

message db "Welcome to CCOS!"
b_loader db "2 loader"
message_a db "Hello World!"


[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp,LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax
        ; 设置分页
    call setup_page
    sgdt [gdt_ptr]

    mov ebx, [gdt_ptr + 2]
    or dword [ebx + 0x18 + 4], 0xc0000000
    add dword [gdt_ptr + 2],0xc0000000
    add esp, 0xc0000000 
    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax 

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [gdt_ptr]
    mov byte [gs:160], 'V'
; -------------------------   加载kernel  ----------------------
    mov eax, KERNEL_START_SECTOR
    mov ebx, KERNEL_BIN_BASE_ADDR
    mov ecx, 200
    call rd_disk_m_32
    jmp SELECTOR_CODE:enter_kernel

enter_kernel:
    call kernel_init
    mov esp, 0xc009f000
    jmp KERNEL_ENTRY_POINT
    jmp $

kernel_init:
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    mov dx, [KERNEL_BIN_BASE_ADDR + 42]  ;the size of program header
    mov ebx, [KERNEL_BIN_BASE_ADDR + 28] ;the first program header offset
    add ebx, KERNEL_BIN_BASE_ADDR
    mov cx, [KERNEL_BIN_BASE_ADDR + 44] ;the number of program header 
  .each_segment:
    cmp byte [ebx+0], PT_NULL ;if p_type == PT_NULL, 说明这个program header 未使用
    je .PTNULL
    push dword [ebx + 16]
    mov eax, [ebx + 4]
    add eax, KERNEL_BIN_BASE_ADDR
    push eax 
    push dword [ebx + 8]
    call mem_cpy
    add esp, 12
  .PTNULL:
    add ebx, edx 
    loop .each_segment
    ret



%include "util32.S"
protect_mod db "Enter protected mode!"