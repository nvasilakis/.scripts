#!/bin/bash

##
# 2011, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A script that  cheatsheets at your fingertips. It is  meant to be used
# with a defined  keymaping, which matches keys to the  script call. For
# instance, compiz global keys plugin can  be used, to map <super + key>
# to an integer to be fed to the script.
#
# Reqs:     The gloobus-preview package. For systems with debian package
#           manager run sudo apt-get install gloobus-preview
#
# Usage: cheatview.sh <id>
#           
#            the identifier for the script to select preview 
##

cheatFolder='/media/w7/Users/nikos/Dbox/Dropbox/ebooks/cheatsheets';

if [ ! -f `which gloobus-preview` ]; then
    # Output that we have an error
    if [ -f `which notify-send` ]; then 
      notify-send "There was a problem with gloobus!" -i /usr/share/pixmaps/gnome-color-browser.png -t 5000
    fi
fi

case $1 in
    '1' )
	gloobus-preview "$cheatFolder/emacs.pdf" ;;
    '2' )
	gloobus-preview "$cheatFolder/vim.pdf" ;;
    '3' )
	gloobus-preview "$cheatFolder/dvorak.jpg" ;;
esac
