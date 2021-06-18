AS = nasm 
LD = ld
CC = gcc 
CFLAGS = -m32 -c -Wall -fno-builtin -fno-stack-protector
#target = kernel.bin print.o main.o init.o
CFILES = $(wildcard *.c)
OTARGETS = $(addsuffix .o, $(basename $(CFILES))) kernel.o print.o
TARGETS = kernel.bin $(OTARGETS)

all: $(TARGETS)

kernel.bin: $(OTARGETS)
	$(LD) main.o init.o interrupt.o kernel.o print.o -m elf_i386 -Ttext 0xC0001500 -e main -o kernel.bin 

kernel.o:kernel.S 
	$(AS) -f elf -o kernel.o kernel.S

print.o: print.S
	$(AS) -f elf -o print.o print.S

interrupt.o:interrupt.c 
	$(CC) $(CFLAGS) interrupt.c -o interrupt.o 

init.o: init.c 
	$(CC) $(CFLAGS) init.c -o init.o 

main.o: main.c
	$(CC) $(CFLAGS) -o main.o main.c 

show:
	echo $(OTARGETS)
clean: 
	rm $(TARGETS)
