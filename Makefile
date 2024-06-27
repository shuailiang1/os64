all: 
	make boot.bin
	make loader.bin
	make system
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary out/system out/kernel.bin

boot.bin: code/bootloader/boot.asm
	nasm code/bootloader/boot.asm -o out/boot.bin

loader.bin: code/bootloader/loader.asm code/bootloader/fat12.inc
	nasm code/bootloader/loader.asm -o out/loader.bin

system:	head.o main.o printk.o
	ld -b elf64-x86-64 -z muldefs -o out/system out/head.o out/main.o out/printk.o -T code/kernel/Kernel.lds 

main.o:	code/kernel/main.c
	gcc  -mcmodel=large -fno-builtin -m64 -c code/kernel/main.c -o out/main.o

head.o:	code/kernel/head.S
	gcc -E  code/kernel/head.S > out/head.s
	as --64 -o out/head.o out/head.s

printk.o: code/kernel/printk.c code/kernel/lib.h 
	gcc -static  -mcmodel=large -fno-builtin -m64 -c code/kernel/printk.c -fno-stack-protector -o out/printk.o


clean:
	rm -f out/loader.bin
	rm -f out/boot.bin
	rm -f out/*.o
	rm -f out/*.s
	rm -f out/system
	rm -f out/kernel.bin


install:
	dd if=out/boot.bin of=bochs/boot.img bs=512 count=1 conv=notrunc
	mount bochs/boot.img  /media/ -t vfat -o loop
	cp out/loader.bin /media/
	cp out/kernel.bin /media/
	sync
	umount /media/