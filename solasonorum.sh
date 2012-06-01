#!/bin/bash
  
##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A script that sends mocp info to notifu-osd
#
# Usage: ./solasonorum.sh 
##

/usr/bin/notify-send "$(echo $(mocp -Q %r))" "$(echo $(mocp -Q %t))" -i "$(echo $(mocp -Q %file) | sed 's%/[^/]*$%/Folder.jpg%')" -t 5000

