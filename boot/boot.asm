[bits 16]
[org 0x7c00]

KERNEL_OFFSET equ 0x1000 ; The same one we used when linking the kernel

mov [BOOT_DRIVE], dl ; Remember that the BIOS sets us the boot drive in 'dl' on boot
mov bp, 0x9000
mov sp, bp

call load_kernel ; read the kernel from disk
call switch_to_32bit ; disable interrupts, load GDT,  etc. Finally jumps to 'BEGIN_PM'
jmp $ ; Never executed

%include "boot/disk.asm"
%include "boot/gdt.asm"

[bits 16]
load_kernel:
    mov bx, KERNEL_OFFSET ; Read from disk and store in 0x1000
    mov dh, 2
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
BEGIN_32BIT:
    call KERNEL_OFFSET ; Give control to the kernel
    jmp $ ; Stay here when the kernel returns control to us (if ever)


BOOT_DRIVE db 0 ; It is a good idea to store it in memory because 'dl' may get overwritten


[bits 16]
switch_to_32bit:
    cli ; 1. disable interrupts
    lgdt [gdt_descriptor] ; 2. load the GDT descriptor
    mov eax, cr0
    or eax, 0x1 ; 3. set 32-bit mode bit in cr0
    mov cr0, eax
    jmp CODE_SEG:init_32bit ; 4. far jump by using a different segment

[bits 32]
init_32bit: ; we are now using 32-bit instructions
    mov ax, DATA_SEG ; 5. update the segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; 6. update the stack right at the top of the free space
    mov esp, ebp

    call BEGIN_32BIT ; 7. Call a well-known label with useful code

; padding
times 510 - ($-$$) db 0
dw 0xaa55
