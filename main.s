	.file	"main"
	.section .vect,	"ax"
	.org	0x00
rst_v:	rjmp	reset
	
	.text
reset:
loop:	rjmp	loop
