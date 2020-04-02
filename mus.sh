#!/bin/bash

# Multiuser screen

name=${1:-dish}

# if /var/run/screen not 755
# sudo chmod 755 /var/run/screen
# sudo rm -fr /var/run/screen/*

screen -dmS $name
screen -S $name -X multiuser on
# screen -S $name -X acladd bob
screen -r $name
