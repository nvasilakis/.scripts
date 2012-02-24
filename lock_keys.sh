#!/bin/bash

##
# 2011, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A handy  notification script. It  visually notifies when  user presses
# CAPS-LOCK, NUM-LOCK or SCROLL-LOCK keys  (for notebooks). Note that it
# distinguishes between on  and off, and notifies  accordingly. It makes
# use of the  libnotify-bin and a modified notify that  works exactly as
# the given examples in the man pages (especially the timeout flag). The
# user can change the icon shown or the duration from within the script.
# Note: the user  must define the key bindings (caps  etc) to launch the
# script via another  application such as compiz keys  plugin or fluxbox
# bindings.
#
# Usage: ./lock_keys.sh <key>
#
# required arguments: 
# <key>     The given  key parameter, it  must be either Scroll,  Num or
#           Caps. The user can define more keys.
##



icon="/usr/share/icons/Humanity/devices/32/keyboard.svg"
icon="/usr/share/icons/AwOken/clear/24x24/status/ibus-keyboard.svg"
icon="/usr/share/icons/AwOken/clear/128x128/status/ibus-keyboard.svg"
icon="/usr/share/icons/AwOken/clear/128x128/devices/kxkb.png"
case $1 in
  'scrl')
    mask=3
    key="Scroll"
    ;;
  'num')
    mask=2
    key="Num"
    ;;
  'caps')
    mask=1
    key="Caps"
    ;;
esac
value=$(xset q | grep "LED mask" | sed -r "s/.*LED mask:\s+[0-9a-fA-F]+([0-9a-fA-F]).*/\1/")
if [ $(( 0x$value & 0x$mask )) == $mask ]
then
  output="$key Lock"
  output2="On"
else
  output="$key Lock"
  output2="Off"
fi
notify-send -i $icon "$output" "$output2" -t 1000
