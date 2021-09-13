   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                          ;;
;;   WINDOW SKIN for MenuetOS               ;;
;;                                          ;;
;;   entryway@bkg.lt                        ;;
;;                                          ;;
;;   Bugfixes & upgrades by                 ;;
;;             Samuel Rodriguez Perez       ;;
;;             Xeoda@ciberirmandade.org     ;;
;;                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   
   
include "SKINDATA.INC"
   
load_default_skin:
   
    pusha
    cmp   [_refleft], 0
    jnz   skinok1
    mov   [_refleft], 0x778000
    mov   eax,_fileleft
    mov   ebx, 1
    mov   ecx, -1
    mov   edx,[_refleft]
    mov   esi,12
    call  fileread
skinok1:
    cmp   [_refbase], 0
    jnz   skinok2
    mov   eax,[_skinh]
    mov   ebx,[_skinleftw]
    imul  eax,ebx
    imul  eax,3
    add   eax,[_refleft]
    mov   [_refbase],eax
    mov   eax,_filebase
    mov   ebx, 1
    mov   ecx, -1
    mov   edx,[_refbase]
    mov   esi,12
    call  fileread
skinok2:
    cmp   [_refoper], 0
    jnz   skinok3
    mov   eax,[_skinh]
    mov   ebx,[_skinbasew]
    imul  eax,ebx
    imul  eax,3
    add   eax,[_refbase]
    mov   [_refoper],eax
    mov   eax,_fileoper
    mov   ebx, 1
    mov   ecx, -1
    mov   edx,[_refoper]
    mov   esi,12
    call  fileread
skinok3:
    popa
    ret
   
   
drawwindow_IV:
   
        pusha
   
        push  edx
   
        mov   edi,[esp]                              ; RECTANGLE
   
        mov   eax,[edi+0]
        shl   eax,16
        mov   ax,[edi+0]
        add   ax,[edi+8]
        mov   ebx,[edi+4]
        shl   ebx,16
        mov   bx,[edi+4]
        add   bx,[edi+12]
;        mov   esi,[edi+24]
;        shr   esi,1
;        and   esi,0x007f7f7f
        mov   esi,[_coloroutborder]
        call  draw_rectangle
        mov   ecx,3
      _dw3l:
        add   eax,1*65536-1
        add   ebx,1*65536-1
        mov   esi,[_colorframe] ;[edi+24]
        call  draw_rectangle
        dec   ecx
        jnz   _dw3l
        mov   esi,[_colorborder]
        add   eax,1*65536-1
        add   ebx,1*65536-1
        call  draw_rectangle
   
        mov   esi,[esp]
        mov   eax,[esi+8]    ; window width
        mov   edx,[_skinleft]
        shl   edx,16
        mov   ecx,[_skinleftw]
        shl   ecx,16
        add   ecx,[_skinh]
        mov   ebx,[_refleft]
        call  sys_putimage
   
        mov   esi,[esp]
        mov   eax,[esi+8]
        sub   eax,[_skinleftw]
        sub   eax,[_skinoperw]
        cmp   eax,[_skinbase]
        jng    non_base
        mov   edx,0
        mov   ebx,[_skinbasew]
        div   ebx
   
        inc   eax
   
        mov   ebx,[_refbase]
        mov   ecx,[_skinbasew]
        shl   ecx,16
        add   ecx,[_skinh]
        mov   edx,[_skinbase]
        sub   edx,[_skinbasew]
        shl   edx,16
      baseskinloop:
        shr   edx,16
        add   edx,[_skinbasew]
        shl   edx,16
        push  eax
        push  ebx
        push  ecx
        push  edx
        call  sys_putimage
   
;        pusha
;        mov   eax,20
;        call  delay_hs
;        popa
   
        pop   edx
        pop   ecx
        pop   ebx
        pop   eax
        dec   eax
        cmp   eax, 0
        jnz   baseskinloop
      non_base:
   
        mov   esi,[esp]
        mov   edx,[esi+8]
        sub   edx,[_skinoperw]
        inc   edx
        shl   edx,16
        mov   ebx,[_refoper]
        mov   ecx,[_skinoperw]
        shl   ecx,16
        add   ecx,[_skinh]
        call  sys_putimage
   
        mov   esi,[esp]
   
        mov   edx,[esi+04]                       ; WORK AREA
        add   edx,21+5
        mov   ebx,[esi+04]
        add   ebx,[esi+12]
        cmp   edx,ebx
        jg    _noinside2
        mov   eax,5
        mov   ebx,[_skinh]
        mov   ecx,[esi+8]
        mov   edx,[esi+12]
        sub   ecx,4
        sub   edx,4
        mov   edi,[esi+16]
        call  drawbar
      _noinside2:
   
        mov   edi,[0xfe88]
        movzx eax,word [edi]
        cmp   eax,1000
        jge   no_skin_add_button
        inc   eax
        mov   [edi],ax
   
        shl   eax,4
        add   eax,edi
   
        mov   bx,[0x3000]
        mov   [eax],bx
   
        add   eax,2         ; save button id number
        mov   bx,1
        mov   [eax],bx
        add   eax,2         ; x start
        mov   ebx,[esp]
        mov   ebx,[ebx+8]
        cmp   [_buttonCx],0
        jg    _bCx_at_right
        mov   ebx,[_buttonCw]    ; ebx will be 0 in next instruction
      _bCx_at_right:
        sub   ebx,[_buttonCw]
        sub   ebx,[_buttonCx]
        mov   [eax],bx
        add   eax,2         ; x size
        mov   ebx,[_buttonCw]
        mov   [eax],bx
        add   eax,2         ; y start
        mov   ebx,[_buttonCy]
        mov   [eax],bx
        add   eax,2         ; y size
        mov   ebx,[_buttonCh]
        mov   [eax],bx
   
      no_skin_add_button:
   
        add   esp,4
        popa
        ret
   
   
   