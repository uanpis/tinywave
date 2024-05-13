	.file "header"

	ZERO	= 0x01
	ONE	= 0x02

	W_PTR	= 5
	R_PTR	= 6

	TMP1	= 16
	TMP2	= 17

	RS_REG	= 18

	DATA	= 19

	DLYL	= 24
	DLYH	= 25

	;WL	= 0x18
	;WH	= 0x19

	XL	= r26
	XH	= r27
	YL	= r28
	YH	= r29
	ZL	= r30
	ZH	= r31

	STATUS	= 0x1C
	FLAGS	= 0x1D
	; bit 0: rxc
	; bit 1: note on/off
	NOTE	= 0x1E

	CCP	= 0x34
	SPL	= 0x3D
	SPH	= 0x3E
	SREG	= 0x3F

