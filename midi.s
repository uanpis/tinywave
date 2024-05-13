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
	in	TMP2,	SREG

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
	cbi	FLAGS,	0	; set next byte flag to byte 0
	out	STATUS,	DATA	; set running status
	andi	DATA,	0xF0	; mask first four bits (ignore channel data)
	cpi	DATA,	0x80	; if DATA is "note off"
	breq	status_nof	; then go to noteoff
	cpi	DATA,	0x90	; else if DATA is "note on"
	breq	status_non	; then go to noteon
	rjmp	update_end	; else end
status_nof:
	sbi	FLAGS,	1	; set note off flag
	rjmp	update_end
status_non:
	sbi	FLAGS,	2	; set note on flag
	rjmp	update_end

databyte:
	sbic	FLAGS,	0	; if byte1 flag set
	rjmp	byte1		; then go to byte1
byte0:
	sbi	FLAGS,	0	; set next byte flag to byte 1
	sbic	FLAGS,	1	; if note off flag set
	rjmp	byte0_nof	; then go to byte0_nof
	sbic	FLAGS,	2	; else if note on flag set
	rjmp	byte0_non	; then go to byte0_non
	rjmp	update_end	; else end
byte0_nof:
	cbi	FLAGS,	1	; clear note off flag
	cbi	0x05,	1	; turn off debug LED
	rjmp	update_end
byte0_non:
	cbi	FLAGS,	2	; clear note on flag
	sbi	0x05,	1	; turn on debug LED
	out	NOTE,	DATA	; write to NOTE
	rjmp	update_end

byte1:
	rjmp	byte1_end
byte1_end:
	out	FLAGS,	ZERO	; clear all flags
	rjmp	update_end

update_end:
	pop	TMP1
	pop	XH
	pop	XL
	ret
