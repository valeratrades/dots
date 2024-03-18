#!/bin/sh

to_send=${1}

obs_pid=$(swaymsg -t get_tree | jq '.. | select(.app_id? == "com.obsproject.Studio") | .pid' | head -n 1)

swaymsg [pid="$obs_pid"] focus
notify-send "focused"
swaymsg focus previous
