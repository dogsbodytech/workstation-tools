#!/usr/bin/env bash
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  A script to setup and maintain the dogsbody workstation environment.
#
# Usage: Add this to your Ubuntu Startup Applications as follows
#        Name: Patch On Startup
#        Command: bash "/path/to/patch-on-startup.sh"
#        Comment: Patch On Startup
#

error ()
{
  echo " "
  echo "  ######  #####   #####    ####   #####  "
  echo "  #       #    #  #    #  #    #  #    # "
  echo "  #####   #    #  #    #  #    #  #    # "
  echo "  #       #####   #####   #    #  #####  "
  echo "  #       #   #   #   #   #    #  #   #  "
  echo "  ######  #    #  #    #   ####   #    # "
  echo " "
  read -p "Press enter to continue"
}

waitforapt()
{
  i=0
  tput sc
  while sudo fuser /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
    case $((${i} % 4)) in
      0 ) j="-" ;;
      1 ) j="\\" ;;
      2 ) j="|" ;;
      3 ) j="/" ;;
    esac
    tput rc
    echo -en "\r[${j}] Waiting for other software managers to finish..." 
    sleep 0.5
    ((i=i+1))
  done
  echo ""
}

waitfornetwork()
{
  i=0
  echo "Testing Network Connectivity"
  while ! curl --fail -s -m 3 http://connectivity-check.ubuntu.com/; do
    case $((${i} % 4)) in
      0 ) j="-" ;;
      1 ) j="\\" ;;
      2 ) j="|" ;;
      3 ) j="/" ;;
    esac
    echo -en "\r[${j}] Cannot connect to the Ubuntu repos, retrying... hold 's' to skip or 'q' to quit." 
    read -t 0.5 -N1 input
    if [[ $input == "s" ]] || [[ $input == "S" ]]; then
      break
    elif [[ $input == "q" ]] || [[ $input == "Q" ]] ; then
      exit
    fi
    ((i=i+1))
  done
  echo ""
}

if [ "${1}" = "subscript" ]; then
  # REPOHOME Variable set by make file
  source $REPOHOME/patch-on-startup/settings.local

  TEMPFILE=`mktemp`
  # Running sudo now so that it's cached
  echo
  echo "Dogsbody Technology Environment Setup"
  echo "====================================="
  waitfornetwork
  echo
  echo "Getting sudo privilege to install latest updates"
  sudo date
  # If there are problems running `sudo date` then exit.
  if [ ${?} != 0 ]; then
    echo "Issue getting sudo privileges"
    error
    exit 1
  fi
  echo

  # Updating Snaps
  if hash snap 2>/dev/null; then
    echo "Updating Snaps"
    echo "=============="
    sudo snap refresh --color=always --unicode=always --abs-time || error
    echo
  else
    echo "Snap is not installed."
    echo
  fi

  # Updating Flatpaks
  if hash flatpak 2>/dev/null; then
    echo "Updating Flatpaks"
    echo "================="
    sudo flatpak update --noninteractive
    echo
  else
    echo "Flatpak is not installed."
    echo
  fi


  # apt-get update does not produce an exit codes for some errors
  # we want to pause on warnings and errors too
  echo "Getting Updates"
  echo "==============="
  waitforapt
  sudo apt-get update 2>&1 | tee ${TEMPFILE} || echo E: update failed | tee ${TEMPFILE}
  if grep -q '^[WE]:' ${TEMPFILE}; then
    error
  fi
  echo
  # Patching
  echo "Patching"
  echo "========"
  waitforapt
  sudo apt-get -y dist-upgrade | tee ${TEMPFILE} || error
  if ! grep -q '^0 to upgrade, 0 to newly install,' ${TEMPFILE}; then
    INSTALLS=$(tail -4 /var/log/apt/history.log | grep "^Install:" | sed 's|^Install: ||' | xargs -d"," -n2 | column -t | sed 's|^|  |g')
    UPGRADES=$(tail -4 /var/log/apt/history.log | grep "^Upgrade:" | sed 's|^Upgrade: ||' | xargs -d"," -n2 | column -t | sed 's|^|  |g')
  fi
  echo
  # Cleanup
  echo "Cleanup"
  echo "======="
  waitforapt
  sudo apt-get -y autoremove | tee ${TEMPFILE} || error
  if ! grep -q '^0 to upgrade, 0 to newly install,' ${TEMPFILE}; then
    REMOVE=$(tail -4 /var/log/apt/history.log | grep "^Remove:" | sed 's|^Remove: ||' | xargs -d"," -n1 | column -t | sed 's|^|  |g')
  fi
  echo
  # Chmod PEM files - Need to ask user where PEM files are stored.. if any..
  echo "Chmodding PEM files"
  echo "==================="
  # Check user set paths to check
  if [[ ! -z ${USER_INPUT_PATHS} ]]; then 
    for userpath in ${USER_INPUT_PATHS[@]}; do
      if [ -d $userpath ]; then
        find $userpath -type f -name "*.pem" -exec chmod 600 {} + || error
      fi
    done
  fi
  echo
  # Check Vagrant
  if hash vagrant 2>/dev/null; then
    echo "Checking latest Vagrant is installed"
    echo "================================="
    VAGRANTCURRENT=$(vagrant --version | sed -n '1p' | grep -o "[0-9]*\.[0-9]*\.[0-9]*")
    echo "Local Current Version: ${VAGRANTCURRENT}"
    echo -n "Testing against latest release  "
    curl -sS https://raw.githubusercontent.com/hashicorp/vagrant/stable-website/version.txt | grep -o "${VAGRANTCURRENT}" || VAGRANTUPDATENEEDED='YES'
    echo
  fi
  # Can we use Cowsay?
  echo "Cowsay"
  echo "======"
  if hash cowsay 2>/dev/null; then
    COWSAY=`cowsay -l | sed  '1d;s/ /\n/g' | sort -R | tail -1`
    echo "Using Cowsay: ${COWSAY}"
  else
    echo "Not using Cowsay, install it with \`sudo apt-get install cowsay\`"
  fi
  echo
  echo "Checking workstation tools git repo"
  echo "==================================="
  cd $REPOHOME
  hash stat
  hash git
  if [ ! -d "$REPOHOME/.git" ]; then
    echo "Error: $REPOHOME is not a git repo"
    GITUPDATE="false"
    error
  else
    GITUPDATE=$(git fetch --quiet)
    GITUPDATE+=$(git diff origin/master --stat)
  fi
  echo
  # Cleanup
  rm "${TEMPFILE}"
  # A nice report to keep Rob happy :-)
  # Swap clear for printing clear char to avoid clearing scrollback
  printf "\33[H\33[2J"
  echo
  if hash toilet 2>/dev/null; then
    echo " Dogsbody Technology" | toilet -F gay -t -f smmono12
  else
    if [[ ${COWSAY} ]]; then
      cowsay -f ${COWSAY} "Welcome ${LOGNAME^} have a productive day."
    else
      echo "Welcome ${LOGNAME^} have a productive day."
    fi
  fi
  echo
  if [[ ${INSTALLS} ]]; then
    echo "Installs:"
    echo "${INSTALLS}"
    echo
  fi
  if [[ ${UPGRADES} ]]; then
    echo "Upgrades:"
    echo "${UPGRADES}"
    echo
  fi
  if [[ ${REMOVE} ]]; then
    echo "Removed:"
    echo "${REMOVE}"
    echo
  fi
  if [[ ${VAGRANTUPDATENEEDED} ]]; then
    echo "New version of Vagrant available."
    echo
  fi
  # Check the latest kubectx files are pulled down when possible
  if [ -f $REPOHOME/../dbh_tools/bin/check_repo.sh -a -d $REPOHOME/../kubectx ]; then
      $REPOHOME/../dbh_tools/bin/check_repo.sh $REPOHOME/../kubectx
  fi

  if [[ ${GITUDATE} == "false" ]]; then
    echo "Warning: The workstation-tools repo is no longer git controlled."
  elif [[ ${GITUPDATE} ]]; then 
    echo "The workstation-tools repo is not in-line with master."
    echo "Changes as follow:"
    echo "${GITUPDATE}"
    echo
  fi
  echo
  read -p "Press enter key to close"
else
  gnome-terminal --maximize -- bash -c "bash \"${0}\" subscript"
fi
