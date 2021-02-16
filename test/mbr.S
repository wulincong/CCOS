section MBR vstart=0x7c00

    mov ax,cs  ;cs = code segment register
    mov ds,ax  ;ds = data segment register
    mov es,ax  ;es = extra segment register
    mov ss,ax  ;ss = stack segment register
    mov fs,ax  ;fs = flag segment resigter 

    mov sp,0x7c00


