#!/bin/sh

battery="/sys/class/power_supply/BAT0/"
percent=$(cat "$battery/capacity")
status=$(cat "$battery/status")

icon=""
[ "$status" = "Charging" ] && icon=""

echo "{\"content\": \"$percent\", \"icon\": \"$icon\"}"
