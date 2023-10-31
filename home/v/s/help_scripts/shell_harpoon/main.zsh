harpoon_config_path=${HOME}/s/help_scripts/shell_harpoon/config.sh

mute() {
	nohup alacritty -e nvim ${HOME}/s/help_scripts/shell_harpoon/config.sh -c 'nnoremap q :q<CR>' -c "nnoremap <esc> :q<CR>" > /dev/null 2>&1 &
	sleep 0.32
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
		. $temp_file
		if type "cs" &>/dev/null; then
			cs $SHELL_HARPOON_CURRENT_DIR_DUMP
		else
			cd $SHELL_HARPOON_CURRENT_DIR_DUMP
		fi
	fi
}

. $harpoon_config_path
config_functions=("${(@f)$(awk '/\(\) {/ {gsub(/\(\)/, "", $1); print $1}' $harpoon_config_path)}")
for func in "${config_functions[@]}"; do
	unalias "$func" 2>/dev/null
	eval '_wrapper_'"$func"'() {
		. '"$harpoon_config_path"'
		'"$func"' "$@"
	}'
	alias "$func"="_wrapper_$func"
done
