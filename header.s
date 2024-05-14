	.file "header"

	ZERO	= 0x01
	ONE	= 0x02

	/* UART RX fifo pointers*/
	W_PTR	= 5
	R_PTR	= 6

	TMP1	= 16
	TMP2	= 17

	DATA	= 19

	WL	= 0x18
	WH	= 0x19

	XL	= r26
	XH	= r27
	YL	= r28
	YH	= r29
	ZL	= r30
	ZH	= r31

	STATUS	= 0x1C
	FLAGS	= 0x1D
	; bit 0: clear = byte0, set = byte1
	; bit 1: note off
	; bit 2: note on
	NOTE	= 0x1E

	CCP	= 0x34
	SPL	= 0x3D
	SPH	= 0x3E
	SREG	= 0x3F

