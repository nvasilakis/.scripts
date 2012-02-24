#!/bin/bash - 
 
##
# 2011, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# The multizip archives (zip) all folders within a directory
#
# Usage: multizip.sh
# 
# Required arguments: None
##

set -o nounset                              # Treat unset variables as an error

for file in *; do
  if [[ -d $file ]]; then
    #statements
    echo "working on " $file
    zip -r "$file".zip "$file"
  fi
done

