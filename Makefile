CC = gcc -m32 -s -O2 -masm=intel
CFLAGS = -Wall
ENTRY = start

AS = as --32
NS = nasm
LD = ld -m elf_i386

QEMU = qemu-system-i386 -d in_asm -fda

LS = ls -l --color

run:edifs
	$(QEMU) boot.img
	$(LS)

nas: boot.s kloader.s
	$(NS) -o boot.img boot.s
	$(NS) -o kloader.sys kloader.s

edifs: nas
	mkdir ./mount_fs_tmp
	mount -o loop boot.img ./mount_fs_tmp
	$(LS)
	$(LS) ./mount_fs_tmp
	mv kloader.sys ./mount_fs_tmp
	$(LS) ./mount_fs_tmp
	umount ./mount_fs_tmp
	$(LS)
	rm -r ./mount_fs_tmp
	$(LS)

kernel: as
	$(LD) -T ini.ld -Map k.map -nostdlib -e $(ENTRY) --oformat binary -o kernel.sys kernel.o
	$(LS)

cmp:
	$(CC) -S kernel.c -Wall
	$(LS)

as: cmp
	$(AS) -o kernel.o kernel.s
	$(LS)

clean:
	$(RM) *.o
	$(RM) *.img
	$(RM) *.map
	$(LS)
