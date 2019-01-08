#!/bin/bash
#
# Name: Panic Phone
# Command: Called via .desktop file
# Comment: Wrapper around gedit for phone calls
#

set -eu

hash gedit

LOC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMP="${LOC}/../live/panic-phone-template.txt"
TIME=`date +%s`
FILE="${LOC}/../var/panic-phone/call-${TIME}.txt"

cp "${TEMP}" "${FILE}"

gedit "${FILE}"

if cmp -s "${TEMP}" "${FILE}"; then
	rm "${FILE}"
fi

