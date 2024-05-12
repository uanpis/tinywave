
# generates waveform data assembly code

import argparse
import math as m

prologue = "\
\t.file\t\"$WAVE\"\n\
\t.data\n\
\t.balign\t0x0100\n\
$WAVE:\
"

def main():
    parser  = argparse.ArgumentParser()
    parser.add_argument("wave", type=str)
    args    = parser.parse_args()
    if args.wave == "sine":
        sinegen()
    elif args.wave == "saw":
        sawgen()
    return

def clamp(num, minimum, maximum):
    return min(maximum, max(minimum, num))

def sinegen():
    file = open("sine.s","w")
    file.write(prologue.replace("$WAVE", "sine"))
    for i in range(256):
        if i % 8 == 0:
            file.write("\n")
            file.write("\t.byte ")
        else:
            file.write(", ")
        result = int(128 + 128 * (m.sin(m.pi*i/128)))
        result = clamp(result, 0, 0xFF)
        file.write(hex(result))
    file.write("\n")
    return

def sawgen():
    file = open("saw.s","w")
    file.write(prologue.replace("$WAVE", "saw"))
    for i in range(256):
        if i % 8 == 0:
            file.write("\n")
            file.write("\t.byte ")
        else:
            file.write(", ")
        file.write(hex(i))
    file.write("\n")
    return


if __name__ == "__main__":
    main()
