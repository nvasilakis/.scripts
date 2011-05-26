#!/bin/bash - 
#===============================================================================
#
#          FILE:  multizip.sh
# 
#         USAGE:  ./multizip.sh 
# 
#   DESCRIPTION:  The multizip archives (zip) all folders within a directory
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  nvasilakis 
#       COMPANY: 
#       CREATED:  03/21/2011 03:43:13 PM EET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

for file in *; do
  if [[ -d $file ]]; then
    #statements
    echo "working on " $file
    zip -r "$file".zip "$file"
  fi
done

