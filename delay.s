	.file "utils"
	.include "header.s"

	.section .text
	.global	delay
delay:	push	DLYL
	push	DLYH
d1:	sbiw	DLYL,	1
	brne	d1
	pop	DLYH
	pop	DLYL
	ret
