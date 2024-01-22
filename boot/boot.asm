[org 0x7c00] ; tells the assembler that the bootloader will be loaded at 0x7c00 
; the reason 0x7c00 is chosen by BIOS is beacuse it knows it won't be taken by some important subroutines
; x86 cpu registers general purpose - [a-d]x 
KERNEL_OFFSET equ 0x1000 ; this is where we load the kernel 
mov [BOOT_DRIVE] , dl ;BIOS stores selected boot drive in dl register
; since the cpu has a limited amount of storage for temeporary variables we create a stack 
; reading and writing from the kernel is also convenient with out stack
; bp is base pointer of stack and sp is top pointer of stack
; the stack in memory is unique and interesting in the sense that it grows downwards
; we can also store return pointers when we call subrotines 

mov bp, 0x9000 ;here the adress we have chosen is 0x9000 so that we have ample space between bootloader and stack pointer to not overwrite each other
mov sp,bp 

call load_kernel 
call switch_to_32bit 
jmp $

%include "boot/mew.asm"
%include "boot/gdt.asm"
;the reason we initially boot our os in real mode is mainly for backwards compabitipility
; it emulates an 8086 cpu 

[bits 16] ; this is a directive to set real mode 
load_kernel:
  mov bx,KERNEL_OFFSET ;the memory location we read data into 
  mov dh,16 ; the number of sectors we are reading are 16 
  mov dl,[BOOT_DRIVE] ; dl register will hold the boot driver number
  call disk_load 
  ret ;ends subroutine and transfers control back to main code
[bits 32] ;code generation in 32-bit mode 
begin_32bit:
  mov ebx, MSG_32BIT_MODE ; stores value of message in ebx register 
  call print32 ;prints test in ebx register 
  call KERNEL_OFFSET 
  jmp $ ; jump to current instruction (infinite loop)

; reading from disk isn't hard in 16 bit mode 
; ah = disk mode (0x02 = read )
; ch = cylinder 
; cl = sector 
; dh= head
; dl = drive 
; es:bx memory adress we load into 
; mettalic coating of disks give them property to magnetically access information
; They use chs system to read and write data which is basically a 3d co-ordinate system 
; The cylinder describes heads distance from the outer edge of platter
; Head describes which track we are interested in 
; Sector the circular track divided into sectors of 512 bytes
; we are loading sectors from  ES:BX from drive dl 
[bits 16]
disk_load:
    pusha ; we push all general purpose registers into stack 
    push dx ; we push the dx register into stack now because it is the higher part of the number of sectors we are going to read 

    mov ah, 0x02 ;BIOS read sector function 
    mov al, dh   ; we read dh sector (basically head)
    mov ch, 0x00 ; we select cylinder 0 
    mov dh, 0x00 ; we select head as 0 
    mov cl, 0x02 ; we select sector as 2
    int 0x13   ; this is the bios interrupt that allows for disk access  
    jc disk_error ; this is the carry bit that indicates if there is a disk error 

    pop dx ; pop the dx  register 
    cmp al, dh   ; if (al= sectors read )!= (dh = sectors expected) then throw error 
    jne sectors_error 
    popa ; pop all genral purpose register 
    ret


disk_error:
    mov bx, disk_error_message ;prints disk error message 
    call print32 ;calls print subroutine 
    jmp disk_loop

sectors_error:

disk_loop:
    jmp $

disk_error_message db " Disk read error ! " , 0 

[bits 16] ; 16 bit directive 
switch_to_32bit:
    cli ;(clear interrupts)switches off interrupts untill we have protected mode on else interrupt vector will clash
        ; ignores interrupts untill turned back on 
        ; this also makes old interrupt vector table(IVT) set up by BIOS completely obsolete
        ; Old bios subrouties are also written in 16 bit whcich are now useless in 32 bit mode 
        ; need to write an IDT to substitute our old IVT 
    lgdt [gdt_descriptor] ;load the gdt table 
    mov eax, cr0 ;set first bit of control register 
    ;Bit |	   Label       | Description
    ;----------------------------------
    ;PE  |	Protected Mode | Enable
    or eax, 0x1 ; since we cant directly set we do or operation with 1 
    mov cr0, eax ; now bit is set in eax and we shift value into cr0
                ; now cpu is in 32-bit protected mode (kind of) 
                ; now the problem we have to encounter is the cpus pipelining
                ; pipelining essentially means that the cpu is executes different instructions at different times (fetch decode exaecute are done differntly)
                ; this means there is an risk of the instructions to be executed in different mode 
    jmp CODE_SEG:init_32bit ; most of the optimizations done by the cpu are done assuming next step is predictable
                            ; conditional logic however cannot be predicted 
                            ; since the pipeline may have unfinished buisness it allows piepeline to be empty
                            ; so we do a far jump to jump to another segment 

[bits 32] ; 32 bit directive 
init_32bit: 
    mov ax, DATA_SEG ; now because we are in protexted mode our old segments are useless
                     ; we point our segment registers to data selector in gdt 
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ;update stakc pointer 
    mov esp, ebp

    call begin_32bit

BOOT_DRIVE db 0 
MSG_32BIT_MODE db "whiskeros booted into protected 32-bit mode :)                                                                 ", 0



; padding
times 510 - ($-$$) db 0 ; here we pad the files with zeroes to postion magic number as the 512th byte of our bootsector
dw 0xaa55 ; this is the magic number which tells the BIOS this is the bootloader and not random data 
