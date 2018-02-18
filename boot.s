;-------------------------------------------------------
;       Boot loader for BOS
;-------------------------------------------------------

[BITS 16]

CYLS            equ     10
                org     0x7c00

                jmp     real_start

BS_JmpBoot      db      0x90
BS_OEMName      db      "BOS     "
BPB_BytsPerSec  dw      0x0200
BPB_SecPerClus  db      0x01
BPB_RsvdSecCnt  dw      0x0001
BPB_NumFATs     db      0x02
BPB_RootEntCnt  dw      0x00e0
BPB_TotSec16    dw      0x0b40
BPB_Media       db      0xf0
BPB_FATSz16     dw      0x0009
BPB_SecPerTrk   dw      0x0012
BPB_NumHeads    dw      0x0002
BPB_HiddSec     dd      0x00000000
BPB_TotSec32    dd      0x00000000

BS_DrvNum       db      0x00
BS_Reserved1    db      0x00
BS_BootSig      db      0x29
BS_VolID        dd      0x20180218
BS_VolLab       db      "BOS        "
BS_FilSysType   db      "FAT12   "

;-------------------------------------------------------
;      ENTRY
;-------------------------------------------------------

real_start:
                xor     ax, ax
                mov     ss, ax
                mov     ds, ax
                mov     es, ax

                mov     si, msg_boot
                call    print

load_start:
                mov     ax, 0x0820
                mov     es, ax
                mov     ch, 0
                mov     dh, 0
                mov     cl, 2
readloop:
                mov     si, 0

retry:
                mov     ah, 0x02
                mov     al, 1
                mov     bx, 0
                mov     dl, 0x00
                int     0x13
                jnc     load_next
                add     si, 1
                cmp     si, 5
                jae     error
                mov     ah, 0x00
                mov     dl, 0x00
                int     0x13
                jmp     retry

load_next:
                mov     ax, es
                add     ax, 0x0020
                mov     es, ax
                add     cl, 1
                cmp     cl, 18
                jbe     readloop
                mov     cl, 1
                add     dh, 1
                cmp     dh, 2
                jb      readloop
                mov     dh, 0
                add     ch, 1
                cmp     ch, CYLS
                jb      readloop

load_end:
                mov     si, msg_load
                call    print
                jmp     os_start

print:
                mov     al, [si]
                add     si, 1
                cmp     al, 0
                je      return
                mov     ah, 0x0e
                int     0x10
                jmp     print

error:
                mov     si, msg_error
                call    print
                jmp     end

os_start:
                mov     si, msg_end
                call    print
                jmp     0xc200

end:
                hlt
                jmp     end

return:
                ret

;-------------------------------------------------------
;      DATA
;-------------------------------------------------------

msg_boot:
                db      "Booting now..."
                db      0x0d, 0x0a
                db      0

msg_load:
                db      "Loading success"
                db      0x0d, 0x0a
                db      0
msg_error:
                db      "Error: Loading"
                db      0x0d, 0x0a
                db      0

msg_end:
                db      "Finish the booting"
                db      0x0d, 0x0a
                db      0

                times   510 -($ - $$) db 0
MBR_sig         dw      0xaa55

;-------------------------------------------------------
;       FAT12
;-------------------------------------------------------

                db      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
                resb    4600
                db      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
                resb    1469432

