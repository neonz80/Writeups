	ORG 0x8a00
start:
	out	(0xfe), a
	ld	d, 0x3d
main_loop:

column_loop:
	ld	h, 0x5a

attrib_loop:
	ld	a, (de)
	inc	e
	
	sub	l
	and	e
	and	b
	rra
	ld	(hl), a
	dec	h
	bit	3, h
	jr	nz, attrib_loop

	
pixel_loop:
	ld	a, (de)
	inc	e
	ld	(hl), a
	dec	h
	bit	6, h
	jr	nz, pixel_loop
	
	inc	l
	jr	nz, column_loop
	inc	e
	jr	main_loop
	
	
