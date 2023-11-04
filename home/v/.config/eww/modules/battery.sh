#!/bin/sh

battery="/sys/class/power_supply/BAT0/"
percent=$(cat "$battery/capacity")
adjusted_percent=$(awk -v val=$percent 'BEGIN {printf "%d", int((val * 1.04) - 4 + 0.5)}') # This is changing due to the age of the battery, so practically an eyeball

status=$(cat "$battery/status")

icon=""
[ "$status" = "Charging" ] && icon=""
[ "$status" = "Full" ] && adjusted_percent="100"

echo "{\"content\": \"$adjusted_percent\", \"icon\": \"$icon\"}"
