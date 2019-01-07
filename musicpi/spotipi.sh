#!/bin/bash
# Last modified 07 Jan 2019

#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

## Test MPC is installed ##
mpc help >/dev/null 2>&1 || {
	echo "This program require's MPC which is not installed."
	echo "To install run the following."
	echo "sudo apt-get install mpc"
	exit 1
}
##### Variables #####
# Defaults
ADDR="localhost"
PASS=""

# Playlist script port
PORT='6060'

# Import variables from settings.local file
source $REPOHOME/musicpi/settings.local
# Should import:
# ADDR=instance IP
# PASS=instance password

# Help guide
GUIDE=$REPOHOME/musicpi/musicpi-man

# Store songs to remove
TOREMOVELOG=$REPOHOME/var/musicpi-flagged-songs.log

# File name
FILE=$(basename "$0")
# Script name
SCRNAME="spotipi.sh"

# Set the ARGS correctly since we will have the base script and links to use it
if [ "$FILE" == "$SCRNAME" ]; then
  ARG1=${1:-}
  ARG2=${2:-}
else
  ARG1=$FILE
  ARG2=${1:-}
fi

#####################################
# wrapper for the mpc command
mpcwrap()
{
  if [ -z "${2:-}" ]; then
    mpc -h $PASS@$ADDR ${1:-}
  else
    mpc -h $PASS@$ADDR "${1}" ${2:-}
  fi
}

# Defining subcommands
case "$ARG1" in
  mute)
    mpcwrap volume 0
    exit
  ;;
  next)
    case $ARG2 in
      # Record songs flagged for removal
      -d)
        echo -n "$(date +%d/%m/%Y) - $(whoami) - " >> "${TOREMOVELOG}"
        mpcwrap current >> "${TOREMOVELOG}"
      ;;
    esac
    mpcwrap next

    # There is a bug with mopidy where mpc next returns the old song. Not waiting for the next one.
    # This work around that. (Hmm thinking about it I could've just silence the first command...)

    tput cuu1
    tput el
    tput cuu1
    tput el
    tput cuu1
    tput el
    mpcwrap
    exit
  ;;
  # Alt name to remove a song
  flagrm)
    CURRSONG=$(mpcwrap current)
    echo "$(date +%d/%m/%Y),$(whoami),\"${CURRSONG}\"" >> "${TOREMOVELOG}"
    exit
  ;;
  # Reject this song and implement your own.
  add)
    mpcwrap insert "$ARG2"
    mpcwrap next
    exit
  ;;
  # Reject this playlist and implement your own.
  load)
    mpcwrap clear
    mpcwrap load "$ARG2"
    mpcwrap shuffle
    exit
  ;;
  # Use this script to start a funky song no mpc command for add
  funk)
    bash "$0" add spotify:track:32OlwWuMpZ6b0aN2RZOeMS
    mpcwrap play
    exit
  ;;
  help)
    man -l "$GUIDE"
    exit
  ;;
  # Fix mpc bug whith blank inserts
  insert)
    case $ARG2 in
      # Catch spotify uris and redirect to insert
      spotify*)
        mpcwrap insert "$ARG2"
        exit
      ;;
      # Spotify URL Input =
      https://play.spotify.com*)
        TMP=${ARG2//https:\/\/play.spotify.com/spotify}
        mpcwrap insert "${TMP////:}"
        exit
      ;;
      https://open.spotify.com*)
        TMP=${ARG2//https:\/\/open.spotify.com/spotify}
        mpcwrap insert "${TMP////:}"
        exit
      ;;
    esac
    exit 1
  ;;
  # Catch spotify uris and redirect to insert
  spotify*)
    mpcwrap insert "$ARG1"
    exit
  ;;
  # Spotify URL Input
  https://play.spotify.com*)
    TMP=${ARG1//https:\/\/play.spotify.com/spotify}
    mpcwrap insert "${TMP////:}"
    exit
  ;;
  https://open.spotify.com*)
    TMP=${ARG1//https:\/\/open.spotify.com/spotify}
    mpcwrap insert "${TMP////:}"
    exit
  ;;
  setup)
    mpcwrap clear
    mpcwrap consume on
    mpcwrap volume 40
    mpcwrap play 1
    mpcwrap pause
    echo "Party on, Wayne! Party on, Garth!"
    exit
  ;;
  # If the command is not defined pass it to MPC
  *)
    mpcwrap "$ARG1" "$ARG2"
    exit
  ;;
esac

