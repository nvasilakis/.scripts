#!/bin/bash
# TODO: use pdfinfo to grab number of pages

##
# 2011, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A tiny script to distribute print pages among many printers or
# sessions. 
#
# Usage: print.sh <file>
#
# required arguments: 
# <file>    the source  file containing files to be printed.
#           
# TODO:  *  It needs an lot of work -- plus use 'pdfinfo' to grab the
#           number of pages.
##

remaining=10
cat $1 | while read -r line; do
  pages=$line && read -r line;
  file=$line;
  if [ $remaining -eq 0 ]; then
    echo $pages >> reversed.txt
    echo $file >> reversed.txt
  else
    if  [ $pages -gt $remaining ]; then
      printPages=$remaining;
    else
      printPages=$pages;
    fi
  #  gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dFirstPage=1 -dLastPage=$pages -sOutputFile=outfile_p22-p36.pdf icde_linkedin_final.pdf
    if [ $(($printPages % 2)) -eq 0 ]; then
      remaining=$(($remaining-$printPages));
    else
      remaining=$(($remaining-$printPages-1)); #remaining needs to be always positive
    fi
    echo "Remaining is: $remaining and Pages to print are $printPages";
  fi
done;
