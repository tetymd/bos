[BITS 16]
;ビデオモード設定
set_vmode:
                mov     ax, 0x00
                mov     al, 0x03
                int     0x10

;GDT設定
_setup_gdt:
                cli
                lgdt    [gdt_toc]

;A20バスの有効化
enable_A20:
                cli

                call    A20wait
                mov     al, 0xad
                out     0x64, al

                call    A20wait
                mov     al, 0xd0
                out     0x64, al

                call    A20wait2
                in      al, 0x60
                push    eax

                call    A20wait
                mov     al, 0xd1
                out     0x64,al

                call    A20wait
                pop     eax
                or      al, 0x2
                out     0x60, al

                call    A20wait
                mov     al, 0xae
                out     0x64, al

                call    A20wait
                jmp     change_pmode

A20wait:
                in      al, 0x64
                test    al, 0x2
                jnz     A20wait
                ret

A20wait2:
                in      al, 0x64
                test    al, 0x1
                jz      A20wait2
                ret

;プロテクトモードに移行
change_pmode:
                cli
                mov     eax, cr0
                or      eax, 0x01
                mov     cr0, eax
                jmp    reset_pipe
reset_pipe:
                ;ここからの挙動がおかしい
                jmp     0x80:pmode_start

[BITS 32]
pmode_start:
                mov     ax, 0x10
                mov     ss, ax
                mov     es, ax
                mov     ds, ax

                mov     esp, 0x1000
                jmp     fin

gdt_toc:
                dw      8*3
                dd      _gdt

_gdt:
                ;Null descriptor
                dw      0x0000
                dw      0x0000
                dw      0x0000
                dw      0x0000

                ;Code descriptor
                db      0xff
                db      0xff
                dw      0x0000
                db      0x00
                db      0x98
                db      0xdf
                db      0

                ;Data descriptor
                db      0xff
                db      0xff
                dw      0x0000
                db      0x00
                db      0x92
                db      0xdf
                db      0

fin:
