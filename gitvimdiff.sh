#!/bin/bash

##
# 2012, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A tiny script that does more sophisticated git-diff
#
# Usage: ./gitvimdiff.sh
#
# TODO:
#        *  Add script to $PATH
##

if [ -n "${GIT_EXTERNAL_DIFF}" ]; then
  [ "${GIT_EXTERNAL_DIFF}" = "${0}" ] ||
    { echo "GIT_EXTERNAL_DIFF set to unexpected value" 1>&2; exit 1; }
    exec vimdiff “$2″ “$5″
  else
    GIT_EXTERNAL_DIFF="${0}" exec git –no-pager diff "$@"
  fi

