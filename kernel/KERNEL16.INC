;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                            ;;
;; KERNEL16.INC                                               ;;
;;                                                            ;;
;; Included 16 bit kernel files for MenuetOS                  ;;
;;                                                            ;;
;; This file is kept separate as it will be easier to         ;;     
;; maintain and compile with an automated SETUP program       ;;
;; in the future.                                             ;;
;;                                                            ;;
;; Copyright Ville Turjanmaa, see file COPYING for details.   ;;
;;                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   
;% +include
   
include "BOOTENG.INC"     ; english system boot messages
include "BOOTCODE.INC"    ; 16 bit system boot code
   
include "PCI16.INC"

;% -include
   
   
   
