#!/bin/bash

##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# Script that installs all required git repositories on the local
# machine, registers submodules and setups .*rc files as soft links.
#
# Usage: ./post-setup.sh
##



current_dir=$(pwd)
# last two are for compiling gnu screen on debial-like systems
install zsh screen git htop autoconf libncurses5-dev

clean

e "Clone via https(1) or ssh(2)? [1]> " -n
read method;
if [[ $method == 2 ]]; then
  wget https://raw.github.com/nvasilakis/scripts/master/setup-keys.sh
  chmod +x setup-keys.sh
  ./setup-keys.sh
  # cleanup
  rm setup-keys.sh

  git clone git@github.com:nvasilakis/immateriia.git ${VIM}
  git clone git@github.com:nvasilakis/scripts.git    ${SCRIPTS}
  git clone git@github.com:nvasilakis/.emacs.d.git   ${EMACS}
  git clone git@github.com:nvasilakis/dotrc.git      ${SHELL}
  cd ~/.vim
  e 'updating submodules'
  git submodule update --init
else
  git clone https://github.com/nvasilakis/immateriia.git ${VIM}
  git clone https://github.com/nvasilakis/scripts.git    ${SCRIPTS}
  git clone https://github.com/nvasilakis/.emacs.d.git   ${EMACS}
  git clone https://github.com/nvasilakis/dotrc.git      ${SHELL}
  cd ~/.vim
  e 'updating submodules'
  git submodule update --init
fi

cd ~/.dotrc

for i in $FILES; do
        e "installing: ~/.dotrc/$i ~/$i"
        rm -rf ~/$i
        ln -s ~/.dotrc/$i ~/$i
done

e "heading to $current_dir"; cd $current_dir

e "Fetching screen"
git clone git://git.savannah.gnu.org/screen.git
cd screen/src
./autogen.sh
./configure --enable-colors256
make
if [[ -f screen ]]; then
  sudo mv screen $(dirname $(which screen))
  e "Clean up screen"
  cd ~
  rm -rf screen/
  #screen
  e "Type screen to launch it!"
else
  e 'Problem installing screen?'
fi
