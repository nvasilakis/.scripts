#!/bin/sh
#
# 2009.10.13 Brian Elliott Finley
# License: GPL v2
#
# This program uses disper to switch between the built-in and an
# external display on a notebook.  See
# http://willem.engen.nl/projects/disper/ for details on disper.
#
# Use the following commands to install disper
# 
# sudo add-apt-repository ppa:disper-dev/ppa
# sudo apt-get update && sudo apt-get upgrade
# sudo apt-get install disper
#

NOTEBOOK_DISPLAY="DFP-0"

disper --export 2>&1 | grep "metamode: $NOTEBOOK_DISPLAY"

if [ $? = 0 ]; then
    # enable the secondary display
    disper --secondary
else
    # enable the primary (notebook) display
    disper --single
fi
