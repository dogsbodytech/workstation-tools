#!/usr/bin/make
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  A script to install the different modular scripts 
#
# Usage:  make [all|script-name] [OVERRIDE=TRUE]
#
# Future Enhancements:
# 	Check make version
#	Support being called from other directories 
#	Skip user input if variable set
#	Check MPC is installed before installing musicpi

# sanity checks
ifneq ($(OVERRIDE),TRUE)

ifneq ($(shell lsb_release -si),Ubuntu)
$(error "System is unsupported")
endif

OS_VERS:=$(shell lsb_release -sr )
ifeq ($(OS_VERS),18.04)
else ifeq ($(OS_VERS),16.04)
else
$(error "System is unsupported")
endif

endif

SHELL=/usr/bin/env bash


# Useful variables
CURRENT_DIR := $(shell pwd)

# List of commands that should run even if a file is created with the same name
.PHONY: all patch-on-startup help markdown html_character_parser from_epoch panic-phone to_uuid randpw musicpi slackpretty


# help is at the top so it is default

# This is a nifty bit of self documentation here. Just start the line with "##"
## help			: Print help
help: Makefile
	@sed -n 's/^## //p' $<	

## markdown		: Install the "md" command to mark up markdown files in your terminal.
markdown: Makefile
	@echo "Installing the md command" 
	touch ${HOME}/.bash_aliases
	grep -q -F 'alias md=' ${HOME}/.bash_aliases || echo 'alias md="bash ${CURRENT_DIR}/markdown/md.sh"' >> ${HOME}/.bash_aliases

## to_uuid			: Install the "to_uuid" command to turn strings into ansible UUID's. 
to_uuid: Makefile
	@echo "Installing the to_uuid command" 
	touch ${HOME}/.bash_aliases
	chmod +x ${CURRENT_DIR}/to_uuid/to_uuid.py
	grep -q -F 'alias to_uuid=' ${HOME}/.bash_aliases || echo 'alias to_uuid="${CURRENT_DIR}/to_uuid/to_uuid.py"' >> ${HOME}/.bash_aliases

## randpw			: Install the "randpw" command which autogenerates random passwords
randpw: Makefile
	@echo "Installing the randpw command" 
	touch ${HOME}/.bash_aliases
	grep -q -P '(randpw\(\) |alias randpw=)' ${HOME}/.bash_aliases || echo 'randpw() { for i in 16 24 32 48; do echo == $${i} digits ==; apg -a 1 -n 5 -m $${i} -x $${i} -MCLN; done }' >> ${HOME}/.bash_aliases

## from_epoch		: Install the "from_epoch" command which converts time from epoch into gregorian
from_epoch: Makefile
	@echo "Installing the from_epoch command" 
	touch ${HOME}/.bash_aliases
	chmod +x ${CURRENT_DIR}/from_epoch/from_epoch.py
	grep -q -F 'alias from_epoch=' ${HOME}/.bash_aliases || echo 'alias from_epoch="${CURRENT_DIR}/from_epoch/from_epoch.py"' >> ${HOME}/.bash_aliases

## html_character_parser	: Install the "html_character_parser" command which encodes and decodes strings into HTML
html_character_parser: Makefile
	@echo "Installing the html_character_parser command" 
	touch ${HOME}/.bash_aliases
	chmod +x ${CURRENT_DIR}/html_character_parser/html_character_reference.py
	grep -q -F 'alias html_character_parser=' ${HOME}/.bash_aliases || echo 'alias html_character_parser="${CURRENT_DIR}/html_character_parser/html_character_reference.py"' >> ${HOME}/.bash_aliases

## slackpretty		: Install the "slackpretty" command which turns slacks poor copy paste text into better markup for humans.
slackpretty: Makefile
	@echo "Installing the slackpretty command"
	touch ${HOME}/.bash_aliases
	grep -q -F 'alias slackpretty=' ${HOME}/.bash_aliases || echo 'alias slackpretty="bash ${CURRENT_DIR}/slackpretty/slackpretty.sh"' >> ${HOME}/.bash_aliases

## panic-phone		: Install the "panic-phone" tool. Which opens gedit with a custom template + filename. 
panic-phone: Makefile
	@echo "Installing the panic-phone tool"
	hash gedit
	mkdir -p ${CURRENT_DIR}/var/panic-phone/
	sed 's|$$REPOHOME|${CURRENT_DIR}|g' ${CURRENT_DIR}/panic-phone/panic-phone.desktop.template > ${CURRENT_DIR}/live/panic-phone.desktop
	chmod +x ${CURRENT_DIR}/live/panic-phone.desktop
	chmod +x ${CURRENT_DIR}/panic-phone/panic-phone.sh
	[[ -r ${CURRENT_DIR}/live/panic-phone-template.txt ]] || cp ${CURRENT_DIR}/panic-phone/message-template.txt ${CURRENT_DIR}/live/panic-phone-template.txt
	@echo "To customise your phone call template edit ${CURRENT_DIR}/live/panic-phone-template.txt"
	@echo "We recommend pinning ${CURRENT_DIR}/live/panic-phone.desktop to your desktop launcher/dock"


## musicpi			: Install the "musicpi" wrapper script to control a mopidy server
musicpi: Makefile
	@echo "Installing the musicpi command"
	echo "# WARNING: Do not manually edit" > ${CURRENT_DIR}/patch-on-startup/settings.local
	echo "# File contents are auto-generated via makefile" >> ${CURRENT_DIR}/patch-on-startup/settings.local
	@echo "What is the IP address of your mopidy instance? (Default: localhost)"
	@read USERINPUT; sed -r 's|([^\ ]*)|"\1"|g; s|^|ADDR=(|; s|$$|)|' <<< $${USERINPUT} >> ${CURRENT_DIR}/musicpi/settings.local
	@echo "What is the port for this instance? (Default: 6060)"
	@read USERINPUT; sed -r 's|([^\ ]*)|"\1"|g; s|^|PASS=(|; s|$$|)|' <<< $${USERINPUT} >> ${CURRENT_DIR}/musicpi/settings.local
	@echo "What is the password for this instance? (Default: blank)"
	@read USERINPUT; sed -r 's|([^\ ]*)|"\1"|g; s|^|PASS=(|; s|$$|)|' <<< $${USERINPUT} >> ${CURRENT_DIR}/musicpi/settings.local
	touch ${HOME}/.bash_aliases
	touch ${HOME}/.bash_completion
	sed 's|$$REPOHOME|${CURRENT_DIR}|g' ${CURRENT_DIR}/musicpi/spotipi.sh > ${CURRENT_DIR}/live/spotipi.sh
	sed 's|$$REPOHOME|${CURRENT_DIR}|g' ${CURRENT_DIR}/musicpi/musicpi-bash-completion > ${CURRENT_DIR}/live/musicpi-bash-completion
	grep -q -F 'alias musicpi=' ${HOME}/.bash_aliases || echo 'alias musicpi="bash ${CURRENT_DIR}/live/spotipi.sh"' >> ${HOME}/.bash_aliases
	grep -q -P 'musicpi/musicpi-bash-completion$$' ${HOME}/.bash_completion || echo '. ${CURRENT_DIR}/live/musicpi-bash-completion' >> ${HOME}/.bash_completion

## patch-on-startup	: Install the patch on startup script
patch-on-startup: Makefile
	@echo "Installing the patch-on-startup script" 
ifeq ($(shell [[ -r ${CURRENT_DIR}/patch-on-startup/settings.local ]] && echo "exists"),exists)
	@echo "Config file already exists, skipping config prompts."
else
	echo "# File contents are auto-generated via makefile" > ${CURRENT_DIR}/patch-on-startup/settings.local
	echo "# Delete this file and run 'make patch-on-startup' to reset" >> ${CURRENT_DIR}/patch-on-startup/settings.local
	@echo "This script can update .pem key permissions for you."
	@echo "Which paths would you like checked? This is a space deliminated array."
	@read USERINPUT; sed -r 's|([^\ ]*)|"\1"|g; s|^|USER_INPUT_PATHS=(|; s|$$|)|' <<< $${USERINPUT} >> ${CURRENT_DIR}/patch-on-startup/settings.local
endif
	sed 's|$$REPOHOME|${CURRENT_DIR}|g' ${CURRENT_DIR}/patch-on-startup/patch-on-startup.sh > ${CURRENT_DIR}/live/patch-on-startup.sh
	mkdir -p ~/.config/autostart
	sed 's|$$REPOHOME|${CURRENT_DIR}|g' ${CURRENT_DIR}/patch-on-startup/patchonstartup.desktop.template > ~/.config/autostart/patchonstartup.desktop


## all			: Install all scripts provided by this repo
all: patch-on-startup markdown to_uuid randpw from_epoch html_character_parser musicpi slackpretty panic-phone
	@echo "All scripts have been installed"



