#!/bin/bash

REPOS=".dotrc .vim .emacs.d .scripts";
RC=".bashrc .conkyrc .hgrc .irbrc .vimrc .zshrc .pythonrc .screenrc .emacs";
RC="${RC} .ocamlinit .pentadactylrc  .gitconfig .Xdefaults .ss";
PROTO="git"

# sudo apt-get install zsh screen vim git

if [[ "$1" == '--clear' ]]; then
  cd ~
  rm -rf $REPOS
  for i in $RC; do
    rm -f ~/$i
  done
  echo "done; you have rm ~/.ssh manually"
  # rm -rf ~/.ssh
  exit
fi

if [[ "$1" == '--http' ]]; then
  PROTO="http"
fi

if [[ $PROTO == "git" ]]; then
  ssh-keygen -t ed25519 -C "nikos@vasilak.is"
  echo "Copy this key to GitHub:"
  cat /home/nikos/.ssh/id_ed25519.pub
  read
  for d in $REPOS; do
    git clone git@github.com:nvasilakis/$d.git $d
  done
else
  for d in $REPOS; do
    git clone https://github.com/nvasilakis/$d.git $d
  done
fi

cd ~/.vim
git submodule update --init

for i in $RC; do
  echo copying $i
  rm -rf ~/$i
  ln -s ~/.dotrc/$i ~/$i
done
