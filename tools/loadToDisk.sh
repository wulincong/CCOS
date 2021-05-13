
dd if=./boot/mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
echo "mbr.bin ready!"

dd if=./boot/loader.bin of=hd60M.img bs=512 count=3 seek=2 conv=notrunc
echo "loader.bin ready!"

dd if=./kernel/kernel.bin of=hd60M.img bs=512 count=200 seek=9 conv=notrunc
echo "kernel.bin ready!"
