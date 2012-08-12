#!/bin/bash
  
##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A script that downloads urls from rapidshare!
#
# Usage: ./rapid.sh [<file>.url | https://<url>]
# TODO:
#       * Clean ${dldir}/files directory
#       * Unarchive all the archived files (in one file)
#       * handle single url (check suffix)
#       * make paths absolute regardless of machnine
##

function usage {
  echo "$0: \ta script tht downloads urls from rapidshare.
  Usage: ./rapid.sh [<file>.urls | https://<url>]
  *\t <file>.urls: a file containing urls that ends in .urls
  *\t http(s)://<url> a url that starts with http://<url>"
  exit 1;
}

if [[ $# -ne 1 ]]; then
  usage
else
  if [[ -a $1 ]]; then
    file=$1
    dldir=${file/.urls//}
  else
    echo "$1 was not found"
    exit 1;
  fi
  echo ${0/\/rapid.sh//} # Now try to locate the cookies file
  if [[ -a ${0/\/rapid.sh//}.cookies/rapidshare ]]; then
    cookie=${0/\/rapid.sh//}.cookies/rapidshare
  elif [[ -a ~/cook/.cookies/rapidshare ]]; then
    cookie=~/cook/.cookies/rapidshare
  else
    echo "The rapidshare cookie file was not found"
    exit 2;
  fi
fi

echo "loading cookie from ${cookie}"
while read line ; do
  echo "Downloading $line in ~/Downloads/${dldir}"
  wget -x --load-cookies ${cookie} -P ~/Downloads/${dldir}  $line
done < $file

echo "Moving all files from ~/Downloads/${dldir} to ~/Downloads/${dldir}"
find ~/Downloads/${dldir} -name '*rar*' -exec mv "{}" ~/Downloads/${dldir}/  \;
