	.file "midi"
	.include "header.s"

	.section .text

	.global midi_init
midi_init:
	/* initialize UART */
	ldi	TMP1,	0x0A	; set baud rate to 31250:
	sts	0x0809,	TMP1	; BAUD = (16 * 20,000,000) / (4 * 31,250)
	sts	0x0808,	ZERO	;      = 2,560 = 0x0A00
	ldi	TMP1,	0x80	;
	sts	0x0805,	TMP1	; enable recieve complete interrupt
	sts	0x0806,	TMP1	; enable reciever
	ret


	.global midi_rxc
midi_rxc:	
	/* recieve complete interrupt service routine */
	push	XL
	push	XH
	push	TMP1
	push	TMP2
	in	TMP2	SREG

	inc	W_PTR		; increment write pointer,
	ldi	TMP1,	0x0F	; modulo 16
	and	W_PTR,	TMP1	;
	ldi	XH,	0x3F	; copy to X reg
	mov	XL,	W_PTR	;
	lds	TMP1,	0x0800	; read rx & clear intflag
	st	X,	TMP1	; store result in pointer location

	out	SREG,	TMP2
	pop	TMP2
	pop	TMP1
	pop	XH
	pop	XL
	reti

	
	.global midi_update
midi_update:	
	push	XL
	push	XH
	push	TMP1
	cp	R_PTR,	W_PTR
	breq	update_end
newbyte:
	inc	R_PTR		; increment read pointer,
	ldi	TMP1,	0x0F	; modulo 16
	and	R_PTR,	TMP1	;
	ldi	XH,	0x3F	; copy to X reg
	mov	XL,	R_PTR	;
	ld	DATA,	X	; load pointed value to DATA
	push	DATA
	andi	DATA,	0x80	; check DATA bit 7
	pop	DATA
	breq	databyte	; if not set, go to databyte. else statusbyte
statusbyte:			
	out	STATUS,	DATA	; set running status
	andi	DATA,	0xF0	; mask first four bits
	cpi	DATA,	0x80	; compare to "note off"
	breq	noteoff		; if equal, go to noteoff
	cpi	DATA,	0x90	; compare to "note on"
	breq	noteon		; if equal, go to noteon
	rjmp	update_end
noteoff:
	ldi	TMP1,	0x02	; turn off debug LED
	sts	0x0426,	TMP1	;
	rjmp	update_end
noteon:
	ldi	TMP1,	0x02	; turn on debug LED
	sts	0x0425,	TMP1	;
	rjmp	update_end
databyte:
	rjmp	update_end	; else, end
update_end:
	pop	TMP1
	pop	XH
	pop	XL
	ret
