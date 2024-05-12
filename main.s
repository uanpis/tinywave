	.file	"main"

	ZERO	= 0x01
	ONE	= 0x02
	TMP1	= 0x10
	TMP2	= 0x11
	WL	= 0x18
	WH	= 0x19
	XL	= 0x1A
	XH	= 0x1B
	YL	= 0x1C
	YH	= 0x1D
	ZL	= 0x1E
	ZH	= 0x1F

	CCP	= 0x34
	SPL	= 0x3D
	SPH	= 0x3E
	SREG	= 0x3F

	.section .vect,	"ax"
	.org	0x00
rst_v:	rjmp	reset
	.org	0x10
ovf_v:	rjmp	ovf
	
	.text
ovf:
	inc	ZL
	sts	0x0A0B,	ONE	; clear OVF interrupt flag
	reti

reset:
	cli			; global interrupt disable
	clr	ZERO		; clear ZERO reg
	clr	ONE		; set ONE reg
	inc	ONE

	; reset stack pointer to 0x3FFF
	ldi	TMP1,	0xFF
	ldi	TMP2,	0x3F
	out	SPL,	TMP1
	out	SPH,	TMP2

	; set clock to 20Mhz
	ldi	TMP1,	0xD8	;
	out	CCP,	TMP1	; unlock protected registers
	sts	0x61,	ZERO	; disable clock prescaler

	; init TCA0 as pwm output on PB0
	sts	0x0420,	ONE	; set PB0 to output
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

	sei			; global interrupt enable

	; DEBUG
	ldi	TMP1,	0x02	; set PB1 to output, debug LED
	sts	0x0421,	TMP1	;

	ldi	ZL,	lo8(sine)
	ldi	ZH,	hi8(sine)
loop:
	lpm	TMP1,	Z	; set pw
	sts	0x0A38,	TMP1	;
	sts	0x0A39,	ZERO	;
	rjmp	loop
