#!/bin/bash

# ./mus.sh <session-name> <user>
if [ "$#" -eq 2 ]; then
  echo "./$0 <session-name> <user>"
else

# if /var/run/screen not 755
# sudo chmod 755 /var/run/screen
# sudo rm -fr /var/run/screen/*

screen -d -m -S $1
screen -S $1 -X multiuser on
screen -S $name -X acladd $2
echo "screen -x $(whoami)/$i"
