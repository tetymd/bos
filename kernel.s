CYLS            equ     0x0ff0
LEDS            equ     0x0ff1
VMODE           equ     0x0ff2
SCRNX           equ     0x0ff4
SCRNY           equ     0x0ff6
VRAM            equ     0x0ff8

                org     0xc200

                mov     al, 0x13
                mov     ah, 0x00
                int     0x10

                mov     BYTE [VMODE], 8
                mov     WORD [SCRNX], 320
                mov     WORD [SCRNY], 200
                mov     DWORD [VRAM], 0x000a0000

                mov     ah, 0x02
                int     0x16
                mov     [LEDS], al

fin:
                hlt
                jmp     fin

return:
                ret

msg:
                db      "hello!"
                db      0
