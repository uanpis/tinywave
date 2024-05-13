	.file	"main"
	.include "header.s"

	.section .vect,	"ax"
	.org	0x00
rst_v:	rjmp	rst
	.org	0x10
ovf_v:	rjmp	ovf
	.org	0x2C
rxc_v:	rjmp	midi_rxc
	
	.text
ovf:	push	TMP1
	in	TMP1,	SREG

	inc	ZL
	sts	0x0A0B,	ONE	; clear OVF interrupt flag

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
	sts	0x0A0A,	ONE	; enable OVF interrupt
	sts	0x0A00, ONE	; enable TCA0, clk 20Mhz

	rcall	midi_init

	/* DEBUG */
	ldi	TMP1,	0x02	; set PB1 to output, debug LED
	sts	0x0421,	TMP1	;

	sei			; global interrupt enable


	ldi	ZL,	lo8(sine)
	ldi	ZH,	hi8(sine)
	ldi	DLYL,	0x00
	ldi	DLYH,	0xFF
loop:
	lpm	TMP1,	Z	; set pw
	sts	0x0A38,	TMP1	;
	sts	0x0A39,	ZERO	;
	rcall	midi_update
	rjmp	loop
