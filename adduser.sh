#!/bin/bash
#
# ./adduser.sh <name>
#
# It creates a new user and copies their public
# key from ~/<name>.pub.


if [ "$#" -ne 1 ]; then
  echo "Try ./$0 <user>, assuming ~/<user>.pub exists"
  cat << EOF
Please send me your ssh public key, which should be the file
~/.ssh/id_rsa.pub; if this file doesn't exist, you can create it by
following instructions online, such as https://git.io/JeuCN .
Please attach to an email with name <username-you-want>.pub---thanks!
EOF
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
  sudo cat /home/$u/.ssh/authorized_keys
else
  echo "There is no ~/$u.pub!"
  exit 0
fi

