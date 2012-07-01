#!/bin/bash
  
##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A script that helps me sleep by shutting down media player smoothly
#
# Usage: ./insomnia.sh <time>
#       
#       * <time>  the time in seconds from when it 
#                 starts shutting down the player
##

# Output current settings
echo "Current Volume Settings:";
amixer get Master | grep Mono ;
period=$1;
half=$(($period/2));
echo "sleeping for $half x2";
sleep $period;

# Lowering volume slowly
for (( i = 0; i < 100; i++ )); do
  sleep 5;
  amixer sset Master,0 1- > /dev/null
done

