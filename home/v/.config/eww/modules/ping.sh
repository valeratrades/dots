#!/bin/sh

HOST="8.8.8.8"

# won't work on school wifi for example, as it is a sad piece of shit (they have something blocking sending pings)
if ! ping=$(ping -c 1 -W 1 "$HOST" 2> /dev/null); then
  echo "None"
else
  rtt=$(echo "$ping" | sed -n 's/.*time=\([0-9]\+\).* ms/\1/p')
  
  [ -z "$rtt" ] && echo "" && exit 1
  echo "$rtt"
fi
