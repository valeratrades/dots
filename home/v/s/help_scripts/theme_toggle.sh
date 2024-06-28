#!/bin/sh

CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$CURRENT_MODE" = "'prefer-dark'" ]; then
	notify-send "going light"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  sed -i "s/rose-pine.toml/catppuccin-latte.toml/" ~/.config/alacritty/alacritty.toml
	swaymsg output '*' bg ~/Wallpapers/AndreySakharov.jpg fill
else
	notify-send "going dark"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  sed -i "s/catppuccin-latte.toml/rose-pine.toml/" ~/.config/alacritty/alacritty.toml
	swaymsg output '*' bg ~/Wallpapers/girl_with_a_perl_earring.jpg fill
fi
nvim --remote-send '<C-\><C-N>:lua setSystemTheme()<CR>'
