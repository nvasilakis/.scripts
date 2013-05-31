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
##

# Function used for debugging output.
function e {
  echo $2 ".. $1";
}

current_dir=$(pwd)

e "Clone via https(1) or ssh(2)? [1]> " -n
read method;
if [[ $method == 2 ]]; then
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
