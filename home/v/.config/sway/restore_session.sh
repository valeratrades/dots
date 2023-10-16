#!/bin/sh

swaymsg "workspace 1, exec alacritty"
#swaymsg "for_window [class=\".*\"] focus=off"
swaymsg "workspace 4, exec alacritty"
swaymsg "workspace 2, exec google-chrome-stable"
swaymsg "workspace 3, exec telegram-desktop &"
swaymsg "exec discord &"


sleep 30
#swaymsg "for_window [class=\".*\"] focus=on"
# discord had time to load and refresh notifs. Now kill the greedy beast.
swaymsg exec "~/.config/sway/discord_toggle.sh"
