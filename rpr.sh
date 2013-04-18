#!/bin/bash
  
##
# 2013, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A script that sends files to remote printers
#
# Usage: ./rpr.sh <file>
##

#invoke it from everywhere
if [[ "${1:0:1}" == "/" ]]; then
  f="${1}"
else
  f="$(pwd)/${1}"
fi

echo "Sending $f for printing on SEAS"
fn=$(basename "$f")
en="${fn##*.}"
fn="${fn%.*}"
echo "[$fn].[$en]  [$f]"
rsync -av --progress "$f" 'nvas@eniac.seas.upenn.edu:~/print'
#TODO: Add here-string
ssh nvas@eniac.seas.upenn.edu "cd print; if [[ \"$en\" == \"pdf\" ]];
then pdf2ps \"${fn}.pdf\" \"${fn}.ps\"; lpr -P4alcove \"${fn}.ps\"; else lpr -P4alcove \"${fn}.${en}\"; fi; " 
echo "$f printed!"
