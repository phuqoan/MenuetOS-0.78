;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                           ;
;   SYSTEM TREE BROWSER                     ;
;                                           ;
;   Compile with FASM for MenuetOS          ;
;                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


use32

               org    0x0
               db     'MENUET01'              ; 8 byte id
               dd     0x01                    ; header version
               dd     START                   ; program start
               dd     I_END                   ; program image size
               dd     0x100000                ; required amount of memory
               dd     0x7f000                 ; stack
               dd     0x0,0x0                 ; param,icon

START:                          ; start of execution

    call read_directory
    call draw_window            ; at first, draw the window

still:

    mov  eax,10                 ; wait here for event
    int  0x40

    cmp  eax,1                  ; redraw request ?
    jz   red
    cmp  eax,2                  ; key in buffer ?
    jz   key
    cmp  eax,3                  ; button in buffer ?
    jz   button

    jmp  still

  red:                          ; redraw
    call draw_window
    jmp  still

  key:                          ; key
    mov  eax,2                  ; just read it and ignore
    int  0x40
    jmp  still

  button:                       ; button
    mov  eax,17
    int  0x40

    cmp  ah,1                   ; button id=1 ?
    jnz  noclose
    mov  eax,0xffffffff         ; close this program
    int  0x40
  noclose:

    pusha                       ; clear info text area
    mov  eax,13
    mov  ebx,70*65536+300
    mov  ecx,265*65536+8
    mov  edx,0xffffff
    int  0x40
    popa

     cmp  ah,41                  ; button id=12 -> directory
     jb   noreadhd

    shr  eax,8
    sub  eax,41
    imul eax,12

    cmp  eax,[loclen]
    jge  still

    mov  [loclen],eax
     mov  [readblock],1
     call read_directory
    call drawbuttons

    jmp  still

  noreadhd:

    cmp  ah,13                  ; button id=13 ?
    jnz  noreadhd2

    mov  eax,[readblock]
    cmp  eax,1
    jz   nozer1
    sub  eax,1
    mov  [readblock],eax
    call read_directory
    call drawbuttons
   nozer1:
    jmp  still

  noreadhd2:

    cmp  ah,14                  ; button id=14 ?
    jnz  noreadhd3

    mov  eax,[readblock]
    add  eax,1
    mov  [readblock],eax
    call read_directory
    call drawbuttons
  nozer2:
    jmp  still

  noreadhd3:

    cmp  ah,21
    jge  yesnewdir
    jmp  nonewdir
  yesnewdir:

    pusha
    mov  al,ah
    and  eax,255
    sub  eax,21
    xor  edx,edx
    mov  ebx,62
    mul  ebx
    mov  esi,eax
    add  esi,fileinfo+7

    cmp  [esi],word 'OL'
    jz   folok

    cmp  [esi+14],word 'XT'          ; show txt and asm files
    je   yeseditor
    cmp  [esi+14],word 'SM'
    je   yeseditor
    jmp  noeditor
  yeseditor:

    popa
    shr  eax,8
    sub  eax,21
    imul eax,32
    add  eax,data_area+1024
    mov  esi,eax
    mov  edi,param
    mov  ecx,11
    cld
    rep  movsb

    mov  eax,19
    mov  ebx,editor
    mov  ecx,param
    int  0x40

    jmp  still

  noeditor:
                                ; start application

    popa
    pusha

    mov  al,ah
    and  eax,255
    sub  eax,21
    xor  edx,edx
    mov  ebx,32
    mul  ebx
    mov  ebx,eax
    add  ebx,data_area+1024

    cmp  [location+1],dword 'RAMD'
    jne  no_ramdisk_start
    mov  eax,19
    mov  ecx,0
    int  0x40
  no_ramdisk_start:

    cmp  [location+1],dword 'HARD'
    jne  no_harddisk_start

    mov  esi,ebx
    mov  edi,location+1
    add  edi,[loclen]
    mov  ecx,11
    cld
    rep  movsb

    mov  eax,31
    mov  ebx,location+24
    mov  ecx,[loclen]
    sub  ecx,12
    mov  edx,0x10000
    int  0x40

  no_harddisk_start:

    popa
    jmp  still


  folok:

    popa

    mov  al,ah
    and  eax,255
    sub  eax,21
    xor  edx,edx
    mov  ebx,32
    mul  ebx
    mov  esi,eax
    mov  edi,[loclen]
    add  edi,1
    add  esi,data_area+1024
    cmp  [esi],word '..'     ; if '..'
    jnz  chdir1
    mov  eax,[loclen]
    sub  eax,12
    mov  [loclen],eax
    mov  [readblock],dword 1
    jmp  readhd
  chdir1:
    cmp  [esi],byte '.'     ; if '.'
    jnz  chdir2
    jmp  still
  chdir2:

    add  edi,location
    mov  ecx,11
    cld
    rep  movsb

    mov  eax,[loclen]
    add  eax,12
    mov  [loclen],eax
    mov  [readblock],dword 1

  readhd:

    call read_directory
    call drawbuttons

    jmp  still

  nonewdir:

    jmp  still




;   *********************************************
;   *******  WINDOW DEFINITIONS AND DRAW ********
;   *********************************************


draw_window:

    mov  eax,12                    ; function 12:tell os about windowdraw
    mov  ebx,1                     ; 1, start of draw
    int  0x40

                                   ; DRAW WINDOW
    mov  eax,0                     ; function 0 : define and draw window
    mov  ebx,50*65536+480          ; [x start] *65536 + [x size]
    mov  ecx,50*65536+290          ; [y start] *65536 + [y size]
    mov  edx,0x03ffffff            ; color of work area RRGGBB
    mov  esi,0x808899ff            ; color of grab bar  RRGGBB,8->color g
    mov  edi,0x008899ff            ; color of frames    RRGGBB
    int  0x40

                                   ; WINDOW LABEL
    mov  eax,4                     ; function 4 : write text to window
    mov  ebx,8*65536+8             ; [x start] *65536 + [y start]
    mov  ecx,0x10ffffff            ; color of text RRGGBB
    mov  edx,labelt                ; pointer to text beginning
    mov  esi,labellen-labelt       ; text length
    int  0x40

    ; UP

    mov  eax,8                      ; function 8 : define and draw button
    mov  ebx,415*65536+22           ; [x start] *65536 + [x size]
    mov  ecx,37*65536+12            ; [y start] *65536 + [y size]
    mov  edx,13                     ; button id
    mov  esi,[b_color]              ; button color RRGGBB
    int  0x40
    mov  ebx,424*65536+40           ; draw info text with function 4
    mov  ecx,0xffffff
    mov  edx,up
    mov  esi,1
    mov  eax,4
    int  0x40

    ; DOWN

    mov  eax,8                     ; function 8 : define and draw button
    mov  ebx,438*65536+22          ; [x start] *65536 + [x size]
    mov  ecx,37*65536+12           ; [y start] *65536 + [y size]
    mov  edx,14                    ; button id
    mov  esi,[b_color]             ; button color RRGGBB
    int  0x40
    mov  ebx,447*65536+40          ; draw info text with function 4
    mov  ecx,0xffffff
    mov  edx,down
    mov  esi,1
    mov  eax,4
    int  0x40

    call drawbuttons

    mov  eax,12                    ; function 12:tell os about windowdraw
    mov  ebx,2                     ; 2, end of draw
    int  0x40

    ret



drawbuttons:

    pusha

    mov  ebx,150*65536+310
    mov  ecx,50*65536+12
    mov  edx,21
    mov  esi,0x3344aa;0x6677cc

 newb:

    push edx
    mov  eax,8
    add  edx,0x80000000
    int  0x40
    pop  edx
    int  0x40

    pusha
    sub  ebx,130*65536
    mov  bx,120
    add  edx,20

    push edx
    add  edx,0x80000000
    int  0x40
    pop  edx

    int  0x40
    popa

    pusha
    sub  edx,21
    mov  esi,edx
    imul edx,12
    cmp  edx,[loclen]
    jg   no_dir_text
    mov  eax,4
    sub  ebx,125*65536
    shr  ecx,16
    mov  bx,cx
    add  bx,3
    shl  esi,2+16
    add  ebx,esi
    mov  ecx,0xffffff
    add  edx,root
    cmp  edx,root
    jne  no_yellow
    mov  ecx,0xffff00
  no_yellow:
    mov  esi,11
    int  0x40
  no_dir_text:
    popa

    pusha
    sub  edx,21
    mov  eax,edx
    xor  edx,edx
    mov  ebx,62
    mul  ebx
    add  eax,fileinfo
    mov  ebx,155*65536
    shr  ecx,16
    mov  bx,cx
    add  ebx,5*65536+3
    mov  ecx,0xffffff
    cmp  [eax+21],word 'SM'
    jnz  noasm
    mov  ecx,0x88ffff
  noasm:
    cmp  [eax+7],word 'OL'
    jnz  nofolt
    mov  ecx,0xffff00
  nofolt:
    cmp  [eax+7],word 'EL'
    jnz  nodelt
    mov  ecx,0x99aaee
  nodelt:
    mov  edx,eax
    mov  esi,57
    mov  eax,4
    int  0x40
    popa

    add  ecx,(13*65536)
    inc  edx
    cmp  edx,37
    jnz  newb

    popa

    ret



fileinfoblock:

   dd 0x0       ; read
   dd 0x0       ; first block
   dd 0x1       ; number of blocks to read
   dd 0x20000   ; ret
   dd 0x10000   ; work
filedir:
   times 12*10 db 32



read_directory:

    mov  edi,0x20000
    mov  eax,0
    mov  ecx,512
    cld
    rep  stosb

    mov  esi,location
    mov  edi,filedir
    mov  ecx,12*8
    cld
    rep  movsb

    mov  eax,[loclen]
    mov  [filedir+eax],byte 0

    mov  eax,[readblock]
    dec  eax
    mov  [fileinfoblock+4],eax
    mov  eax,58
    mov  ebx,fileinfoblock
    int  0x40

    cmp  eax,0
    jne  hd_read_error

    mov  [dirlen],ebx
    mov  esi,0x20000
    mov  edi,data_area+1024
    mov  ecx,512
    cld
    rep  movsb

    mov  ebx,1024

    ; command succesful

    mov  esi,data_area+1024
    mov  edi,fileinfo+11
    mov  edx,16

  newlineb:

    pusha               ; clear
    mov  al,32
    mov  ecx,58
    sub  edi,11
    cld
    rep  stosb
    popa

    mov  cl,[esi]       ; end of entries ?
    cmp  cl,6
    jnz  noib0

    mov  [edi-5],dword 'EOE '
    add  esi,32
    add  edi,62
    jmp  inf

  noib0:

    mov  cl,[esi+0]
    cmp  cl,0xe5
    je   yesdelfil

    mov  cl,[esi+11]    ; long fat32 name ?
    cmp  cl,0xf
    jnz  noib1

    mov  [edi-5],dword 'F32 '
    add  esi,32
    add  edi,62
    jmp  inf

  noib1:

    mov  eax,'DAT '     ; data or .. ?

    mov  cl,[esi+0]     ; deleted file
    cmp  cl,0xe5
    je   yesdelfil
    cmp  cl,0x0
    je   yesdelfil
    jmp  nodelfil
   yesdelfil:
    mov  eax,'DEL '
    jmp  ffile
  nodelfil:

    mov  cl,[esi+11]    ; folder
    and  cl,0x10
    jz   ffile
    mov  eax,'FOL '
    mov  [edi-5],eax
    mov  [edi+45],byte '-'
    jmp  nosize

  ffile:

    mov  [edi-5],eax

    pusha               ; size
    mov  eax,[esi+28]
    mov  esi,edi
    add  esi,37
    mov  ebx,10
    mov  ecx,8
  newnum:
    xor  edx,edx
    div  ebx
    add  dl,48
    mov  [esi],dl
    cmp  eax,0
    jz   zernum
    sub  esi,1
    loop newnum
  zernum:
    popa
  nosize:

    pusha                    ; date
    mov  [edi+17],dword '.  .'
    mov  [edi+21],dword '2002'
    movzx eax,word [esi+24]
    mov  ecx,eax
    mov  ebx,32
    xor  edx,edx
    div  ebx
    xor  edx,edx
    mov  ebx,10
    div  ebx
    add  al,48 ; year
    movzx eax,dl
    xor  edx,edx
    mov  ebx,10
    div  ebx
    add  al,48
    add  dl,48
    mov  [edi+15],byte '0'   ; day
    mov  [edi+16],byte '0'

    mov  eax,ecx
    xor  edx,edx
    mov  ebx,32
    div  ebx
    xor  edx,edx
    mov  ebx,16
    div  ebx
    mov  eax,edx
    xor  edx,edx
    mov  ebx,10
    div  ebx
    add  al,48
    add  dl,48
    mov  [edi+18],al         ; month
    mov  [edi+19],dl
    popa


    pusha                    ; number
    mov  ecx,17
    sub  ecx,edx
    mov  eax,[readblock]
    sub  eax,1
    shl  eax,4
    add  eax,ecx
    xor  edx,edx
    mov  ebx,10
    div  ebx
    add  dl,48
    mov  [edi-8],dl          ;0001
    xor  edx,edx
    div  ebx
    add  dl,48
    mov  [edi-9],dl          ;0010
    xor  edx,edx
    div  ebx
    add  al,48
    add  dl,48
    mov  [edi-10],dl         ;0100
    mov  [edi-11],al         ;1000
    mov  [edi-7],byte '.'
    popa

    mov  ecx,8          ; first 8
    cld
    rep  movsb
    mov  [edi],byte '.'
    add  edi,1
    mov  ecx,3          ; last 3
    cld
    rep  movsb

    add  esi,(32-11)
    add  edi,(60-12+2)

  inf:

    sub  edx,1
    cmp  edx,0
    jnz  newlineb

    ret


hd_read_error:

    cmp  eax,1
    jnz  la1
    mov  edx,nodef
    mov  esi,50
  la1:
    cmp  eax,2
    jnz  la2
    mov  esi,nosup
    mov  edi,data_area+8
    mov  ecx,50
    cld
    rep  movsb
    mov  edx,data_area
    mov  esi,8+50
  la2:
    cmp  eax,3
    jnz  la3
    mov  esi,unknw
    mov  edi,data_area+8
    mov  ecx,50
    cld
    rep  movsb
    mov  edx,data_area
    mov  esi,8+50
  la3:
    cmp  eax,4
    jnz  la4
    mov  edx,xpart
    mov  esi,50
  la4:
    cmp  eax,5
    jnz  la5
    mov  edx,eof
    mov  esi,50
    dec  dword [readblock]
    add  [loclen],dword 12

  la5:
    cmp  eax,6
    jnz  la6
    mov  edx,fnf
    mov  esi,50
  la6:

    mov  eax,4
    mov  ebx,70*65536+265
    mov  ecx,0x00000000
    int  0x40

    sub  [loclen],dword 12
    jmp  read_directory



; DATA AREA


dirlen    dd   0x1
b_color   dd   0x6677cc
editor    db   'TINYPAD    '
param     db   '           ',0
text      db   '/                       '
up        db   0x18
down      db   0x19
xx        db   'x'
loclen    dd  0
readblock dd  1
 labelt    db   'SYSTEM TREE'
 labellen:
root      db   'ROOTDIR     '


location:

          db    '/           /           /           /           '
          db    '/           /           /           /           '
          db    '/           /           /           /           '
          db    '/           /           /           /           '
          db    '/           /           /           /           '
          db    '/           /           /           /           '
          db    '/           /           /           /           '
          db    '/           /           /           /           '

fileinfo:

    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '
    db   '  00.              .     10.20  01.01.00                      '

nodef   db   'NO HD BASE AND/OR FAT32 PARTITION DEFINED.         '
xpart   db   'INVALID PARTITION AND/OR HD BASE                   '
nosup   db   '<- FS, NO SUPPORT YET                              '
unknw   db   '<- UNKNOWN FS                                      '
eof     db   'END OF FILE                                        '
fnf     db   'FILE NOT FOUND                                     '

data_area:

I_END:




