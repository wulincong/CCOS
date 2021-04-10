section MBR vstart=0x7c00

    mov ax,cs  ;cs = code segment register
    mov ds,ax  ;ds = data segment register
    mov es,ax  ;es = extra segment register
    mov ss,ax  ;ss = stack segment register
    mov fs,ax  ;fs = flag segment resigter 

    mov sp,0x7c00
    call scream_clear

scream_clear:
    mov ax,0x600
    mov bx,0x700
    mov cx,0
    mov dx,0x184f
    int 0x10

