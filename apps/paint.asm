;*********************************
;*                               *
;*    PAINT 0.02 ��� MenuetOS    *
;*                               *
;*     �������஢��� FASM'��     *
;*                               *
;*********************************

;******************************************************************************
; ��� �ணࠬ�� �� �㦭� ��쥧�� ��ᬠ�ਢ��� - �� �ᥣ� ���� �ਬ��,
; � ���஬ ��������, ��� ࠡ���� � ������묨 ��⥬�묨 �㭪�ﬨ ����,
; �� ����� �� ��ଠ��� ����᪨� ।����. ��� �ணࠬ�� ����� ���⮩,
; � ��� �।�����祭� ��� ��, �� ⮫쪮 ��稭��� ������ ��ᥬ����,
; ���⮬� � ��६���� ᤥ���� ��� ��� ����� ����� ������.
; ��� �� �����, ��� �����쭮 ������ ��⨬���஢��, ��� �� �������
; ����� ����㤭��� ��� ���������. � ����ࠫ�� ��⥫쭮 �ப������஢���
; ᫮��� ����. ����, ���� �ணࠬ�� �ਭ������� �� ���, � Sniper'�, ���
; ���ண� ���饬-� �� � ��ᠫ���.
;   ���� � ���祭�� �ᬠ!
;   ���� ����㡭�, ivan-yar@bk.ru
;******************************************************************************

; ������砥� ����室��� ������
include 'macros.inc'

;******************************************************************************

; ������ ���������
meos_app_start
; ������� ����
code
    mov  eax,40       ; ᮮ�騬 ��⥬�, ����� ᮡ��� �㤥� ��ࠡ��뢠��
    mov  ebx,0100101b ; ��᪠ ᮡ�⨩ - ����ᮢ�� (1) + ������ (3) + ���� (6
    int  0x40         ; �� ������� ��뢠�� ��⥬��� �㭪��

    mov  [workarea.cx],10  ; ���न���� ࠡ�祩 (������᪮�) ������
    mov  [workarea.cy],45  ; ��� �ᮢ����

red:
    call draw_window   ; ��뢠�� ��楤��� ���ᮢ�� ����

still:            ; ������� ���� ��������� - ���� ��������� ���������

    mov  eax,10   ; �㭪�� 10 - ����� ᮡ���; �ணࠬ�� ��⠭���������� ��
    int  0x40     ; ᫥����� ������� �� �㤥� �믮����� �� �� ���, ����
                  ; �� �ந������ ᮡ�⨥

    ; ⥯��� ॣ���� eax ᮤ�ন� ����� ᮡ���
    ; ����।�� �ࠢ��� ��� � �ᥬ� �������묨 ���祭�ﬨ, �⮡� �맢���
    ; �㦭� ��ࠡ��稪

    cmp  eax,1    ; ����ᮢ��� ���� ?
    je   red      ; �᫨ ॣ���� eax ࠢ�� ������, � ���室�� �� ���� red
    cmp  eax,3    ; ����� ������ ?
    je   button
    cmp  eax,6    ; ����?
    je   mouse

    jmp  still    ; �᫨ �ந��諮 ᮡ�⨥, ���஥ �� �� ��ࠡ��뢠��,
                  ; ���� �����頥��� � ��砫� 横��, ��� ⠪��� ����
                  ; �� ������! �.�. �᫨ ��� ������� ��� ����, �
                  ; ��祣� ���譮�� �� ������.

;******************************************************************************

  button:        ; ��ࠡ��稪 ������ ������ � ���� �ணࠬ��
    mov  eax,17  ; �㭪�� N17 - ������� �����䨪��� ����⮩ ������
    int  0x40

    ; ⥯��� � ॣ���� ah ᮤ�ন��� �����䨪���.

    shr  eax,8   ; ah -> al (ᤢ�� �� 8 ��� ��ࠢ�)

    dec  al       ; �����䨪���_������--;
    jnz  .noclose ; �᫨ १���� �।��饩 ������� ࠢ�� ���, ����뢠����
                  ; ���� - ��� �� ���� noclose

    or   eax,-1  ; ��室 �� �ணࠬ��
    int  0x40

  .noclose:
    ; �᫨ �� � ������, ����� �����䨪��� ������ �� �� ࠢ�� ���...
    ; ⥯��� � ��� � eax ᮤ�ন��� (����� 梥⭮� ������ - 1),
    ; �.� ��� 1, ��� 2, ... ,��� 5

    ; 㬥��訬 �� 1:
    dec  eax

    ; ��� �� ��� ������� ��������� � eax ������� ᫮�� �� ����� colors+eax*4
    ; ��� colors - ᬥ饭�� ��⪨ colors, ��᫥ ���ன ���� ��᫥����⥫쭮���
    ; 梥⮢, eax*4 - ����� 梥�, 㬭������ �� 4, �.�. �� ���� 梥� �㦭�
    ; ���� ����.
    mov  eax,[colors+eax*4]

    ; ⥯��� �� ��⠭���� 梥�, ᮤ�ঠ騩�� � ॣ���� eax ��� �᭮����:
    mov  [active_color],eax

    ; �� ���, ᮡ�⢥���, � ���, �� �� ��� �ॡ������� ;)
    ; ������ � ��砫� 横�� ��ࠡ�⪨ ᮡ�⨩
    jmp  still

;******************************************************************************

  mouse:          ; ��ࠡ��稪 ���
    mov  eax,37             ; ᭠砫� ����稬 ⥪�騥 ���न���� ���
    mov  ebx,1
    int  0x40

    mov  ebx,eax            ; �८�ࠧ㥬 ��
    shr  eax,16             ;   eax=x;
    and  ebx,0xffff         ;   ebx=y;

    cmp  ebx,22
    jb   save_canvas

    sub  eax,[workarea.cx]  ; x-=[workarea.cx]
    cmp  eax,0              ; �᫨ ���� ����� ������᪮� ������,
    jle  .not_pressed       ;   ��祣� �� ��㥬
    cmp  eax,[workarea.sx]  ; �᫨ ���� �ࠢ��...
    jae  .not_pressed

    sub  ebx,[workarea.cy]
    cmp  ebx,0              ; ...���...
    jle  .not_pressed
    cmp  ebx,[workarea.sy]  ; ...����...
    jae  .not_pressed

    ; ����� ������ ������?
    mov  eax,37
    mov  ebx,2
    int  0x40

    ; �᫨ ����� ������ (�.�. eax = 1), � ����� �����
    cmp  eax,1
    je   .leftbtn

  .not_pressed:
    ; ����� ������ �� �����, �������� ⥪�騥 ���न���� � �㤥� ����� ᮡ���
    mov  [mouse_pressed],0   ; ���� �� �����
    mov  eax,37              ; ����稬 ���न����
    mov  ebx,1
    int  0x40
    mov  ebx,eax
    shr  eax,16
    and  ebx,0xffff
    mov  [old_x],eax         ; �������� ��
    mov  [old_y],ebx
    jmp  still

  .leftbtn:
    ; ����� ������ �����, ���� �� �������!
    mov  [mouse_pressed],1

    ; ����稬 ���न���� ����� ��� (�⭮�⥫쭮 ����)
    mov  eax,37              ; �㭪�� 37 - ������� ���ﭨ� ���
    mov  ebx,1               ; ����㭪�� 1
    int  0x40

    ; ��।����� �� ⠪, �⮡� ��� �뫨 � ࠧ��� ॣ�����, �.�. eax � ebx
    mov  ebx,eax
    shr  eax,16
    and  ebx,0xffff

    ; �����⮢�� ��ࠬ���� ��� �㭪樨 �ᮢ���� �����
    mov  ecx,[old_x]     ; ��� ��砫� ����㧨� ���� ���न����
    mov  edx,[old_y]
    mov  [old_x],eax     ; ⥯��� ��࠭�� ⥪�騥 � ����
    mov  [old_y],ebx
    shl  ecx,16          ; � ���孥� ᫮�� ��砫�� (⥪�騥) ���न����
    shl  edx,16
    add  eax,ecx         ; � � ������ ᫮�� ������, �.�. ����
    add  ebx,edx

    mov  ecx,ebx             ; �����塞 ॣ����� ⠪, ��� ��� �㦭� 38 �㭪樨
    mov  ebx,eax
    mov  eax,38              ; ����� �㭪樨 � eax
    mov  edx,[active_color]  ; � edx 梥�
    int  0x40

;             - ���஡�� ���⠢��� ��㣨� ���祭�� (00090001)
    mov  edi,0x00010001      ; �⮡� ����� �� �뫠 ᫨誮� ⮭���,
    add  ebx,edi             ; ����㥬 �冷� �� 3!
    int  0x40
    add  ecx,edi
    int  0x40
    sub  ebx,edi
    int  0x40

    sub  ebx,edi             ; �� � �⮡� ᬮ�५��� ᮢᥬ ����,
    int  0x40                ; ����㥬 �� 5!
    sub  ecx,edi
    int  0x40
    sub  ecx,edi
    int  0x40
    add  ebx,edi
    int  0x40
    add  ebx,edi
    int  0x40

  jmp still

;******************************************************************************

save_canvas:
    mov  eax,[process.x_size]
    add  eax,[workarea.cx]
    mov  ebx,[process.y_size]
    add  ebx,[workarea.cy]

    jmp still

;******************************************************************************

;   *********************************************
;   *******  ����������� � ��������� ���� *******
;   *********************************************

draw_window:

    mov  eax,48                    ; ���������� ��������� �����
    mov  ebx,3
    mov  ecx,sc
    mov  edx,sizeof.system_colors
    int  0x40

    mov  eax,12      ; �㭪�� 12: ᮮ���� �� �� ���ᮢ�� ����
    mov  ebx,1       ; 1, ��稭��� �ᮢ���
    int  0x40

                                   ; ������� ����
    mov  eax,0                     ; �㭪�� 0 : ��।����� � ���ᮢ��� ����
    mov  ebx,100*65536+400         ; [x ����] *65536 + [x ࠧ���]
    mov  ecx,100*65536+300         ; [y ����] *65536 + [y ࠧ���]
    mov  edx,[sc.work]             ; 梥� ࠡ�祩 ������  RRGGBB,8->color gl
    or   edx,0x02000000
    mov  esi,[sc.grab]             ; 梥� ������ ��������� RRGGBB,8->color gl
    or   esi,0x80000000
    mov  edi,[sc.frame]            ; 梥� ࠬ��            RRGGBB
    int  0x40

    mov  eax,9                     ; ����稬 ���ଠ�� � ᥡ�
    mov  ebx,process
    mov  ecx,-1
    int  0x40

    mov  eax,[process.x_size]      ; ����ந� ࠧ��� ࠡ�祩 ������
    add  eax,-20                   ;   (� ࠧ��� ���� - 20)
    mov  [workarea.sx],eax         ;
    mov  eax,[process.y_size]      ;
    add  eax,-60                   ;   (� ࠧ��� - 60)
    mov  [workarea.sy],eax         ;

                                   ; ��������� ����
    mov  eax,4                     ; �㭪�� 4 : ������� � ���� ⥪��
    mov  ebx,8*65536+8             ; [x] *65536 + [y]
    mov  ecx,[sc.grab_text]        ; 梥�
    or   ecx,0x10000000            ; ����
    mov  edx,header                ; ���� ��ப�
    mov  esi,header_len            ; � �� �����
    int  0x40

                                   ; ������ �������� ����
    mov  eax,8                     ; �㭪�� 8 : ��।����� � ���ᮢ��� ������
;   mov  ebx,(300-19)*65536+12     ; [x ����] *65536 + [x ࠧ���]
    mov  ebx,[process.x_size]
    add  ebx,-19
    shl  ebx,16
    add  ebx,12
    mov  ecx,5*65536+12            ; [y ����] *65536 + [y ࠧ���]
    mov  edx,1                     ; �����䨪��� ������
    mov  esi,[sc.grab_button]      ; 梥� ������ RRGGBB
    int  0x40

    cmp  [process.y_size],80
    jb   .finish

    ; ᮧ��� ������ �롮� 梥�:
    mov  ebx,10*65536+10           ; ��砫쭠� x ���न��� � ࠧ���
    mov  ecx,27*65536+10           ; ��砫쭠� y ���न��� & size
 .new_button:
    inc  edx                       ; �����䨪���++;
    mov  esi,[btn_colors-8+edx*4]  ; 梥� ������
    int  0x40                      ; �⠢�� ������
    add  ebx,12*65536              ; ᫥����� ������ �ࠢ�� �� 12
    cmp  edx,9                     ; �ࠢ������ edx (�����䨪���) � 9
    jbe  .new_button               ; �᫨ ����� ��� ࠢ�� -> ��� ���� �����

    mov  eax,13                    ; ��⨬ "宫��" - ��������� �������
    mov  ebx,[workarea.cx]
    mov  ecx,[workarea.cy]
    shl  ebx,16
    shl  ecx,16
    add  ebx,[workarea.sx]
    add  ecx,[workarea.sy]
    mov  edx,0xffffff
    int  0x40

 .finish:
    mov  eax,12      ; ᮮ�頥� ��⥬� � �����襭�� ���ᮢ�� ����
    mov  ebx,2
    int  0x40

    ret

;******************************************************************************
; ��砫� ������ ���樠����஢����� ������
; �᫨ �� ��� �� �����, �� ����� "���樠����஢����", � ������:
; �� � �����, ����� ��᢮��� ��砫쭮� ���祭��
data

header:                  ; ��ப� ���������
   db  'PAINT v0.2 for MenuetOS'
header_len = $ - header  ; � �� �����

   mouse_pressed   db  0 ; �����뢠��, ����� �� �뫠 ���� � �।��騩 ������

; 梥� ������
btn_colors:
   dd 0xdddddd ; white
   dd 0x444444 ; black
   dd 0x00dd00 ; green
   dd 0x0000dd ; blue
   dd 0xdd0000 ; red
   dd 0xdd00dd ; magenta
   dd 0xdddd00 ; yellow
   dd 0x00dddd ; cyan
   dd 0x559955 ; warm green

; 梥� ���� (� ⮬ �� ���浪�, �� � 梥� ������)
colors:
   dd 0xffffff ; ����
   dd 0x000000 ; ���
   dd 0x00ff00 ; ������
   dd 0x0000ff ; ᨭ��
   dd 0xff0000 ; ����
   dd 0xff00ff ; ������
   dd 0xffff00 ; �����
   dd 0x00ffff ; ���㡮�
   dd 0x77bb77 ; ⥯�� ������

;******************************************************************************
; � ��� ��� ��稭����� ������� �����樠����஢����� ������, �.�.
; ����� ����� ���祭�� �� ��᢮���. � �⫨稥 �� ����., �� 㢥��稢��� ࠧ���
; 䠩��

udata

   active_color    dd  ?           ; ��⨢�� 梥�

   old_x           dd  ?           ; ���� ���न���� ���
   old_y           dd  ?

   workarea:                       ; ���न���� � ࠧ���� ������᪮� ������
       .cx     dd  ?               ;   c - ���������
       .cy     dd  ?
       .sx     dd  ?               ;   s - ࠧ����
       .sy     dd  ?

   sc          system_colors       ; ��⥬�� 梥�
   process     process_information ; ���ଠ�� � �����

   restflag    dd  ?
   canvas      rb  800*600*3

meos_app_end
