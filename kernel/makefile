target = kernel.bin print.o main.o
all: $(target)
kernel.bin: main.o print.o
	ld main.o print.o -m elf_i386 -Ttext 0xC0001500 -e main -o kernel.bin 

print.o: print.S
	nasm -f elf -o print.o print.S

main.o:
	gcc -m32 -c -o main.o main.c 

clean: 
	rm $(target)
