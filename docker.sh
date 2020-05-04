#!/bin/bash

# This is only for ubuntu and debian
set -o errexit

distro=$(
  # source / pollute namespace only in subshell
  # https://unix.stackexchange.com/a/6348
  . /etc/os-release
  echo $NAME | tr '[:upper:]' '[:lower:]'
)

# From: https://docs.docker.com/engine/install/debian/
sudo apt-get update
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

curl -fsSL https://download.docker.com/linux/$distro/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$distro \
  $(lsb_release -cs) \
  stable"

# https://docs.docker.com/engine/install/linux-postinstall/
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
set +o exit
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker 
docker run hello-world

echo "\n"
echo "To allow more users to run docker without sudo, run:"
echo 'sudo usermod -aG docker <user>'
