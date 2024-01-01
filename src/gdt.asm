; Global Descriptor Table
; this is a data structure used by intel x86 processors to define charecteristics of memory areas
; these memory areas are called segments
; Each segment contains the following information - 
; base adress , default operation size (16/32 bit ), privlige level (???) , segment limit (max legal offset)
; segment presence (if it is present or not ) , descriptor (0 = system / 1 = code ) and segment type

; first entry in the table is the null desctiptor and is never refernecd by our proccesor and contians no data 
gdt_start:
  dd 0x0
  dd 0x0 

; CS ( code segment ) descriptor 
gdt_code:
  dw 0xffff ; segment length (64 KB) bits 0 - 15
  dw 0x0 ;segment base, bits 0-15
  db 0x0 ;segment base , bits 16 - 23
  db 10011010b ; 8 bit flag representing readable , executable code segment 
  db 11001111b ; 8 bit flag representing readable , executable code segment 
  db 0x0 ; segment base 

; DS (data segment ) descriptor
gdt_data:
  dw 0xffff ; segment length (64 KB) bits 0 - 15
  dw 0x0 ;segment base, bits 0-15
  db 0x0 ;segment base , bits 16 - 23
  db 10010010b ; 8 bit flag representing readable , executable code segment 
  db 11001111b ; 8 bit flag representing readable , executable code segment 
  db 0x0 ; segment base 

gdt_end:

;GDT Descriptor
gdt_descriptor:
  dw gdt_end - gdt_start - 1 ; size of GDT (16 bit)
  dd gdt_start ; starting adress 

CODE_SEG equ gdt_code - gdt_start  ;code segment offset 
DATA_SEG equ gdt_data - gdt_start  ; data segment offset 







