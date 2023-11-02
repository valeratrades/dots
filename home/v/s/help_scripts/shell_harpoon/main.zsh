harpoon_config_path=${HOME}/s/help_scripts/shell_harpoon/config.sh

mute() {
	nohup alacritty -e nvim ${HOME}/s/help_scripts/shell_harpoon/config.sh -c 'nnoremap q :q<CR>' -c "nnoremap <esc> :q<CR>" > /dev/null 2>&1 &
	sleep 0.35
	swaymsg floating enable

	wait $!
	# . $harpoon_config_path
	# swaymsg "for_window [app_id="Alacritty"]
}
,ui() {
	mute > /dev/null 2>&1
}


temp_file="${HOME}/tmp/shell_harpoon.sh"
,add() {
	mkdir -p $(dirname "$temp_file")
	echo "export SHELL_HARPOON_CURRENT_DIR_DUMP=$(pwd)" > "$temp_file"
}
,c() {
	if [ -z $SHELL_HARPOON_CURRENT_DIR_DUMP ]; then
		printf "Error: first dump the current dir by doing \033[34m,add\033[0m\n"
		return 1
	else
		if type "cs" &>/dev/null; then
			cs $SHELL_HARPOON_CURRENT_DIR_DUMP
		else
			cd $SHELL_HARPOON_CURRENT_DIR_DUMP
		fi
	fi
}

. $harpoon_config_path
if [ -e "$temp_file" ]; then
	. $temp_file
fi	
# Does not work for the life of me. So doing the dumb way.
# config_functions=("${(@f)$(awk '/\(\) {/ {gsub(/\(\)/, "", $1); print $1}' $harpoon_config_path)}")
# for func in "${config_functions[@]}"; do
# 	eval "$func(){(source '$harpoon_config_path'; '$func')}"
# done

alias ,h="source $harpoon_config_path && _h"
alias ,t="source $harpoon_config_path && _t"
alias ,n="source $harpoon_config_path && _n"
alias ,s="source $harpoon_config_path && _s"