AS = nasm 
LD = ld
CC = gcc 
CFLAGS = -Wall -0 
target = kernel.bin print.o main.o
all: $(target)
kernel.bin: main.o print.o
	$(LD) main.o print.o -m elf_i386 -Ttext 0xC0001500 -e main -o kernel.bin 

print.o: print.S
	$(AS) -f elf -o print.o print.S

main.o:
	$(CC) -m32 -c -o main.o main.c 

clean: 
	rm $(target)
