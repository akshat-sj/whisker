[bits 16] ; our code starts in 16 bit mode using the directive given here
[org 0xc7c00] ; bios finds boot sector and it is loaded at 0x0000:0ex7c00
              ; this is important as when using labels they get transalated into memory adresses
              ; these memory adresses need the current offset 
              ; the memory area is likely to also be unusable until execution has been transferred to a second stage bootloader, or to your kernel. 

OFFSET equ 0x1000 ;this is where we load the kernel to in the memory point
mov [BOOT_DRIVE], dl ; this is the byte that stores the boot drive number that bios understands to load the boot sectors

; the stack is a data structure we can use to push and pop elements 
; in x86 and other architectures there is one stack for code execution , we return pointers when we calling routines

mov bp,0x9000 ;stack here is set up with bottom pointeer, we place it at the following adress so we have enough space for the stack to grow downwards and avoid collisions
mov sp,bp ; the stack here keeps track of memory to avoid collisions

;loads the kernel to memory and switches the proccesor to 32 bit protected mode 
call load_kernel 
call switch_to_32bit

; jumps to current location and creates infinte loop that repeats same set of instructions over and over again
jmp $ 

%include "disk.asm"
%include "gdt.asm"
%include "switch-to-32bit.asm"

[bits 16]
load_kernel:
  mov bx, OFFSET ; our destination adress is bx 
  mov dh, 2 ; the number of sectors we have to read 
  mov dl, [BOOT_DRIVE] ; disk number 
  call disk_load
  ret 

[bits 32]
BEGIN_32BIT:
  call OFFSET ; gives control to kernel 
  jmp $ ; keep looping the instructions when kernel returns 

BOOT_DRIVE db 0 

times 510-($-$$) db 0 
; pad to fill data upto 510 bytes and ($-$$) gives length of program so far measured in bytes
dw 0xaa55
; last bytes neeed to be AA55 to run 
;




