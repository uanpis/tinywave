	.file	"main"
	.include "header.s"

	.section .vect,	"ax"
	.org	0x00
rst_v:	rjmp	rst
	.org	0x1A
tcb_v:	rjmp	tcb_int
	.org	0x2C
rxc_v:	rjmp	midi_rxc
	
	.text

tcb_int:
	/* TCB0 interrupt service routine */
	push	TMP1
	in	TMP1,	SREG
	push	TMP2

	add	POSL,	INCL
	adc	POSH,	INCH

	mov	ZL,	POSH	; increment Z pointer
	lpm	TMP2,	Z	; set pw
	sts	0x0A38,	TMP2	;
	sts	0x0A39,	ZERO	;
	sts	0x0A46,	ONE	; clear interrupt flag

	pop	TMP2
	out	SREG,	TMP1
	pop	TMP1
	reti

rst:	cli			; global interrupt disable
	clr	ZERO		; clear ZERO reg
	clr	ONE		; set ONE reg
	inc	ONE

	/* reset stack pointer to 0x3FFF */
	ldi	TMP1,	0xFF
	ldi	TMP2,	0x3F
	out	SPL,	TMP1
	out	SPH,	TMP2

	/* set clock to 20Mhz */
	ldi	TMP1,	0xD8	;
	out	CCP,	TMP1	; unlock protected registers
	sts	0x61,	ZERO	; disable clock prescaler

	/* init TCA0 as pwm output on PB0 */
	sts	0x0421,	ONE	; set PB0 to output
	ldi	TMP1,	0xFF	; set period to 255
	sts	0x0A26,	TMP1	;
	sts	0x0A27,	ZERO	;
	ldi	TMP1,	0x7F	; set pw to 127
	sts	0x0A28,	TMP1	;
	sts	0x0A29,	ZERO	;
	ldi	TMP1,	0x13	; enable CMP0, set WGMODE to SINGLESLOPE
	sts	0x0A01,	TMP1	;
	; sts	0x0A0A,	ONE	; enable OVF interrupt */
	sts	0x0A00, ONE	; enable TCA0, clk 20Mhz

	/* init TCB0 on periodic interrupt mode */
	ldi	TMP1,	0xFF
	sts	0x0A4C,	TMP1	; set period to 255
	sts	0x0A4D,	ZERO
	sts	0x0A45,	ONE	; enable interrupt
	sts	0x0A40,	ONE	; enable TCB0, clk 20Mhz

	rcall	midi_init

	/* DEBUG */
	ldi	TMP1,	0x02	; set PB1 to output, debug LED
	sts	0x0421,	TMP1	;

	sei			; global interrupt enable


	ldi	ZL,	lo8(sine)
	ldi	ZH,	hi8(sine)
	ldi	TMP1,	0x60	; set note to middle C
	out	NOTE,	TMP1
loop:
	rcall	midi_update
	rcall	update_note
	rjmp	loop

update_note:
	in	TMP1,	NOTE
	rcall	div12		; TMP1 /= 12 ; TMP2 = TMP1 % 12

	dec	TMP2
	ldi	YH,	hi8(notes)
	subi	YH,	0x80
	ldi	YL,	lo8(notes)
	add	YL,	TMP2
	add	YL,	TMP2
	ld	WL,	Y
	ldd	WH,	Y+1

	ldi	TMP3,	0x0C
	sub	TMP3,	TMP1
l1:	
	dec	TMP3
	breq	e1
	lsr	WH
	ror	WL
	rjmp	l1
e1:
	mov	INCL,	WL
	mov	INCH,	WH
	ret


div12:
	/* TMP1 /= 12; TMP2 = TMP1 % 12 */
	inc	TMP1
	mov	TMP2,	TMP1	; save dividend to tmp2
	ldi	TMP3,	0xAA
	mul	TMP1,	TMP3	; r1, r0 = (TMP1+1) * 0xAA
	mov	TMP1,	r1	; get high byte
	lsr	TMP1		; TMP1 >>= 3
	lsr	TMP1		;
	lsr	TMP1		;
	ldi	TMP3,	0x0C	; TMP2 = TMP2 - 12*TMP1 -> remainder
	mul	TMP3,	TMP1	;
	sub	TMP2,	r0	; 
	ret
