[org 0x7c00]
KERNEL_OFFSET equ 0x1000 

mov [BOOT_DRIVE], dl 
mov bp, 0x9000
mov sp, bp


call load_kernel 
call switch_to_32bit 
jmp $ 

%include "boot/mew.asm"
%include "boot/gdt.asm"

[bits 16]
load_kernel:

    mov bx, KERNEL_OFFSET 
    mov dh, 16
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
BEGIN_32BIT:
    mov ebx, MSG_32BIT_MODE
    call print32
    call print32
    call KERNEL_OFFSET 
    jmp $ 


disk_load:
    pusha
    push dx

    mov ah, 0x02 
    mov al, dh   
    mov cl, 0x02
    mov ch, 0x00 
    mov dh, 0x00 
    int 0x13    
    jc disk_error 

    pop dx
    cmp al, dh    
    jne sectors_error
    popa
    ret


disk_error:
    jmp disk_loop

sectors_error:

disk_loop:
    jmp $



[bits 16]
switch_to_32bit:
    cli 
    lgdt [gdt_descriptor] 
    mov eax, cr0
    or eax, 0x1 
    mov cr0, eax
    jmp CODE_SEG:init_32bit 

[bits 32]
init_32bit: 
    mov ax, DATA_SEG 
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 
    mov esp, ebp

    call BEGIN_32BIT 

BOOT_DRIVE db 0 
MSG_32BIT_MODE db "Booted into protected 32-bit mode :)                                                                 ", 0

; padding
times 510 - ($-$$) db 0
dw 0xaa55
