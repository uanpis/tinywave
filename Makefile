AS = avr-as -mmcu=avrxmega3
LD = avr-ld -m avrxmega3 -A avrxmega3
PYTHON = python

objects = main.o \
		  midi.o \
		  waveforms/sine.o \
		  waveforms/saw.o

main.out: main.ld $(objects)
	${LD} -T main.ld -o main.out $(objects)

$(filter %.o, $(objects)): %.o: %.s
	${AS} -o $@ $<

waveforms/%.s: waveforms/wavegen.py
	cd waveforms &&\
	${PYTHON} wavegen.py $*

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
