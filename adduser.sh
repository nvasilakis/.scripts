#!/bin/bash
#
# ./adduser.sh <name>
#
# It creates a new user and copies their public
# key from ~/<name>.pub.

if [ "$#" -ne 1 ]; then
  echo "Try ./$0 <user>, assuming ~/<user>.pub exists"
  exit 0
fi

u=$1 

if [ -e ~/$u.pub ]
then
  echo "Creating user $u"
  sudo adduser $u
  sudo mkdir /home/$u/.ssh
  sudo touch /home/$u/.ssh/authorized_keys
  sudo mv ./$u.pub /home/$u/.ssh/authorized_keys
  sudo chown -R $u:$u /home/$u/.ssh
  sudo chmod 700 /home/$u/.ssh
  sudo chmod 600 /home/$u/.ssh/authorized_keys
  sudo cat /home/$u/.ssh/*
  echo "If expected, run 'rm ~/$u.pub'."
else
  echo "There is no ~/$u.pub!"
  exit 0
fi

