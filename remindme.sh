#!/bin/bash
# Remind user something

remindmeto() {
  # todo OSX:
  # http://stackoverflow.com/questions/5588064/how-do-i-make-a-mac-terminal-pop-up-alert-applescript
  # Also find notification center even on other platforms
  if [[ $# == 0 ]]; then
    cat <<-__EOF
			
			NAME
			    remindmeto - Reminds user of anything if they are on-screen.
			
			SYNOPSIS
			    remindmeto <dosomething> at <time>
			
			DESCRIPTION
			    Remindmeto feeds users with small bursts of text at
			    pre-specified to remind them what they need to remember at
			    this point in time. All entries are mandatory, otherwise this
			    help is printed.
			
			    <dosomething> : arbitrary text (optionally containing "at")
			
			    <time> : Can be a combination of the following formats:
			      * Time: one- or two-digit number (0-23) to indicate the start of an
			        hour on a 24-hour clock (e.g., 13 is 13:00 or 1:00pm).
			      * Date: keywards (e.g., today, tomorrow), day of week 
			        (e.g., Monday) or fully qualified date (e.g., November 9, 2010).
			      * Increment: period relative to now, using "+" followed by a number
			        and one of {minutes, hours, days, months, years}.
			
			AUTHOR
			    Written by Nikos Vasilakis
			
			COPYRIGHT
			    Copyright © 2013 Nikos Vasilakis.  License GPLv3+: GNU GPL version 3 
			    or later  <http://gnu.org/licenses/gpl.html>.  This is free software: 
			    you are free to  change and  redistribute  it. There is NO  WARRANTY,
			    to the extent permitted by law.
			
			__EOF
  else
    # remindmeto drink milk at 6
    # remindmeto return book at the library at 6
    when="$(echo "${*}" | sed 's/^.*at//')"
    #what="$(echo "${*}" | sed 's/^\(.*\)at/\1/')"
    what="$(echo "${*}" | sed 's/^\(.*\)at.*$/\1/' | sed -e 's/^\(.\)/\u\1/g')"
    #what="$(echo "${*}" | sed "s/${when}//")"
    if [[ "${1}" == "debug" ]]; then
      echo "all:  $*"
      echo "when: ${when}"
      echo "what: ${what}"
    fi
    at "${when}" <<-__EOF
			notify-send "Hey!" "${what}!" -i /usr/share/pixmaps/gnome-color-browser.png -t 5000
			paplay /usr/share/sounds/gnome/default/alerts/drip.ogg
			atq
			__EOF
    rat=$?
    if [[ $rat != 0 ]]; then
      echo "\e[00;31mThere was an ERROR, $(whoami) -- Please resubmit!"
    fi
  fi
}

remindmeto $*
