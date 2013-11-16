#!/bin/bash
  
##
# 2013, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# Help Manage EC2 nodes
#
# Contains a number of functions, that 
# need to be sourced at the EC2 node
##

function makeFilesystem {
  partitions="$(grep -v name /proc/partitions | grep -v '^$' | awk '{print $4}')"
  diskfree="$(df)"
  for partition in ${partitions}; do 
    if [ $(echo "${diskfree}" | grep -c "${partition}") -eq 1 ]; then
      echo "${partition} is mounted";
    else
      echo -n "Format ${partition} to ext3 [y/N]?" 
      read toFormat
      case "${toFormat}" in
        y)
          sudo mke2fs -F -j /dev/${partition} \
            && sudo mkdir /mnt/${partition} \
            && sudo mount /dev/${partition} /mnt/${partition} \
            && sudo chown -R $(whoami):$(whoami) /mnt/${partition} \
            && echo "Filesystem ${partition} mounted under /mnt" \
            || { echo "There was a problem mounting ${partition}"; }
          ;;
        *)
          echo "Exiting"
          ;;
      esac
    fi
  done
  df -h
}

makeFilesystem
