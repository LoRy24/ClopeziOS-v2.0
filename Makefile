build_all:
	fasm ./src/boot/boot.asm ./bin/os.img

	fsutil file setEOF ./bin/os.img 2048

run:
	qemu-system-i386 -hda ./bin/os.img

all:
	make build_all
	make run
