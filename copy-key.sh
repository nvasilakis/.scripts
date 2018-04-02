#!/bin/bash

# requires sudo
USER="yash"

if [[ $USER == "false" ]]; then
  echo "you have to pass a user via $USER or $1"
  exit
fi

mkdir ../$USER/.ssh
touch ../$USER/.ssh/authorized_keys
cat id_rsa.pub >> ../$USER/.ssh/authorized_keys
chmod 600 ../$USER/.ssh/authorized_keys
chown $USER:$USER ../$USER/.ssh/authorized_keys
ls -l ../$USER/.ssh/authorized_keys
cat ../$USER/.ssh/authorized_keys
