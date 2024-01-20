#!/bin/bash
swaymsg -t subscribe '["window"]' | jq -c --unbuffered 'select(.change == "focus")' | while read -r event; do
  app_id=$(echo "$event" | jq -r '.container.app_id // ""')
  
  if [[ $app_id == *"chrome"* ]]; then
    swaymsg bindsym --to-code Ctrl+j exec xdotool key ctrl+c
    swaymsg bindsym --to-code Ctrl+k exec xdotool key ctrl+v
  else
    swaymsg unbindsym --to-code Ctrl+j
    swaymsg unbindsym --to-code Ctrl+k
  fi
done
