#!/bin/bash
# TODO: use pdfinfo to grab number of pages

remaining=10
cat print.txt | while read -r line; do
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
