#POSIX
config_path=${HOME}/s/help_scripts/shell_harpoon/config.sh

mute() {
	nohup alacritty -e nvim ${HOME}/s/help_scripts/shell_harpoon/config.sh -c 'nnoremap q :q<CR>' -c "nnoremap <esc> :q<CR>" > /dev/null 2>&1 &
	sleep 0.3
	swaymsg floating enable

	wait $!
	. $config_path
}
,ui() {
	mute > /dev/null 2>&1
}


temp_file="${HOME}/tmp/shell_harpoon.sh"
,add() {
	mkdir -p $(dirname "$temp_file")
	echo "export SHELL_HARPOON_CURRENT_DIR_DUMP=$(pwd)" > "$temp_file"
	. $temp_file
}
,c() {
	if [ -z $SHELL_HARPOON_CURRENT_DIR_DUMP ]; then
		printf "first dump the current dir by doing \033[34m,add\033[0m\n"
	else
		if type "cs" &>/dev/null; then
			cs $SHELL_HARPOON_CURRENT_DIR_DUMP
		else
			cd $SHELL_HARPOON_CURRENT_DIR_DUMP
		fi
	fi
}


. $config_path
if [ -f $temp_file ]; then
	. $temp_file
fi
