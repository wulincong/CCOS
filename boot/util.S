cls:
    mov ax,0x600  ;BIOS的打印显示过程从这里读取参数  功能0x6是清屏操作
    mov bx,0x700
    mov cx,0
    mov dx,0x184f
    int 0x10
    ret

put_int:
    ret

GPU_print_char:

    ret

GPU_print_string:
    ret


;al是字符ascii码
BIOS_print_char:
    mov ah,0x0A
    mov bx,0x0007
    mov cx,0x01
    int 0x10
    ret

BIOS_print_string:
    ret

delay:
    ret
