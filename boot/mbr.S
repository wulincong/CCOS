;主引导程序MBR
%include "boot.inc"
SECTION MBR vstart=0x7c00   ;把编译地址改到0x7c00处，这里是BIOS移交控制权的地方
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov fs,ax
	mov sp,0x7c00

	;gs寄存器用于存储显存的地址段从0x8000开始
    mov ax,0xb800
    mov gs,ax  
    
    ;清屏
	mov ax,0x600   ;BIOS的打印显示过程从这里读取参数  功能0x6是清屏操作
	mov bx,0x700   
	mov cx,0
	mov dx,0x184f
	int 0x10

    ;操作显卡显示
    mov byte [gs:0x00],'1'
    mov byte [gs:0x01],0xA4
    
    mov byte [gs:0x02],' '
    mov byte [gs:0x03],0xA4
    
    mov byte [gs:0x04],'M'
    mov byte [gs:0x05],0xA4
    
    mov byte [gs:0x06],'B'
    mov byte [gs:0x07],0xA4
    
    mov byte [gs:0x08],'R'
    mov byte [gs:0x09],0xA4
    
    mov eax,LOADER_START_SECTOR  ; 起始扇区lba地址
    mov bx,LOADER_BASE_ADDR      ; 写入的地址
    mov cx,4                     ; 待读入的扇区数
    call rd_disk_m_16
    mov byte [gs:0x0A],'L'
    jmp LOADER_BASE_ADDR + 0x300
rd_disk_m_16:
    mov esi,eax ; 备份eax
    mov di,cx   ; 备份cx

    ; step1:设置要读取的扇区数
    mov dx,0x1f2
    mov al,cl       ;al = cl = 1
    out dx,al       ;读取的扇区数  out 第一个参数是端口地址，第二个参数是带读取的扇区数
    
    mov eax,esi     ;恢复ax
    
    ;step2:将LBA地址存入0x1f3~0x1f6
    mov dx,0x1f3
    out dx,al       ;此时eax已经恢复存储LBA地址了所以低位直接进0x1f3
    
    mov cl,8
    shr eax,cl      ;eax右移8位
    mov dx,0x1f4
    out dx,al
    
    shr eax,cl      ;eax右移8位
    mov dx,0x1f5
    out dx,al
    
    shr eax,cl
    and al,0x0f     ;保留了LBA的最后四位信息
    or al,0xe0      ;设置device信息，0xe = 0b1110 表示LBA模式
    mov dx,0x1f6
    out dx,al
    
    ;step3 向0x1f7端口写读命令0x20
    mov dx,0x1f7
    mov al,0x20
    out dx,al
    
    ;step4:检测硬盘状态
  .not_ready:
    nop
    in al,dx        ;dx = 0x1f7 status信息--> al
    and al,0x88 
    cmp al,0x08   ;比较信息，如果第四位上status为1（硬盘控制器就绪为1）并且第八位为0（硬盘忙为1）即准备就绪
    jnz .not_ready

    ;stpe5 从0x1f0端口读数据
    mov ax,di
    mov dx,256
    mul dx
    mov cx,ax
    mov dx,0x1f0
    
  .go_on_read:
    in ax,dx
    mov [bx],ax
    add bx,2
    loop .go_on_read
    ret

	times 510-($-$$) db 0
	db 0x55,0xaa
    
