#!/bin/sh

CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$CURRENT_MODE" = "'prefer-dark'" ]; then
	notify-send "going light"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
	# Will break when I update to .toml!!!
  sed -i "s/rose-pine.yml/catppuccin-latte.yml/" ~/.config/alacritty/alacritty.yml
else
	notify-send "going dark"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  sed -i "s/catppuccin-latte.yml/rose-pine.yml/" ~/.config/alacritty/alacritty.yml
fi
nvim --remote-send '<C-\><C-N>:lua setSystemTheme()<CR>' --servername ~/tmp/nvimsocket

