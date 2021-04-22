all: loader.bin mbr.bin  

loader.bin: loader.S ./include/boot.inc  util.S 
	nasm -I ./include loader.S -o loader.bin

mbr.bin: mbr.S ./include/boot.inc 
	nasm -I ./include mbr.S -o mbr.bin

clean:
	rm loader.bin mbr.bin