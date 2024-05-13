TARGET(elf32-avr)
OUTPUT_FORMAT(elf32-avr)

SECTIONS {
	.vect 0x0000 : { main.o(.vect) }	/* interrupt vector section */
	.text 0x0034 : { *(.text) }		/* code */
	.data : { *(.data) }		/* data */
}
