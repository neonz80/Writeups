        ORG 0xbf14
start:
        di

        ;; Load 0xbf17 into hl, using the next two opcodes as address
        db      0x21
loop:
        ;; Modify a and the carry flag
        rla
        cp      a

        ;; Write to memory
        inc     d
        res     7, d
        ld      (de), a
        inc     e
        
        djnz    loop

        inc     e
        jr      nz, loop

        ;; Modify the cp a instruction and jump to it, restarting the loop
        dec     (hl)
        jp      (hl)
