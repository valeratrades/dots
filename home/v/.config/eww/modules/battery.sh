#!/bin/sh

battery="/sys/class/power_supply/BAT0/"
percent=$(cat "$battery/capacity")
adjusted_percent=$(awk -v val=$percent 'BEGIN {printf "%d", int((val * 1.02) - 2 + 0.5)}')

status=$(cat "$battery/status")

icon=""
[ "$status" = "Charging" ] && icon=""

echo "{\"content\": \"$adjusted_percent\", \"icon\": \"$icon\"}"
