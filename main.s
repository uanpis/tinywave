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

	inc	ZL		; increment Z pointer
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
	sts	0x0A4D,	ZERO	;
	sts	0x0A45,	ONE	; enable interrupt
	sts	0x0A40,	ONE	; enable TCB0, clk 20Mhz

	rcall	midi_init

	/* DEBUG */
	ldi	TMP1,	0x02	; set PB1 to output, debug LED
	sts	0x0421,	TMP1	;

	sei			; global interrupt enable


	ldi	ZL,	lo8(sine)
	ldi	ZH,	hi8(sine)
loop:
	rcall	midi_update
	rcall	update_note
	rjmp	loop

update_note:
	in	TMP1,	NOTE
	rcall	mod12
	ldi	YH,	hi8(notes)
	subi	YH,	0x80
	ldi	YL,	lo8(notes)
	subi	YL,	0xEA
	sub	YL,	TMP1
	sub	YL,	TMP1
	ldd	TMP1,	Y+1
	sts	0x0A4C,	TMP1
	sts	0x0A4D,	ZERO
	ret


mod12:
	/* TMP1 = TMP1 % 12 */
	subi	TMP1,	0x0C	; while TMP > 0, TMP -= 12
	brpl	mod12		;
	subi	TMP1,	0xF4	; TMP += 12
	ret
