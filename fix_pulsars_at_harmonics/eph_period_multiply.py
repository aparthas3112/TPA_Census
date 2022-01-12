#!/usr/bin/env python
import sys


fn=sys.argv[1]
n=float(sys.argv[2])

with open(fn) as f:
    for line in f:
        e=line.split()
        if len(e) > 1:
            if e[0] in ["F0","F1","F2","F3","F4"]:
                new = float(e[1])/n
                e[1] = "{:.18g}".format(new)
                line = " ".join(e) + "\n"
        print(line,end="")
    print("IPERHARM {:d}".format(int(n)))


