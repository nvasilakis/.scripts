#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Try ./$0 <user>, assuming ~/<user>.pub exists"
  exit 0
fi

u=$1 

if [ -e $u ]
then
  echo "Creating user $u"
  sudo adduser $u
  sudo mkdir /home/$u/.ssh
  sudo touch /home/$u/.ssh/authorized_keys
  sudo mv ./$u.pub /home/$u/.ssh/authorized_keys
  sudo chown -R $u:$u /home/$u/.ssh
  sudo chmod 700 /home/$u/.ssh
  sudo chmod 600 /home/$u/.ssh/authorized_keys
else
  echo "There is no user variable defined!"
  exit 0
fi

