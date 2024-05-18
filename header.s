	.file "header"

	ZERO	= 2
	ONE	= 3

	/* UART RX fifo pointers*/
	W_PTR	= 5
	R_PTR	= 6

	/* periodic increment */
	INCL	= 7
	INCH	= 8
	/* fixed point 8+8bit pointer location */
	POSL	= 9
	POSH	= 10

	TMP1	= 16
	TMP2	= 17
	TMP3	= 18

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

