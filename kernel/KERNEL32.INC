;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                            ;;
;; KERNEL32.INC                                               ;;
;;                                                            ;;
;; Included 32 bit kernel files for MenuetOS                  ;;
;;                                                            ;;
;; This file is kept separate as it will be easier to         ;;
;; maintain and compile with an automated SETUP program       ;;
;; in the future.                                             ;;
;;                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   
;% +include
   
; processes

include "SYS32.INC"    ; process scheduling

; shutdown

include "SHUTDOWN.INC" ; shutdown or restart

; file system

include "FS.INC"       ; syscall
include "FAT32.INC"    ; read / write
include "RD.INC"       ; ramdisk read / write

; sound
   
include "SB16.INC"     ; playback for Sound Blaster 16
   
; display
   
include "VESA12.INC"   ; Vesa 1.2 functions
include "VESA20.INC"   ; Vesa 2.0 functions
include "VGA.INC"      ; VGA 16 color functions
   
; Network Interface & TCPIP Stack
   
include "STACK.INC"
   
; Mouse pointer
   
include "MOUSE.INC"
   
; Window skinning
   
include "SKINCODE.INC"
   
; Pci functions

include "PCI32.INC"

; Floppy drive controller

include "FDC.INC"

;% -include
   
   
   
   
   
   
