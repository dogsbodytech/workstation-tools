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

# sanity checks
ifneq ($(OVERRIDE),TRUE)

ifneq ($(shell lsb_release -si),Ubuntu)
$(error "System is unsupported")
endif

OS_VERS:=$(shell lsb_release -sr )
ifeq ($(OS_VERS),24.04)
else ifeq ($(OS_VERS),22.04)
else ifeq ($(OS_VERS),20.04)
else ifeq ($(OS_VERS),18.04)
else ifeq ($(OS_VERS),16.04)
else
$(error "System is unsupported")
endif

endif

SHELL=/usr/bin/env bash

# Useful variables
CURRENT_DIR := $(shell pwd)

# List of commands that should run even if a file is created with the same name
.PHONY: default all patch-on-startup help to_uuid randpw slackpretty dbtzoom twofactorauth

# help is at the top so it is default

# This is a nifty bit of self documentation here. Just start the line with "##"
## help			: Print help
help: Makefile
	@sed -n 's/^## //p' $<	

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

## slackpretty		: Install the "slackpretty" command which turns slacks poor copy paste text into better markup for humans.
slackpretty: Makefile
	@echo "Installing the slackpretty command"
	touch ${HOME}/.bash_aliases
	grep -q -F 'alias slackpretty=' ${HOME}/.bash_aliases || echo 'alias slackpretty="bash ${CURRENT_DIR}/slackpretty/slackpretty.sh"' >> ${HOME}/.bash_aliases

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

## freeagent-timer		: Install the freeagent timer script
freeagent-timer: Makefile
	@echo "Installing the freeagent timer script"
	@echo "Please enter your OAuth Identifier: "
	@read USERINPUT; sed "s|VARAPPID|$${USERINPUT}|g" ${CURRENT_DIR}/freeagent_timer/freeagent-timer.pl > ${CURRENT_DIR}/live/freeagent-timer.pl
	@echo "Please enter your OAuth Secret ID: "
	@read USERINPUT; sed -i "s|VARSECRETID|$${USERINPUT}|g" ${CURRENT_DIR}/live/freeagent-timer.pl
	@echo "Please enter your App Refresh Token: "
	@read USERINPUT; sed -i "s|VARREFRESHTOKEN|$${USERINPUT}|g" ${CURRENT_DIR}/live/freeagent-timer.pl
	@echo "Please enter your personal freeagent ID: "
	@read USERINPUT; sed -i "s|VARMYFAID|$${USERINPUT}|g" ${CURRENT_DIR}/live/freeagent-timer.pl
	@echo "The next two questions are regarding the default timer this script starts."
	@echo "Please enter the default timer project: "
	@read USERINPUT; sed -i "s|VARDEFAULTPROJECT|$${USERINPUT}|g" ${CURRENT_DIR}/live/freeagent-timer.pl
	@echo "Please enter the default timer task ID from that project: "
	@read USERINPUT; sed -i "s|VARDEFAULTTASK|$${USERINPUT}|g" ${CURRENT_DIR}/live/freeagent-timer.pl
	@grep -q -F 'alias freeagent-timer=' ${HOME}/.bash_aliases || echo 'alias freeagent-timer="perl ${CURRENT_DIR}/live/freeagent-timer.pl"' >> ${HOME}/.bash_aliases
	@echo "Dependancy for perl xml, please install this with \"sudo apt install libxml-libxml-perl\""
	@echo "Install complete"

## dbtzoom			: Install the "dbtzoom" shortcut to open a zoom meeting
dbtzoom: Makefile
	@echo "Installing the dbtzoom command"
	touch ${HOME}/.bash_aliases
	@read -p "What is the Zoom Meeting ID? " ROOMID; \
	read -p "What is the HTML encoded password for this room? " ROOMPASSWORD; \
	CLEANROOM=`echo -e "$${ROOMID}" | tr -d '[:space:]'`; \
	sed -i -n -e '/^alias dbtzoom=/!p' -e "\$$aalias dbtzoom=\'xdg-open \"zoommtg://zoom.us/join?confno=$$CLEANROOM&pwd=$$ROOMPASSWORD&zc=0\"\'" ${HOME}/.bash_aliases

## twofactorauth		: Install the "dbtoauth" shortcut to simplify 2fa
twofactorauth: Makefile
	@echo "Installing 2fa alias"
	touch ${HOME}/.bash_aliases
	grep -q -P 'dbtoauth\(\)' ${HOME}/.bash_aliases || echo 'dbtoauth() { tty=$$(tty); oathtool --totp --base32 "$$@" | tee $${tty} | xclip -i -selection clipboard; echo "Copied to clipboard!"; }' >> ${HOME}/.bash_aliases

## default			: Install core scripts provided by this repo
default: patch-on-startup to_uuid randpw slackpretty twofactorauth
	@echo "Default scripts have been installed"

## all			: Install all scripts provided by this repo
all: patch-on-startup to_uuid randpw slackpretty freeagent-timer dbtzoom twofactorauth 
	@echo "All scripts have been installed"
