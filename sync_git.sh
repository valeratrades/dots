#!/bin/env sh

target_dir="${HOME}/.dots"
dot_directories="
	${HOME}/.bashrc
	${HOME}/.profile
	/usr/bin/start_sway.sh
	${HOME}/s/help_scripts
	${HOME}/.config/sway
	${HOME}/.config/eww
	${HOME}/.config/nvim
	${HOME}/.config/keyd
	/etc/keyd
	${HOME}/.config/helix
	${HOME}/.config/git
	${HOME}/.config/greenclip
	${HOME}/.config/foot
	${HOME}/.config/alacritty
	${HOME}/.config/cargo
	${HOME}/.config/zathura
	${HOME}/.config/mimeapps.list
	${HOME}/.local/share/applications/nnn.desktop
	${HOME}/.local/share/applications/nvim.desktop
	${HOME}/.config/dconf/user
"

exclude_gitignore() {
	local dir="$1"
	local command="$2"
	while IFS= read -r line; do
		command="$command --exclude=$line"
	done < "${dir}/.gitignore"
	echo "$command"
}

for dir in $dot_directories; do
	printf "\033[34m%s\033[0m\n" "$dir"
	command="rsync -au"
	command=$(exclude_gitignore "$dir" "$command" 2>/dev/null || :)

	case "$command" in
		*"--exclude"*) echo ${command} | sed 's/^rsync -au //' ;;
	esac

	to="$target_dir$dir"
	mkdir -p "$(dirname "$to")"
	$command "$dir" $(dirname "$to")
done

date=$(date +"%Y-%m-%d %H:%M:%S")
git -C "$target_dir" add -A && git -C "$target_dir" commit -m "$date" && git -C "$target_dir" push
