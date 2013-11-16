#!/bin/bash

##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# Script that installs all required git repositories on the local
# machine, registers submodules and setups .*rc files as soft links.
#
# Usage: ./setup.sh
#
# TODO:  
#       *  Maybe install extra packages
#       *  in case of ssh, grab setup keys, generate keys, wait for
#       github and then continue
##

clear
# Function used for debugging output.
function e {
  echo $2 ".. $1";
}
function icheck {
  sudo apt-get install "$1" || e "Install $1";
}

function install {
  for prog; do
    #echo "Install ${prog}"
    command -v "${prog}" >/dev/null 2>&1 || { icheck "${prog}"; }
  done
}

current_dir=$(pwd)
install zsh screen git htop

e "Clone via https(1) or ssh(2)? [1]> " -n
read method;
if [[ $method == 2 ]]; then
  wget https://raw.github.com/nvasilakis/scripts/master/setup-keys.sh
  chmod +x setup-keys.sh
  ./setup-keys.sh
  # cleanup
  rm setup-keys.sh

  git clone git@github.com:nvasilakis/immateriia.git ~/.vim
  git clone git@github.com:nvasilakis/scripts.git ~/scripts
  git clone git@github.com:nvasilakis/.emacs.d.git ~/.emacs.d
  git clone git@github.com:nvasilakis/dotrc.git ~/.dotrc
  cd ~/.vim
  e 'updating submodules'
  git submodule update --init
else
  git clone https://github.com/nvasilakis/immateriia.git ~/.vim
  git clone https://github.com/nvasilakis/scripts.git ~/scripts
  git clone https://github.com/nvasilakis/.emacs.d.git ~/.emacs.d
  git clone https://github.com/nvasilakis/dotrc.git ~/.dotrc
  cd ~/.vim
  e 'updating submodules'
  git submodule update --init
fi

cd ~/.dotrc
# run sudo xrdb ~/.Xdefaults to complete installation for fluxbox
FILES="$(echo .*rc) .ss .gitconfig .Xdefaults .emacs"
for i in $FILES; do
        e "installing: ~/.dotrc/$i ~/$i"
        rm -rf ~/$i
        ln -s ~/.dotrc/$i ~/$i
done

e "heading to $current_dir"; cd $current_dir
e "Clean up ${0}"; rm  ${0}

screen
