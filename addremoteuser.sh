#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Try $0 <user> [password], assuming ~/<user>.pub exists"
  exit 1
fi

u=$1 
p="${2:-$(openssl rand -base64 32 | tr -dc A-Za-z0-9 | head -c 8)}"

if [ -e ~/$u.pub ]
then
  for h in $(echo $stars | xargs -n1); do
    rsync -av --progress ~/${u}.pub "nikos@$h:~"
  done

  sleep 2
  
  for h in $(echo $stars | xargs -n1); do
    ssh -t "nikos@$h" "cd scripts; git pull; sudo ./adduser.sh ${u} ${p}"
  done
# # To reset user's password
# for h in $(echo $stars | xargs -n1); do
#   ssh -t "nikos@$h" "sudo passwd -e $u"
# done

  sleep 2

  echo ""
  echo "Your one time password is: $p"
  echo "You can access machines via:"
  for h in $(echo $stars | xargs -n1); do
    echo "  ssh $u@$h"
  done
else
  echo "There is no ~/$u.pub!"
  exit 0
fi
