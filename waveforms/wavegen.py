
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
    return

def clamp(num, minimum, maximum):
    return min(maximum, max(minimum, num))

def sinegen():
    file = open("sine.s","w")
    file.write(prologue.replace("$WAVE", "sine"))
    for i in range(16):
        file.write("\t.byte ")
        for j in range(16):
            n = 16*i + j
            result = int(128 + 128 * (m.sin(m.pi*n/128)))
            result = clamp(result, 0, 0xFF)
            file.write(hex(result))
            if j < 15:
                file.write(", ")
        file.write("\n")
    return

if __name__ == "__main__":
    main()