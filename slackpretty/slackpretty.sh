#!/usr/bin/env bash

dpkg --get-selections | grep "^xclip[[:space:]]" > /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Package 'xclip' is not installed"
    echo "Install with 'sudo apt-get install xclip'"
    exit 1
fi


xclip -o -selection clipboard | perl -0 -lpe '''
	s/^([0-9:]{5})\n/\n[$1] /gm; # Timestamp matching
        s/(  (?:[0-9:]{5}|[Tt]oday at [0-9:]{5}|[0-9]+ (?:minutes?|hours?|days?|months?) ago)\n)?(?:\n)?(@[A-Za-z0-9 ]+)\n/$1$2/gm; # At-d users, careful if the first word is an at-d user
	s/(?:^\n\n|^\n|)(?:[A-Z]+\n|)([A-Za-z0-9 ]+)\n(?:APP|WORKFLOW|:[a-zA-Z0-9]+:|)  ?((?:Today at |Yesterday at |[0-9]+ [A-Za-z]{3} at |)[0-9:]{5}|(?:< |)[0-9]+ (?:minutes?|hours?|days?|months?) ago)\n/[$2] $1: /gm; # Timestamps and names
	s/(?:^\n\n|^\n|)([0-9]+ repl(?:y|ies))\n(?:Last reply |)([Tt]oday at [0-9:]{5}|[0-9]+ (?:minutes?|hours?|days?|months?) ago)(?:View thread|)(?:\n\n\n\n\n$|$)/($2, $1)/gm; # Thread toggle
	s/(?:^\n\n|^\n)([0-9]+ repl(?:y|ies))\n/($1)\n/gm; # In thread replie counter
	s/:\n([0-9]+)\n/: ($1)\n/gm; # Forgot what this is for
	s/^\n\n\n+//gm; # Random Newlines
	''' | xclip -i -selection clipboard
