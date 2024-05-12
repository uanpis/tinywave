AS = avr-as -mmcu=avrxmega3
LD = avr-ld -m avrxmega3 -A avrxmega3
PYTHON = python

main.out: main.ld main.o waveforms/sine.o waveforms/saw.o
	${LD} -T main.ld -o main.out \
		main.o \
		waveforms/sine.o \
		waveforms/saw.o

main.o: main.s
	${AS} -o main.o main.s

waveforms/sine.o: waveforms/sine.s
	${AS} -o waveforms/sine.o waveforms/sine.s
waveforms/sine.s: waveforms/wavegen.py
	cd waveforms &&\
	${PYTHON} wavegen.py sine

waveforms/saw.o: waveforms/saw.s
	${AS} -o waveforms/saw.o waveforms/saw.s
waveforms/saw.s: waveforms/wavegen.py
	cd waveforms &&\
	${PYTHON} wavegen.py saw
upload:
	avrdude 		\
	-p t404 		\
	-c serialupdi 		\
	-b 900000 		\
	-P /dev/ttyUSB0 	\
	-U flash:w:main.out:e

clean:
	@rm -f waveforms/*.s
	@rm -f waveforms/*.o
	@rm -f *.o
	@rm -f *.out
