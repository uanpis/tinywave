ZERO = 0x01
TMP1 = 0x10
TMP2 = 0x11
WL = 0x18
WH = 0x19
XL = 0x1A
XH = 0x1B
YL = 0x1C
YH = 0x1D
ZL = 0x1E
ZH = 0x1F

CCP = 0x34
SPL = 0x3D
SPH = 0x3E
SREG = 0x3F

	.file	"main"
	.section .vect,	"ax"
	.org	0x00
rst_v:	rjmp	reset
	
	.text
reset:
	; clear ZERO reg
	eor	ZERO,	ZERO

	; reset stack pointer to 0x3FFF
	ldi	TMP1,	0xFF
	ldi	TMP2,	0x3F
	out	SPL,	TMP1
	out	SPH,	TMP2

	; set clock to 20Mhz
	ldi	TMP1,	0xD8	;
	out	CCP,	TMP1	; unlock protected registers
	sts	0x0061,	ZERO_R	; disable clock prescaler

loop:	rjmp	loop
