#!/bin/bash

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ] && [ "$#" -ne 3 ] ; then
  echo "Try $0 <user> [remote[pwd]], assuming ~/<user>.pub exists"
  exit 1
fi

u=$1 
stars=${2:-"lifestar.ndr.md deathstar.ndr.md memstar.ndr.md alpha.ndr.md beta.ndr.md gamma.ndr.md delta.ndr.md bowie.csail.mit.edu antikythera.csail.mit.edu"}
p="${3:-$(openssl rand -base64 32 | tr -dc A-Za-z0-9 | head -c 8)}"

if [ ! -e ~/$u.pub ]
then
  echo "There is no ~/$u.pub!"
  exit 1
fi

echo Servers: 
echo $stars | xargs -n1 | sed 's/^/ * /'

read

for h in $(echo $stars | xargs -n1); do
	rsync -av --progress ~/${u}.pub "nikos@$h:~"
	ssh -t "nikos@$h" "cd scripts || cd .scripts; git pull; sudo ./adduser.sh ${u} ${p}"
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
