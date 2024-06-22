export DISPLAY=localhost:10.0
nasm code/boot.asm -o out/boot.bin
nasm code/loader.asm -o out/loader.bin

dd if=out/boot.bin of=bochs/boot.img bs=512 count=1 conv=notrunc
mount bochs/boot.img  /media/ -t vfat -o loop
cp out/loader.bin /media/
sync
umount /media/

bochs/run_bochs.sh