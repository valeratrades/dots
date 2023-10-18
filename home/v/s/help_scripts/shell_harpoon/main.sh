#!/bin/sh
config_path=${HOME}/s/help_scripts/shell_harpoon/config.sh

mute() {
	nohup alacritty -e nvim ${HOME}/s/help_scripts/shell_harpoon/config.sh > /dev/null 2>&1 &
	sleep 0.3
	swaymsg floating enable

	wait $!
	. $config_path
}
,ui() {
	mute > /dev/null 2>&1
}
#? Can I also do the `,add` thingie?

. $config_path
