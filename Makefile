#!/usr/bin/make
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  A script to install the different modular scripts 
#
# Usage:  make [all|script-name]
#
# Future Enhancements:
# 	Include a `make clean` command to uninstall scripts
# 	Check make version
#	Support being called from other directories 

# sanity checks
ifneq ($(shell lsb_release -si),Ubuntu)
$(error "System is unsupported")
endif

OS_VERS:=$(shell lsb_release -sr )
ifeq ($(OS_VERS),18.04)
else ifeq ($(OS_VERS),16.04)
else
$(error "System is unsupported")
endif

# Useful variables
CURRENT_DIR := $(shell pwd)

# List of commands that should run even if a file is created with the same name
.PHONY: all patch-on-startup help 


# help is at the top so it is default

# This is a nifty bit of self documentation here. Just start the line with "##"
## help			: Print help
help: Makefile
	@sed -n 's/^## //p' $<	

## markdown		: Install the "md" command to mark up markdown files in your terminal.
markdown: Makefile
	touch ${HOME}/.bash_aliases
	grep -q -F 'alias md=' ${HOME}/.bash_aliases || echo 'alias md="bash ${CURRENT_DIR}/markdown/md.sh"' >> ${HOME}/.bash_aliases


## patch-on-startup	: Install the patch on startup script
patch-on-startup: Makefile
	@echo "Installing patch-on-startup" 
	sed 's|$$REPOHOME|${CURRENT_DIR}|g' patch-on-startup/patchonstartup.desktop.template > ~/.config/autostart/patchonstartup.desktop
	
## all			: Install all scripts provided by this repo
all: patch-on-startup markdown
	@echo "All scripts have been installed"
