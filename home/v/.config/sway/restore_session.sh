#!/bin/sh

swaymsg "workspace 4, exec alacritty && todo"
swaymsg "workspace 2, exec google-chrome-stable" #--enable-features=UseOzonePlatform --ozone-platform=wayland"
swaymsg "workspace 3, exec telegram-desktop &"
swaymsg "exec discord &" # --enable-features=UseOzonePlatform --ozone-platform=wayland &"
swaymsg "workspace 1, exec alacritty"

#TODO: switch to running it in a minimzed system tray.
sleep 30
# discord had time to load and refresh notifs. Now kill the greedy beast.
swaymsg exec "~/.config/sway/discord_toggle.sh"
