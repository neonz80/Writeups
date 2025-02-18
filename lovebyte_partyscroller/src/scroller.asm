	ORG 0xf7c0
start:
	call	0xdaf

	ld	de, text
print_loop:
	ld	a, (de)
	rst	0x10
	inc	e
	jr	nz, print_loop

	inc	d
expand_loop_3:
	ld	l, e
expand_loop_2:
	ld	b, 8
expand_loop_1:
	sla	(hl)
	sbc	a
	ld	(de), a
	dec	e
	djnz	expand_loop_1
	inc	hl
	jr	nz, expand_loop_2
	inc	h
	inc	d
	jr	nz, expand_loop_3
	
	ld	d, 0x59
main_loop:
	halt
	halt
	ld	h, 0xf8
line_loop:
	ld	b, 32
	ld	l, c
column_loop:
	ld	a, (hl)
	dec	l
	ld	(de), a
	inc	e
	djnz	column_loop
	inc	h
	jr	nz, line_loop
	dec	c
	jr	main_loop

text:
	db	"FUN"
	db	0xc6 ; " AND "
	db	0xaf ; "CODE "
	db	0xac ; "AT "
	db	"LOVEBYTE"
