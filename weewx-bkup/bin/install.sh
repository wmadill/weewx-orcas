#!/bin/bash
# Installtion script for weewx database backups
#
# November 1, 2024
#
VERSION=1.0
BASEDIR=/home/weewx/weewx-bkup

# Prompting function
confirm() {
  read -r -p "${1:-Are you sure? [y/N]} " response
  response="$(echo $response | tr '[:upper:]' '[:lower:]')"
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    true
  else
    false
  fi
}

confirm "Install database backups? [y/N]"

if  [ $? -ne 0 ]; then
  echo "Installation canceled"
  exit 1
fi

echo "Checking archive directory"
if [ -d "$BASEDIR/archive" ]; then
  echo "archive directory exists"
elif [ -e "$BASEDIR/archive" ]; then
  echo "$BASEDIR/archive must be a directory" ];
  exit 1
else
  echo "archive directory does not exist; creating"
  mkdir -p $BASEDIR/archive
fi

# archive directory must be empty
if ! [ "$(ls -A "$BASEDIR/archive")" = "" ]; then
  echo "$BASEDIR/archive must be empty"
  exit 1
fi

echo "Creating additional directories"
mkdir -p $BASEDIR/archive/weekly
mkdir -p $BASEDIR/archive/monthly
mkdir -p $BASEDIR/log

echo "Creating crontab for daily backup"
#
# Ask if want to install crontab
(crontab -l 2>/dev/null; echo "57 23 * * * /home/weewx/weewx-bkup/bin/bkupdbs.sh >>/home/weewx/weewx-bkup/log/bkup.log 2>&1") | crontab -
