#!/bin/bash

set -e

HOST=$(hostname) 
CPU="$(lscpu | grep '^CPU(s):' | awk '{print $2}')x $(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//')"
MEM=$(free -gt | grep Mem | awk '{print $2}')G
HDD=$(df -h | grep ' /$' | awk '{print $2}')
echo "$HOST    $MEM     $HDD     $CPU"
