section .data
str_c_lib: db "c library says: hello world!", 0xa ;0xa 为LF ascii码
str_c_lib_len equ $-str_c_lib

str_syscall: db "syscall says: hello world!", 0xa
str_syscall_len equ $-str_syscall

section .text 
global _start
_start:
    ;1
    push str_c_lib_len
    push str_c_lib
    push 1

    call simu_write
    add esp,12 

    ;2
    mov eax,4 ;4号子功能是write系统调用
    mov ebx,1 
    mov ecx, str_syscall
    mov edx, str_syscall_len
    int 0x80

    mov eax,1 
    int 0x80

    simu_write: 
    push ebp ;备份 ebp
    mov ebp,esp
    mov eax,4 ;第 4 号子功能是 write 系统调用（不是 C 库函数 write）
    mov ebx, [ebp+8] ;第 1 个参数
    mov ecx, [ebp+12] ;第 2 个参数
    mov edx, [ebp+16] ;第 3 个参数
    int 0x80 ;发起中断，通知 Linux 完成请求的功能
    pop ebp ;恢复 ebp
    ret
    