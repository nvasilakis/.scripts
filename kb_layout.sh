#!/bin/bash
  
##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A script that switches keyboard layout between gr and us layouts
#
# Usage: ./kb_layout.sh
#
##

current="$(setxkbmap -query | sed 's/:[ ]*/:/' | grep layout | cut -d: -f2)" 
echo $current
if [[ $current == 'us' ]]; then
  setxkbmap gr
else 
  setxkbmap us
fi


