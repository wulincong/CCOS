all: loader.bin mbr.bin 

loader.bin: loader.S
	nasm -I ./include loader.S -o loader.bin

mbr.bin: mbr.S
	nasm -I ./include mbr.S -o mbr.bin

clean:
	rm loader.bin mbr.bin