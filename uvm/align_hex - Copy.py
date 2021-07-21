#!/usr/bin/python

import argparse

parser = argparse.ArgumentParser(description = 'Align hex file to memory addresses')
parser.add_argument('-i', '--input', help = 'Input hex file name', default = 'diag.hex')
parser.add_argument('-o', '--output', help = 'Output hex file name', default = 'diag.hex')
parser.add_argument('-s', '--start', help = 'Start address', default = 0x40000000, type = hex)
parser.add_argument('-n', '--increment', help = 'Increment value', default = 0x4, type = hex)
args = parser.parse_args()

with open(args.input,'r') as file:
    lines = file.readlines()

with open(args.output, 'w') as file:
    start = args.start
    for line in lines:
        line = "@" + hex(start)[2:] + " " + line
        start = start + args.increment
        file.write(line)
        print(line, end = "")
