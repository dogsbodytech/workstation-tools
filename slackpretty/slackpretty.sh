#!/usr/bin/env bash

dpkg --get-selections | grep "^xclip[[:space:]]" > /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Package 'xclip' is not installed"
    echo "Install with 'sudo apt-get install xclip'"
    exit 1
fi

if [ "$1" == "highlighted" ]; then
	xclip -o -selection primary | perl -0 -lpe's|(?:\n\n)?(.*) ?(\n?\[\d?\d:\d\d(?: [AP]M)?\])\s+|$2 $1: |gm' | xclip -i -selection primary
else
	xclip -o -selection clipboard | grep -v '^$' | perl -0 -lpe's|(.*) (\[\d?\d:\d\d(?: [AP]M)?\])\s+|$2 $1: |gm' | xclip -i -selection clipboard
fi

