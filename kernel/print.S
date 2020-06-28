TI_GDT equ 0   ;选择子TI = 0表示GDT 
RPL0 equ 0      ;特权级0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0 
;第 0 个段描述符没用。 从第1个到第3个，分别是代码段描述符CODE_DESC、
;数据段和栈段描述符DATA_STACK_DESC、显存段描述符 VIDEO_DESC,所以这里选择3作为索引值

section .data
    put_int_buffer dq 0

[bits 32]  ;下面是在32位地址模式下的命令
section .text
;-------------------------------put_str-----------------------------------
;put_str: 输入字符串首地址，打印字符串
;-------------------------------------------------------------------------
global put_str
put_str:
    push ebx
    push ecx
    xor ecx,ecx
    mov ebx,[esp + 12]
   .goon:
    mov cl, [ebx]
    cmp cl, 0 ; 如果处理到了字符串尾，跳到结束处返回
    jz .str_over
    push ecx ; 为 put_char 函数传递参数
    call put_char
    add esp, 4 ; 回收参数所占的栈空间
    inc ebx ; 使 ebx 指向下一个字符
    jmp .goon
  .str_over:
    pop ecx
    pop ebx
    ret


;---------------------------   put_char  ---------------------------------
;功能：把栈中的一个字符写入光标所在的地方
;-------------------------------------------------------------------------
global put_char
put_char:
    pushad      ;备份32位寄存器环境 pushad = push all double 压入所有双字长的寄存器，这里是指8个EAX->ECX->EDX->EBX->ESP->EBP->ESI->EDI
    ;需要保存gs中正确的视频段选择子
    ;为保险起见，每次打印都为gs赋值
    mov ax,SELECTOR_VIDEO
    mov gs,ax ;为段寄存器gs赋值为SELECTOR_VIDEO
    mov byte [gs:0x00],'P'
;;;;;;;  获取当前光标位置  ;;;;;;;;;;;;
    ;high 8 bits
    mov dx,0x03d4   ;索引寄存器
    mov al,0x0e     ;高八位的显存寄存器地址
    out dx,al 
    mov dx,0x03d5   ;通过读写数据端口0x03d5来获取光标位置 dx<-0x03d5
    in al,dx        ;得到了光标位置的高八位 al<-dx
    mov ah,al       ;ah<-al 

    ;get low 8 bits
    mov dx,0x03d4   ;索引寄存器
    mov al,0x0f     ;高八位的显存寄存器地址
    out dx,al 
    mov dx,0x03d5   ;通过读写数据端口0x03d5来获取光标位置 dx<-0x03d5
    in al,dx        ;得到了光标位置的高八位 al<-dx
 
    ;我们习惯用寄存器bx做基址，所以将光标存入bx
    mov bx,ax   ;此时ax存的是光标位置
    mov ecx,[esp+36]    ;pushad 压入4x8=32字节，加上主调用函数4字节的返回地址，故esp+36是参数1的位置

    cmp cl,0xd          ;CR(carriage return)是回车0x0d，LF(line_feed)是退格0x0a
    jz .is_carriage_return 
    cmp cl,0xa
    jz .is_line_feed
    cmp cl,0x8          ;BS(backspace)的ASCII码是8 
    jz .is_backspace 
    jmp .put_other
    
.is_backspace:
    dec bx          ;bx-- 
    shl bx,1        ;bx*2

    mov byte [gs:bx],0x20   ;空格
    inc bx                  ;bx++属性位
    mov byte [gs:bx],0x07   ;属性黑底白字
    shr bx,1                ;bx/2 尾数舍去
    jmp .set_curcor         

.put_other:
    shl bx,1                ;bx<<2作为显存地址的偏移量
    mov [gs:bx],cl          ;把要打印的字符装进光标对应的内存位置
    inc bx
    mov byte [gs:bx],0x07 
    shr bx,1 
    inc bx                  ;光标移向下一位置
    cmp bx,2000
    jl .set_curcor

.is_line_feed:
.is_carriage_return:
    xor dx,dx
    mov ax,bx
    mov si,80

    div si 

    sub bx,dx 

.is_carriage_return_end:
    add bx,80
    cmp bx,2000
.is_line_feed_end:
    jl .set_curcor

.roll_screen:
    cld
    mov ecx,960
    mov esi,0xc00b80a0
    mov edi,0xc00b8000
    rep movsd

    mov ebx,3840
    mov ecx,80

.cls:
    mov word [gs:ebx], 0x0720
    add ebx,2 
    loop .cls
    mov bx,1920

.set_curcor:

    mov dx,0x03d4
    mov al,0x0e
    out dx,al 
    mov dx,0x03d5
    mov al,bh 
    out dx,al

    mov dx,0x03d4
    mov al,0x0f
    out dx,al
    mov dx,0x03d5
    mov al,bl 
    out dx,al
  .put_char_done:
    popad 
    ret  

;----------将小端字节序的数字变成对应的 ASCII 后，倒置----------
;输入:栈中参数为待打印的数字
;输出:在屏幕上打印十六进制数字，并不会打印前缀 0x
;如打印十进制 15 时，只会直接打印 f，不会是 0xf
;---------------------------------------------------------------------------------------

global put_int
put_int:
    pushad
    mov ebp, esp
    mov eax, [ebp+4*9]  
    mov edx, eax
    mov edi, 7 
    mov ecx, 8 
    mov ebx, put_int_buffer
  .16based_4bits:  
    and edx, 0x0000000F 
    cmp edx, 9 
    jg .is_A2F
    add edx, '0'  
    jmp .store
  .is_A2F:
    sub edx,10
    add edx,'A'

    .store:
    mov [ebx+edi], dl
    dec edi
    shr eax, 4
    mov edx, eax
    loop .16based_4bits

  .ready_to_print:
    inc edi ; 此时 edi 退减为-1(0xffffffff)，加 1 使其为 0
  .skip_prefix_0:
    cmp edi,8 ; 若已经比较第 9 个字符了
    je .full0
  .go_on_skip:
    mov cl, [put_int_buffer+edi]
    inc edi
    cmp cl, '0'
    je .skip_prefix_0 ; 继续判断下一位字符是否为字符 0（不是数字 0）
    dec edi ;edi 在上面的 inc 操作中指向了下一个字符
    jmp .put_each_num

  .full0:
    mov cl,'0' ; 输入的数字为全 0 时，则只打印 0
  .put_each_num:
    push ecx ; 此时 cl 中为可打印的字符
    call put_char
    add esp, 4
    inc edi ; 使 edi 指向下一个字符
    mov cl, [put_int_buffer+edi] ; 获取下一个字符到 cl 寄存器
    cmp edi,8
    jl .put_each_num
    popad
    ret






