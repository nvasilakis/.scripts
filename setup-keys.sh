#!/bin/bash

prompt_start () {
  echo '****************************************'
  echo 'please add the key NOW to github account'
  echo '****************************************'
}

prompt_end () {
  echo 'installation complete'
  echo '*****************************************'
  echo '* update your remote servers by running:*'
  echo '* ssh-copy-id -i user@remotehost.smt    *'
  echo '*****************************************'
}

# should return appropriate result 
ssh-keygen -t rsa -f ~/.ssh/id_rsa -C `whoami`@`uname -n` &&
  prompt_start &&
  cat ~/.ssh/id_rsa.pub &&
  read null &&
  e 'adding pair to ssh agent' &&
  ssh-add ~/.ssh/id_rsa &&
  prompt_end &&
  read null || exit 1

