MAX_CURSOR equ 1999
[bits 16]
cls:
    mov ax,0x600  ;BIOS的打印显示过程从这里读取参数  功能0x6是清屏操作
    mov bx,0x700
    mov cx,0
    mov dx,0x184f
    int 0x10
    mov bx,0
    call SET_CURSOR
    ret

;put_int:
;    ret

GPU_print_char:

    ret

GPU_print_string:
    ;si放置字符串内存地址
    ;cx保存字符串数量
        call GET_CURSOR
        mov bx,ax
        shr ax,4
        add ax,0x0B800
        mov gs,ax 
        add bx,0xA0
        call SET_CURSOR
        mov di,0    ;di放置显示缓冲区索引
    @g:
        mov al,[si] 
        mov [gs:di],al
        inc di
        mov byte [gs:di],0x07
        inc di
        inc si
        loop @g 

    ret

SET_CURSOR:
    ;bx 存储重置的cursor位置
    mov dx,0x3d4
    mov al,0x0e
    out dx,al 
    mov dx,0x3d5
    mov al,bh 
    out dx,al

    mov dx,0x3d4
    mov al,0x0f
    out dx,al 
    mov dx,0x3d5
    mov al,bl
    out dx,al 

    ret


GET_CURSOR:  ;将光标地址存储在ax内
    mov dx,0x3d4
    mov al,0x0e
    out dx,al ;索引寄存器
    
    mov dx,0x3d5
    in  al,dx ;读取高位
    mov bh,al ;挪到bh高位

    mov dx,0x3d4
    mov al,0x0f
    out dx,al ;索引寄存器

    mov dx,0x3d5
    in  al,dx ;读取低位
    mov bl,al
    mov al,4
    out dx,al

    mov ax,bx 
    ret

SHOW_CURSOR:
;显卡光标在两个8位的光标寄存器中，可以通过索引寄存器的方式访问
;索引寄存器的端口号是 0x3d4 通过写入值来指定需要映射的寄存器，
;映射的数据放在端口 0x3d5 可以通过读写0x3d5改变实际寄存器的值
    mov ax,0x0B800
    mov gs,ax 

    call GET_CURSOR

    mov bx,10 

    mov dx,0
    div bx 
    mov [number+0x00],dl ;保存各位上的数字

    xor dx,dx 
    div bx 
    mov [number+0x01],dl ;保存十位上的数字

    xor dx,dx 
    div bx 
    mov [number+0x02],dl ;保存百位上的数字

    xor dx,dx 
    div bx 
    mov [number+0x03],dl ;保存千位上的数字

    mov bx,0

    mov al,[number+0x03]
    or al,0x30    ;0x30 = 0b00110000  相当于 + 0x30
    mov [gs:bx],al 

    mov al,[number+0x02]
    or al,0x30
    add bx,2
    mov [gs:bx],al 
    

    mov al,[number+0x01]
    or al,0x30
    add bx,2
    mov [gs:bx],al 
    
    mov al,[number+0x00]
    or al,0x30
    add bx,2
    mov [gs:bx],al 

    ret
;al是字符ascii码
BIOS_print_char:
    mov ah,0x0E
    mov bx,0x0007
    ;mov cx,0x00A0
    int 0x10
    ret


BIOS_print_string:
    ps:
    mov al,[si]
    inc si
    or al,al
    jz pend
    call BIOS_print_char
    jmp ps 
    pend:
    ret

;delay:
;    ret

number db 0,0,0,0   ;用于储存四位光标数据