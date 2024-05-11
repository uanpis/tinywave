import argparse
import math as m

prologue = "\
\t.data\n\
\t.align\t0x0100\n\
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
    file.write("\t.file\t\"sine\"\n")
    file.write(prologue)
    for i in range(16):
        file.write("\t.byte ")
        for j in range(16):
            n = 16*i + j
            result = int(128 + 128 * (m.sin(m.pi*n/128)))
            result = clamp(result, 0, 256)
            file.write(hex(result))
            if j < 15:
                file.write(", ")
        file.write("\n")
    return

if __name__ == "__main__":
    main()
