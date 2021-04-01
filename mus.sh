#!/bin/bash
# ./mus.sh <session-name> <user>

# https://unix.stackexchange.com/a/163878
if [ "$#" -eq 2 ]; then
  # if /var/run/screen not 755
  # sudo chmod 755 /var/run/screen
  # sudo rm -fr /var/run/screen/*

  sudo chmod u+s $(which screen)
  sudo chmod 755 /var/run/screen
  screen -d -m -S $1
  screen -S $1 -X multiuser on
  screen -S $1 -X acladd $2
  echo "screen -x $(whoami)/$1"
else
  echo "./$0 <session-name> <user>"
fi

