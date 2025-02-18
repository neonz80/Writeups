;;;
;;; Channel 36
;;;
;;; A 16 byte intro for the ZX Spectrum released at Lovebyte 2025
;;;

        ;; The entrypoint must be <0x8000
        ;; The low byte of the entrypoint can be anything, but different values
        ;; give different results.
        ORG 0x708c
start:
        ;; Initial register values:
        ;;   bc = Start address (0x708c)
        ;;   a  = Low byte of start address (0x8c)
        ;;   hl = 0x2d2b
loop:
        ;; Write a to (bc) and increment bc while keeping bc between 0x4000 and
        ;; 0x5fff as long as the start value of bc is between 0x4000 and 0x7fff.
        res     5, b
        ld      (bc), a
        inc     bc

        ;; Rotate a and invert the carry flag. 
        rla
        ccf

        ;; Loop until l is 0
        dec     l
        jr      nz, loop

        ;; Set c to a to get a bit more noisy look
        ld      c, a

        ;; Loop until h is 0
        dec     h
        jr      nz, loop

        ;; This transforms a and the carry flag to a new value, changing the
        ;; look of the pattern on the screen.
        daa     
        jr      loop
        
        
