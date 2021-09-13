;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                      ;;
;; RAMDISK functions                                                    ;;
;; (C) 2004 Ville Turjanmaa, License: GPL                               ;;
;;                                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ramdisk_free_space:    
;---------------------------------------------
;
; returns free space in edi
;   
;---------------------------------------------

        push   eax ebx ecx

        mov    eax,0x280000
        xor    edi,edi
        mov    ecx,1448000/512
      rdfs1:
        mov    ebx,[eax]
        and    ebx,4095
        cmp    ebx,0
        jne    rdfs2
        add    edi,512
      rdfs2:
        add    eax,2
        loop   rdfs1

        pop    ecx ebx eax
        ret
   

expand_filename:
;---------------------------------------------
;
; exapand filename with '.' to 11 character
;   
;---------------------------------------------

        push esi edi ebx
   
        mov  edi,esp                  ; check for '.' in the name
        add  edi,12+8

        mov  esi,eax
   
        mov  eax,edi
        mov  [eax+0],dword '    '
        mov  [eax+4],dword '    '
        mov  [eax+8],dword '    '
   
      flr1:
   
        cmp  [esi],byte '.'
        jne  flr2
        mov  edi,eax
        add  edi,7
        jmp  flr3
   
      flr2:
   
        mov  bl,[esi]
        mov  [edi],bl
   
      flr3:
   
        inc  esi
        inc  edi
   
        mov  ebx,eax
        add  ebx,11
   
        cmp  edi,ebx
        jbe  flr1
   
        pop  ebx edi esi
        ret
   
   
fileread:
;----------------------------------------------------------------
;
;  fileread - sys floppy
;
;  eax  points to filename 11 chars
;  ebx  first wanted block       ; 1+ ; if 0 then set to 1
;  ecx  number of blocks to read ; 1+ ; if 0 then set to 1
;  edx  mem location to return data
;  esi  length of filename 12*X
;
;  ret ebx = size or 0xffffffff file not found
;      eax = 0 ok read or other = errormsg
;
;--------------------------------------------------------------

        cmp    esi,0               ; return ramdisk root
        jne    fr_noroot
        cmp    ebx,224/16
        jbe    fr_do
        mov    eax,5
        mov    ebx,0
        ret
   
      fr_do:
        mov    edi,edx
        dec    ebx
        shl    ebx,9
        mov    esi,0x100000+512*19
        add    esi,ebx
        shl    ecx,9
        cld
        rep    movsb
        mov    eax,0 ; ok read
        mov    ebx,0
        ret
   
     fr_noroot:
   
        sub    esp,32
        call   expand_filename
   
      frfloppy:
   
        cmp    ebx,0
        jne    frfl5
        mov    ebx,1
      frfl5:
   
        cmp    ecx,0
        jne    frfl6
        mov    ecx,1
      frfl6:
   
        dec    ebx
   
        push   eax

        push   eax ebx ecx edx esi edi

        mov    edi,0x100000+512*18+512  ;Point at directory
        mov    edx,224 +1
   
l.20:   sub    edx,1
        cmp    edx,0
        jnz    l.21
        mov    eax,5                    ; file not found ?
        mov    ebx,-1
        add    esp,32+28
        ret
      l.21:
        mov    esi,eax                  ;Name of file we want
        mov    ecx,11
        cld
        rep    cmpsb                    ;Found the file?
        je     fifound                  ;Yes
        add    cl, 21                   ;Offset to next directory entry
        add    edi, ecx                 ;Advance to next entry
        jmp    l.20
   
     fifound:
   
        mov    ebx,[edi-11+28]          ;file size
        mov    [esp+20],ebx
        mov    [esp+24],ebx
        add    edi,0xf
        mov    eax,[edi]
        and    eax,65535
        mov    edi,eax                  ;edi=cluster
   
      frnew:
   
        add    eax,31                   ;bootsector+2*fat+filenames
        shl    eax,9                    ;*512
        add    eax,0x100000             ;image base
        mov    ebx,[esp+8]
        mov    ecx,512                  ;[esp+4]
   
        cmp    [esp+16],dword 0         ; wanted cluster ?
        jne    frfl7
        call   memmove
        add    [esp+8],dword 512
        dec    dword [esp+12]           ; last wanted cluster ?
        cmp    [esp+12],dword 0
        je     frnoread
        jmp    frfl8
      frfl7:
        dec    dword [esp+16]
      frfl8:
        shl    edi,1                    ;find next cluster from FAT
        add    edi,0x280000
        mov    eax,[edi]
        and    eax,4095
        mov    edi,eax
        cmp    edi,4095                 ;eof  - cluster
        jz     frnoread2
   
        cmp    [esp+24],dword 512       ;eof  - size
        jb     frnoread
        sub    [esp+24],dword 512
   
        jmp    frnew

      frnoread2:

        cmp    [esp+16],dword 0         ; eof without read ?
        je     frnoread

        pop    edi esi edx ecx
        add    esp,4
        pop    ebx     ; ebx <- eax : size of file
        add    esp,36
        mov    eax,6   ; end of file
        ret

      frnoread:
   
        pop    edi esi edx ecx
        add    esp,4
        pop    ebx     ; ebx <- eax : size of file
        add    esp,36
        mov    eax,0
        ret
   
filedelete:   
;--------------------------------------------
;
; filedelete - sys floppy
;
; in:
; eax - filename 11 chars
;
; out:
; eax - 0 = successful, 1 = file not found
;
;--------------------------------------------

        mov    ebp,1  ; file not found as default

      filedelete_newtry:

        sub    esp,32
        call   expand_filename
   
        push   eax ebx ecx edx esi edi

        mov    edi,0x100000+512*18+512  ;Point at directory
        mov    edx,224 +1
   
     l20d:
        sub    edx,1
        cmp    edx,0
        jnz    l21d
        jmp    frnoreadd
     l21d:
        mov    esi,eax                  ;Name of file we want
        mov    ecx, 11
        cld
        rep    cmpsb                    ;Found the file?
        je     fifoundd                 ;Yes
        add    cl, 21                   ;Offset to next directory entry
        add    edi, ecx                 ;Advance to next entry
        jmp    l20d
     fifoundd:
   
        mov    [edi-11],byte 0xE5       ;mark filename deleted
        add    edi,0xf
        mov    eax,[edi]
        and    eax,65535
        mov    edi,eax                  ;edi = cluster
   
      frnewd:
   
        shl    edi,1                    ;find next cluster from FAT
        add    edi,0x280000
        mov    eax,[edi]
        mov    [edi],word 0x0           ;clear fat chain cluster
        and    eax,4095
        mov    edi,eax
        cmp    edi,dword 4095           ;last cluster ?
        jz     frnoreadd2
   
        jmp    frnewd
   
      frnoreadd2:
   
        pop    edi esi edx ecx ebx eax
        add    esp,32
        mov    ebp,0       ; file found
        jmp    filedelete_newtry
   
      frnoreadd:
   
        pop    edi esi edx ecx ebx eax
        add    esp,32
        mov    eax,ebp
        ret
   
filesave:
;----------------------------------------------------------   
;   
; filesave - sys floppy
;
; eax points to filename 11 chars
;
;        eax      ; pointer to file name
;        ebx      ; buffer
;        ecx      ; count to write in bytes
;        edx      ; 0 create new , 1 append
;
;-----------------------------------------------------------
  
        sub  esp,32
        call expand_filename
        cmp  edx,0
        jnz  fsdel
        pusha
        call filedelete
        popa
   
      fsdel:
   
        call   ramdisk_free_space
        cmp    ecx,edi
        jb     rd_do_save
        add    esp,32
        mov    eax,1    ; not enough free space
        ret
   
      rd_do_save:
   
        push   eax ebx ecx edx esi edi

        mov    edi,0x100000+512*18+512  ;Point at directory
        mov    edx,224 +1
        ; find an empty spot for filename in the root dir
     l20ds:
        sub    edx,1
        cmp    edx,0
        jnz    l21ds
        jmp    frnoreadds
     l21ds:
        cmp    [edi],byte 0xE5
        jz     fifoundds
        cmp    [edi],byte 0x0
        jz     fifoundds
        add    edi,32                   ; Advance to next entry
        jmp    l20ds
     fifoundds:
   
        push   edi                      ; move the filename to root dir
        mov    esi,[esp+4+20]
        mov    ecx,11
        cld
        rep    movsb
        pop    edi
        mov    edx,edi
        add    edx,11+0xf               ; edx <- cluster save position
        mov    ebx,[esp+12]             ; save file size
        mov    [edi+28],ebx
        mov    [edi+11],byte 0x20       ; attribute
        mov    ebx,1                    ; first cluster
   
      frnewds:
   
        add    ebx,1
        mov    edi,ebx                  ; find free cluster in FAT
        shl    edi,1
        add    edi,0x280000
        mov    eax,[edi]
        and    eax,4095
        cmp    eax,0x0
        jnz    frnewds
        mov    [edx],bx                 ; save next cluster pos. to prev cl.
        mov    edx,edi                  ; next save pos abs mem add
        call   fdc_filesave
        pusha                           ; move save to floppy cluster
        add    ebx,31
        shl    ebx,9
        add    ebx,0x100000
        mov    eax,[esp+32+16]
        mov    ecx,512
        call   memmove
        popa
   
        mov    eax,[esp+12]
        cmp    eax,512
        jb     flnsa
        sub    eax,512
        mov    [esp+12],eax
        mov    eax,[esp+16]
        add    eax,512
        mov    [esp+16],eax
        jmp    frnewds
   
     flnsa:
        mov    [edi],word 4095          ; mark end of file - last cluster
   
      frnoreadds:
   
        pop    edi esi edx ecx ebx eax
        add    esp,32

        pusha
        cli
        call   fdc_commitfile
        sti
        popa

        mov    eax,0
        ret



