[bits 32] 


VIDEO_MEMORY equ 0xb8000
RED_ON_BLACK equ 0x04 ; color byte

print32:
    pusha
    mov edx, VIDEO_MEMORY

print32_loop:
    mov al, [ebx] ; [ebx] is the address of our character
    mov ah, RED_ON_BLACK ; attributes in ah

    cmp al, 0 ; check if end of string
    je print32_done ;jump to done 

    mov [edx], ax ;store char and attributes 
    add ebx, 1 ;next char in string 
    add edx, 2 ;next char in memory

    jmp print32_loop

print32_done:
    popa
    ret

newline:
