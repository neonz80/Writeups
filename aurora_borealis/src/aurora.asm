	ORG 0x8000
BUFFER = 0xb8e0
SINE = (BUFFER & 255) << 8
	
start:
bitmap: 
	db	0b00000000
	db	0b11111111
	db	0
	db	0b11000000
	db	0b00000011
	db	0
	dec	bc

	;; Generate rotated bitmap
	push	bc
	pop	hl
	
shift_loop:
	scf
shift_inner_loop:
	ld	a, (hl)
	inc	h
	rra
	ld	(hl), a
	dec	h
	inc	l
	jr	nz, shift_inner_loop
	inc	h
	jr	nz, shift_loop

	;; hl = 0
	;; c = 0
	;; Generate sine
	ld	d, high SINE
sine_loop:
	ld	e, c
	rrc	e
	sbc	a
	ld	b, a
	xor	h
	ld	(de), a
	;; only 1 add gives a range of approx -32 to 31
	add	hl, bc
	dec	c
	jr	nz, sine_loop

;;; 
;;; Clear screen
;;;
	ld	(iy+83), 0x44
	call	0x0daf

	;; a = 0
	out	(0xfe), a

main_loop:
	;;
	;; Clear buffer
	;;
	ld	hl, BUFFER
clear_loop:
	ld	(hl), 0
	inc	l
	jr	nz, clear_loop

	ld	d, 95
draw_loop:
	push	de
	ld	h, high SINE

	;; Calculates counter + 4*y and 7*y - 2*counter
	ld	a, d
	add	a					; a = 2y
	push	af
	add	a					; a = 4y
	add	e					; a = 4y + counter
	ld	l, a					
	ld	c, (hl)					; c = sin(4y + counter)
	sub	e					; a = 4y
	sub	e					; a = 4y - counter
	add	a					; a = 8y - 2*counter
	sub	d					; a = 7y - 2*counter
	ld	l, a
	ld	a, (hl)					; a = sin(7y - 2*counter)
	add	c					; a = sin(...) + sin(...)
	add	d					; a += y

	ld	d, high BUFFER				; 
	sub	d					; a -= 0xb8 (offset)
	ld	c, a					
	rrca						
	rrca
	rrca
	or	h
	ld	e, a
	ld	a, c
	and	7
	add	high bitmap
	ld	h, a
	ld	l, 0

	;; read mask bytes
	ld	b, (hl)					
	inc	l
	ld	c, (hl)
	inc	l
	inc	l

	;; first
	ld	a, (de)
	and	b
	or	(hl)
	inc	l
	ld	(de), a
	inc	e

	;; second
	ldi
	inc	c

	;; third
	ld	a, (de)
	and	c
	or	(hl)
	ld	(de), a

	;; copy buffer to screen
	pop	af
	
	;; l is always < 8
	ld	c, l
	call	0x22b0
	ex	de, hl
	ld	l, low BUFFER
	ld	bc, 32
	ldir

	pop	de
	dec	d
	jr	nz, draw_loop

	inc	e
	jr	main_loop
	
	
