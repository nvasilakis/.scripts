#!/bin/bash
# A script bringing cheatsheets at your
# fingers
# author: Nikos Vasilakis
# email:  n.c.vasilakis@gmail.com
#
# notes: 

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
esac
