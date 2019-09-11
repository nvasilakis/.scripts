#!/bin/bash
# Will kill all instances of a command
ps aux | grep $1 | grep -v grep | awk '{print $2}' | sudo xargs kill
