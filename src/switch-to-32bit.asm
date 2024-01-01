[bits 16]
switch_to_32bit:
  cli ; disable interrupts to ensure smooth transition to 
  lgdt [gdt_descriptor] ; load gdt desctiptor 
  mov eax,cr0 ; move control register 0 value into eax  
  or eax,0x1 ;or with 1 to set least sifnigidact bit to 1
  mov cr0,eax ;change value of cr0
  ; we need to these steps to indicate process should be executed in protected omode
  jmp CODE_SEG:init_32bit ;far jump

[bits 32]
init_32bit:
  mov ax, DATA_SEG ; update segemnt register 
  mov ds, ax
  mov ss,ax
  mov es,ax
  mov fs,ax
  mov gs,ax
  mov ebp,0x90000 
  mov esp,ebp 
  call BEGIN_32BIT

