nasm -f elf -o .\syscall_write.o .\syscall_write.S

ld -o .\syscall_write.bin .\syscall_write.o

chmod u+x .\syscall_write.bin