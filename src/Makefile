# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile
all: run

# Notice how dependencies are built as needed
kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

kernel_entry.o: kernel_entry.asm
	nasm $< -f elf -o $@

kernel.o: kernel.c
	gcc -fno-pie -m32 -ffreestanding -c $< -o $@

kernel.dis:kernel.bin
	ndiasm -b 32 $< > $@

boot.bin: boot.asm
	nasm $< -f bin -o $@

os-image.bin: boot.bin kernel.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

echo: os-image.bin
	xxd $<

clean:
	$(RM) *.bin *.o *.dis
