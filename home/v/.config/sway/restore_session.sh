#!/bin/sh

swaymsg "workspace 4, exec alacritty"
#swaymsg "for_window [class=\".*\"] focus=off"
#swaymsg "workspace 2, exec google-chrome-stable"
swaymsg "workspace 2, exec google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland"
swaymsg "workspace 3, exec telegram-desktop &
discord  --enable-features=UseOzonePlatform --ozone-platform=wayland &"
swaymsg "workspace 1, exec alacritty"


sleep 30
#swaymsg "for_window [class=\".*\"] focus=on"
# discord had time to load and refresh notifs. Now kill the greedy beast.
swaymsg exec "~/.config/sway/discord_toggle.sh"
