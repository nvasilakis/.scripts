#!/bin/bash

stars=${2:-"lifestar.ndr.md deathstar.ndr.md memstar.ndr.md alpha.ndr.md beta.ndr.md gamma.ndr.md delta.ndr.md bowie.csail.mit.edu antikythera.csail.mit.edu"}

if [ "$#" -ne 0 ] && [ "$#" -ne 1 ]; then
  echo "Try $0 [remote]"
  exit 1
fi

for h in $(echo $stars | xargs -n1); do
	ssh -t "nikos@$h" "cd scripts || cd .scripts; git pull; ./sysinfo.sh"
done

