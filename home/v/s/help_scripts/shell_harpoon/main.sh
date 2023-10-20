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
#? I think I'm in need of 'jump'. I think my thingie still has a case though; as jump doesn't seem to be able to handle custom commands like 'cs' and not so simple to get it to work with new projects.

. $config_path
