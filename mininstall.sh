#!/bin/bash

REPOS=".dotrc .vim .emacs.d .scripts";
RC=".bashrc .conkyrc .hgrc .irbrc .vimrc .zshrc .pythonrc .screenrc .emacs";
RC="${RC} .ocamlinit .pentadactylrc  .gitconfig .Xdefaults .ss";

ssh-keygen -t rsa -b 4096 -C "nikos@vasilak.is"
cat ~/cat .ssh/id_rsa.pub
read null

for d in $REPOS; do
  git clone git@github.com:nvasilakis/$d.git $d
done

for i in $RC; do
  rm -rf ~/$i
  ln -s ~/.dotrc/$i ~/$i
done
