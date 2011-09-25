#!/bin/bash
# A minor script to massively rename files 
# in a folder based on a pattern

# Here we rename aWokenIcons2.png to aWokenIcons1.png
for file in *2.png; do
  echo "Working on $file";
  mv $file `echo $file | sed "s/2/1/"`
done;

 
  
