all:mbr.bin hd60M.img

mbr.bin:mbr.S
	nasm -o mbr.bin mbr.S

loader.bin:loader.S
	nasm -o loader.bin loader.S

hd60M.img:mbr.bin loader.bin
	dd if=mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=hd60M.img bs=512 count=1 seek=2 conv=notrunc

.PHONY:run 
run:
	bochs -f bochsrc
clean:
	rm mbr.bin loader.bin 