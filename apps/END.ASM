;
;    END
;
;    Ok, this is the sceleton that MENUET 0.38 understands.
;    Do not change the header bits for now. Compile with fasm.
;
   
use32
   
              org     0x0
              db      'MENUET00'              ; 8 byte id
              dd      38                      ; required os
              dd      START                   ; program start
              dd      I_END                   ; program image end
              dd      0x100000                ; reguired amount of memory
              dd      0x00000000              ; reserved=no extended header
   
   
START:
   
    call  draw_window
   
still:
   
    mov  eax,10                 ; wait here for event
    int  0x40
   
    cmp  eax,1
    jz   red
    cmp  eax,2
    jz   key
    cmp  eax,3
    jz   button
   
    jmp  still
   
  red:
    call draw_window
    jmp  still
   
  key:
    mov  eax,2
    int  0x40
   
    jmp  still
   
  button:
   
    mov  eax,17
    int  0x40
   
    cmp  ah,1
    jz   boot
   
    mov  eax,0xffffffff ; close this program
    int  0x40
   
    ; end of program
   
  boot:
   
    mov  eax,18    ; system boot
    mov  ebx,1
    int  0x40
   
    mov  eax,0xffffffff ; close this program
    int  0x40
   
   
draw_window:
   
    pusha
   
    mov  eax,48
    mov  ebx,3
    mov  ecx,I_END
    mov  edx,40
    int  0x40
   
    mov  eax,12                    ; tell os about redraw start
    mov  ebx,1
    int  0x40
   
    mov  eax,14                    ; get screen max x & max y
    int  0x40
   
    shr  eax,17
    sub  eax,78
    shl  eax,16
    mov  ebx,eax
    add  ebx,150
   
    mov  eax,0                     ; define and draw window
    mov  ecx,200*65536+65
     mov  edx,[I_END+24]
     mov  esi,[I_END+24]
    mov  edi,0x00ffffff
    int  0x40
   
    mov  eax,8
    mov  ebx,15*65536+55           ; button start x & size
    mov  ecx,40*65536+12           ; button start y & size
    mov  edx,1                     ; button number
    mov  esi,[I_END+24]           ; button color
    int  0x40
   
    mov  eax,8
    mov  ebx,80*65536+55           ; button start x & size
    mov  ecx,40*65536+12           ; button start y & size
    mov  edx,2                     ; button number
    mov  esi,[I_END+24]           ; button color
    int  0x40
   
   
    mov  eax,dword 0x00000004      ; 0x00000004 = write text
    mov  ebx,17*65536+15
    mov  ecx,dword 0x00ffffff      ; 8b window nro - RR GG BB color
    mov  edx,label1                ; pointer to text beginning
    mov  esi,labellen1-label1      ; text length
    int  0x40
   
    mov  eax,dword 0x00000004      ; 0x00000004 = write text
    mov  ebx,14*65536+42
    mov  ecx,dword 0x00ffffff      ; 8b window nro - RR GG BB color
    mov  edx,label2                ; pointer to text beginning
    mov  esi,labellen2-label2      ; text length
    int  0x40
   
    mov  eax,12                    ; tell os about redraw end
    mov  ebx,2
    int  0x40
   
    popa
   
    ret
   
label1:
     db   '     EXIT MENUET     '
labellen1:
   
label2:
    db   '    OK       CANCEL   '
labellen2:
   
   
I_END:
   
   
   
   
   