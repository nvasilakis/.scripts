#!/bin/bash
#
# ./adduser.sh <name>
#
# It creates a new user and copies their PK
# Expects public key as ~/<username>.pub


if [ "$#" -eq 0 ]; then
  echo "Try $0 <user> [password], assuming ~/<user>.pub exists"
  cat << EOF
To give you access to a set of servers, please send me (i) the username you want
to  use to  log  into  these servers  (ii)  your public  ssh  key,  as an  email
attachment named  "<username-you-want>.pub". Your ssh  public key should  be the
file  ~/.ssh/id_rsa.pub; if  this  file  doesn't exist,  you  can  create it  by
following instructions  online, such  as https://git.io/JeuCN (but  you probably
have it, if you have a GitHub account).
EOF
  exit 0
fi

u=$1 
p="${2:-$(openssl rand -base64 32 | tr -dc A-Za-z0-9 | head -c 8)}"

if [ -e ~/$u.pub ]
then
  echo "Creating user $u"
  sudo adduser --disabled-password $u
  sudo mkdir /home/$u/.ssh
  sudo touch /home/$u/.ssh/authorized_keys
  sudo mv ~/$u.pub /home/$u/.ssh/authorized_keys
  sudo chown -R $u:$u /home/$u/.ssh
  sudo chmod 700 /home/$u/.ssh
  sudo chmod 600 /home/$u/.ssh/authorized_keys
  sudo cat /home/$u/.ssh/authorized_keys
  echo $u:$p | chpasswd
  sudo passwd -e $u
  echo "Created account $u:$p ."
  # echo "If expected, run 'rm ~/$u.pub'."
else
  echo There is no ~/$u.pub
  exit 0
fi

