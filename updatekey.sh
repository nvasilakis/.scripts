#!/bin/bash

stars="lifestar.ndr.md deathstar.ndr.md memstar.ndr.md beta.ndr.md gamma.ndr.md delta.ndr.md";

if [ "$#" -ne 1 ]; then
  echo "Try $0 <user> [password], assuming ~/<user>.pub exists"
  exit 1
fi

u=$1 

if [ -e ~/$u.pub ]
then
  # copy key
  for h in $(echo $stars | xargs -n1); do
    rsync -av --progress ~/${u}.pub "nikos@$h:~"
  done

  sleep 2
  
  for h in $(echo $stars | xargs -n1); do
    ssh -t "nikos@$h" "cd scripts; git pull; sudo mv ~/$u.pub /home/$u/.ssh/authorized_keys; sudo chown $u:$u /home/$u/.ssh/authorized_keys"
  done
else
  echo "There is no ~/$u.pub!"
  exit 0
fi

