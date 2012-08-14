#!/bin/bash
  
##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
#
#  .Armarian. /ɑrˈmɛəriən/ [ahr-mair-ee-uhn]

#   {noun}  
#   (History/Historical) a monk in charge  of the library and scriptorium
#   in a monastery.
#
#   Origin: 
#   1840–50; < Medieval  Latin armāri (us), equivalent  to armāri (a)
#   library, orig.  neuter plural,  derivative of  Latin armārium  ( see
#   armarium) + -an
#
#
# Usage: ./armarian.sh
##

scriptorium=${0/armarian.sh/}

for file in $scriptorium/*.sh; do
  echo "${file/$scriptorium/}     $( echo $(awk '/^# A script that /,/^#$/' $file) | sed -e 's/# //' -e 's/ # //g' )"
done
