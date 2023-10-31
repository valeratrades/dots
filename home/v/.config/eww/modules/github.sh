#!/bin/sh

notifications="$(gh api notifications 2> /dev/null | jq '. | length')"
if [ -n $notifications ]then
	echo "$notifications" 
fi
