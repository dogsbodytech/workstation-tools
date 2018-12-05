#!/bin/bash
###############################
# Markdown reader script
# Usage : $0 file-to-read
################################
######## To set up Alias
# Alias command to link shared script to command `md`
# alias md="bash $HOME/ownCloud/All\ Staff/Tools\ \&\ Scripts/Markdown.sh"
##########

#############
# Recent changes
# Added syntax help
# 
########################
# Known Bugs
# Sed regex breaks if any character in (capture group) is in the string. (Cannot fix greedy regex in SED) > Future enhancement
#
# Future enhancement 
# re-write with modern regex (python)
########################

# If no input then exit a quick help
if [ -z "$1" ]; then
  echo "No file input given.  Outputting basic syntax..."
  echo ""
  echo "** Text **	Bold"
  echo "~~ Text ~~	Strikethrough"
  echo "__ Text __	Underline"
  echo "?? Text ??	Reverse"
  echo "(( Text ))	Dim"
  echo ";; Text ;;	Italics"
  echo ""
  exit 1
fi

# Check it is a valid file
if ! [ -r "$1" ] || ! [[ $(file -L "$1") = *'text' ]]; then
  echo "Error: Invalid file $1"
  exit 1
fi

# Duplicate file so that I can edit it 
TMPFILE=`mktemp "/tmp/MarkDownXXXXX"`

# Loops through the file adding in newlines (as sed doesn't read them in) making the file only 1 line for the rest of the program.
# For more information http://stackoverflow.com/questions/1251999/sed-how-can-i-replace-a-newline-n
sed -r ':a;N;$!ba;s/\n/\$\$\$\$/g' "$1" > $TMPFILE

# Replace markdown with Terminal Codes
# Text formatting
sed -i -r 's/\*\*([^\*\*]*)\*\*/\[1m\1\[21m/g' $TMPFILE # Bold
sed -i -r 's/\~\~([^\~\~]*)\~\~/\[9m\1\[29m/g' $TMPFILE # Strikethrough
sed -i -r 's/\_\_([^\_\_]*)\_\_/\[4m\1\[24m/g' $TMPFILE # Underline
sed -i -r 's/\?\?([^\?\?]*)\?\?/\[7m\1\[27m/g' $TMPFILE # Reverse (FG & BG colours)
sed -i -r 's/\(\(([^\(\)]*)\)\)/\[2m\1\[22m/g' $TMPFILE # Dim
sed -i -r 's/\;\;([^\;\;]*)\;\;/\[3m\1\[23m/g' $TMPFILE # Italics

# Not working but not practical
#sed -i -r 's/wibble([^wibble]*)wibble/\[5m\1\[25m/g' $TMPFILE # Blink
#sed -i -r 's/wibble([^wibble]*)wibble/\[8m\1\[28m/g' $TMPFILE # Invisible


####### Slashes don't be stupid what about website urls
# Foreground Colour
#sed -i -r 's/\\\\0([^\\\\]*)\\\\0/\[30m\1\[39m/g' $TMPFILE # Black
#sed -i -r 's/\\\\1([^\\\\]*)\\\\1/\[31m\1\[39m/g' $TMPFILE # Red
#sed -i -r 's/\\\\2([^\\\\]*)\\\\2/\[32m\1\[39m/g' $TMPFILE # Green?
#sed -i -r 's/\\\\3([^\\\\]*)\\\\3/\[33m\1\[39m/g' $TMPFILE # Yellow?
#sed -i -r 's/\\\\4([^\\\\]*)\\\\4/\[34m\1\[39m/g' $TMPFILE # Blue?
#sed -i -r 's/\\\\5([^\\\\]*)\\\\5/\[35m\1\[39m/g' $TMPFILE # Magenta?
#sed -i -r 's/\\\\6([^\\\\]*)\\\\6/\[36m\1\[39m/g' $TMPFILE # Cyan?
#sed -i -r 's/\\\\7([^\\\\]*)\\\\7/\[37m\1\[39m/g' $TMPFILE # White?

#sed -i -r 's/\\\\([^\\\\]*)\\\\/\[38m\1\[39m/g' $TMPFILE # Default

# Background Colour
#sed -i -r 's/\/\/0([^\/\/]*)\/\/0/\[40m\1\[49m/g' $TMPFILE # Black
#sed -i -r 's/\/\/1([^\/\/]*)\/\/1/\[41m\1\[49m/g' $TMPFILE # Red
#sed -i -r 's/\/\/2([^\/\/]*)\/\/2/\[42m\1\[49m/g' $TMPFILE # Green?
#sed -i -r 's/\/\/3([^\/\/]*)\/\/3/\[43m\1\[49m/g' $TMPFILE # Yellow?
#sed -i -r 's/\/\/4([^\/\/]*)\/\/4/\[44m\1\[49m/g' $TMPFILE # Blue?
#sed -i -r 's/\/\/5([^\/\/]*)\/\/5/\[45m\1\[49m/g' $TMPFILE # Magenta?
#sed -i -r 's/\/\/6([^\/\/]*)\/\/6/\[46m\1\[49m/g' $TMPFILE # Cyan?
#sed -i -r 's/\/\/7([^\/\/]*)\/\/7/\[47m\1\[49m/g' $TMPFILE # White?
#
#sed -i -r 's/\/\/([^\/\/]*)\/\//\[48m\1\[49m/g' $TMPFILE # Default

# Re-implement new lines 
sed -i -r 's/\$\$\$\$/\n/g' $TMPFILE

# Print edited file
cat $TMPFILE

# Remove Edited file
rm $TMPFILE

# Reset bash terminal and end
echo "[0m"
exit
