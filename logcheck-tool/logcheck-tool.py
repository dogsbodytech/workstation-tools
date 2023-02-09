#!/usr/bin/env python3 

import re
#import pyperclip

try:
    import pyperclip
except ModuleNotFoundError:
    print("\nModule 'pyperclip' is not installed. Please install with 'pip3 install pyperclip'\n")

text = pyperclip.paste()
lines = text.splitlines()
new_lines = []
for line in lines:
    line = re.sub(r"/", r"\/", line)
    line = re.sub(r"\[(\d+)\]", r"[.*]", line)
    split_line = line.split(' ', 4)[-1]
    split_line = re.sub(r"(\[|\]|\(|\)|\+)", r"\\\1", split_line)
    split_line = re.sub(r"(?<!\*)\.(?!\*)", r"\\.", split_line)
    new_lines.append(split_line)
pyperclip.copy("\n".join(new_lines))
