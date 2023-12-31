disk_load:
  pusha ;pushes all general purpose registers on top of the stack
  push dx ; pushes content of dx register onto the stack (which is number of sectors to read )
  mov ah,2 ; set ah register to read mode (accumulator)
  mov al, dh ; read dh number of sectors
  mov cl,2 ; cl is our starting sector (2), sector 1 is out boot sector

  ; hard drives are organized with cylinders and head
  ; this is chs method od adressing
  ; cylinder containts tracks that are same distance from center of disk 
  ; head is the hard disk that has multiple surfaces that are read or written independently
  mov ch,0 ; cylinder 0
  mov dh,0 ;head 0

  int 0x13 ; bios interrupt 
  jc disk_error ; check carry bit for disk_error

  pop dx ; restore original number of sectors we have to read
  cmp al,dh ; compare if actual number of sectors read is same as number of sectors expected to be read
  jne sector_error ;else we jump to sector error 
  
; we run infinite loop if we run into any error 
disk_error:
  jmp disk_loop

sector_error:
  jmp disk_loop

disk_loop:
  jmp $

          
