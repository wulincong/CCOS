CC = gcc -Wall
OBJ := mbr.bin loader.bin kernel.bin
TOP_DIR := $(PWD)
BOOT_DIR := $(PWD)/boot
KERNEL_DIR := $(PWD)/kernel

SUB_DIR := boot kernel 

export CC OBJ TOP_DIR BOOT_DIR KERNEL_DIR 

all: $(SUB_DIR)

$(SUB_DIR):ECHO 
	make -C $@

ECHO:
	@echo $(SUB_DIR)
	@echo begin compile

.PHONY:run 
run:
	dd if=$(BOOT_DIR)/mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
	dd if=$(BOOT_DIR)/loader.bin of=hd60M.img bs=512 count=5 seek=2 conv=notrunc
	dd if=$(KERNEL_DIR)/kernel.bin of=hd60M.img bs=512 count=200 seek=9 conv=notrunc
	echo "kernel.bin ready!"

	bochs -f bochsrc.disk

clean:
	rm  $(BOOT_DIR)/*.bin $(KERNEL_DIR)/*.bin  