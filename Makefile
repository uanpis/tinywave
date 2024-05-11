AS = avr-as -mmcu=avrxmega3
LD = avr-ld -m avrxmega3 -A avrxmega3
PYTHON = python

main.out: main.o main.ld
	${LD} -T main.ld -o main.out main.o

main.o: main.s waveforms/sine.s
	${AS} -o main.o main.s

waveforms/sine.s: waveforms/wavegen.py
	${PYTHON} waveforms/wavegen.py sine

upload:
	avrdude 		\
	-p t404 		\
	-c serialupdi 		\
	-b 900000 		\
	-P /dev/ttyUSB0 	\
	-U flash:w:main.out:e

clean:
	@rm -f waveforms/*.s
	@rm -f *.o
	@rm -f *.out
