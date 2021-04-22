BOOT_FILE = ./boot







.PHONY:run 
run:
	dd if=$(BOOT_FILE)/mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
	dd if=$(BOOT_FILE)/loader.bin of=hd60M.img bs=512 count=8 seek=2 conv=notrunc

#	dd if=./kernel/kernel.bin of=hd60M.img bs=512 count=200 seek=9 conv=notrunc
#	echo "kernel.bin ready!"

	bochs -f bochsrc.disk
