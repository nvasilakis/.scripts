#!/bin/bash

##
# 2011, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A  tiny  script   that  populates  the  dotrc  folder   with  all  the
# configuration files  for linux. It  pulls checks if git  is installed,
# and installs it if not,  configures git, generates private/public keys
# (requires passphrase),  prompts you to  add the keys to  github, pulls
# from github and generates the soft links.
#
# Usage: ./populate
#
# Required arguments: None
##

##
#Function used for debugging output
##
function e {
  echo "[Output] $1";
}

wget https://raw.github.com/nvasilakis/scripts/master/setup-keys.sh .
chmod +x setup-keys.sh
wget https://raw.github.com/nvasilakis/scripts/master/setup.sh .
chmod +x setup.sh
./setup-keys.sh
