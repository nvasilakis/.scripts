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
  for partition in "${partitions}"; do 
    if [ $(echo "${diskfree}" | grep -c "${partition}") -eq 1 ];
      echo "${partition} is mounted";
    else
      read -p "Format ${partition} to ext3 [y/N]" toFORMAT
      case "${toFormat}" in
        y)
          mke2fs -F -j ${partition} \
            && sudo mkdir /mnt/${partition} \
            && sudo mount /dev/${partition} /mnt/${partition} \
            && sudo chown -R $(whoami):$(whoami) /mnt/${partition}
          ;;
        *)
          echo "Exiting"
          exit 1;
          ;;
      esac
    fi

  done
}



