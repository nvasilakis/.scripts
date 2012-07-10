#!/bin/bash

# Function used for debugging output.
function e {
  echo "[Output] $1";
}

e 'generating key pair'
ssh-keygen -t rsa -f ~/.ssh/id_rsa -C `whoami`@`uname -n`
e '****************************************'
e 'please add the key NOW to github account'
e '****************************************'
cat ~/.ssh/id_rsa.pub
e '****************************************'
e 'adding pair to ssh agent'
ssh-add ~/.ssh/id_rsa

e 'installation complete'
e '*****************************************'
e '* update your remote servers by running:*'
e '* ssh-copy-id -i user@remotehost.smt    *'
e '*****************************************'

