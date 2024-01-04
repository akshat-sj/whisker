# $@ = target file
# $< = first dependency
# $^ = all dependencies

SRC_DIR := kernel
BOOT_DIR := boot
BUILD_DIR := build

all: $(BUILD_DIR)/os-image.bin

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel_entry.o $(BUILD_DIR)/kernel.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

$(BUILD_DIR)/kernel_entry.o: $(SRC_DIR)/kernel_entry.asm
	nasm $< -f elf -o $@

$(BUILD_DIR)/kernel.o: $(SRC_DIR)/kernel.c
	gcc -fno-pie -m32 -ffreestanding -c $< -o $@

$(BUILD_DIR)/kernel.dis: $(BUILD_DIR)/kernel.bin
	ndisasm -b 32 $< > $@

$(BUILD_DIR)/boot.bin: $(BOOT_DIR)/boot.asm
	nasm $< -f bin -o $@

$(BUILD_DIR)/os-image.bin: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $^ > $@

run: $(BUILD_DIR)/os-image.bin
	qemu-system-i386 -fda $<

clean:
	$(RM) $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.o $(BUILD_DIR)/*.dis





