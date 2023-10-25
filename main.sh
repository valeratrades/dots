#!/bin/env sh

README="""\
#sync dots script
  \033[34msync\033[0m to upload local dots
  \033[34mload\033[0m to load global dots"""


target_dir="${HOME}/.dots"
dot_directories="
	${HOME}/.zshrc
	${HOME}/.zprofile
	${HOME}/.config/zsh
	/usr/bin/start_sway.sh
	${HOME}/s/help_scripts
	${HOME}/.config/sway
	${HOME}/.config/eww
	${HOME}/.config/nvim
	${HOME}/.config/keyd
	/etc/keyd
	${HOME}/.config/helix
	${HOME}/.config/git
	${HOME}/.config/greenclip.toml
	${HOME}/.config/foot
	${HOME}/.config/alacritty
	${HOME}/.config/cargo
	${HOME}/.config/zathura
	${HOME}/.config/mimeapps.list
	${HOME}/.local/share/applications/nnn.desktop
	${HOME}/.local/share/applications/nvim.desktop
	${HOME}/.config/dconf/user
	${HOME}/.config/nnn/termfilechooser.sh
	${HOME}/.config/nnn/setup.sh
	${HOME}/.config/xdg-desktop-portal-termfilechooser/config
	${HOME}/.file_snippets
	${HOME}/.config/openvpn
	/etc/systemd/system/getty@tty1.service.d/override.conf
"

exclude_gitignore() {
	local dir="$1"
	local command="$2"
	while IFS= read -r line; do
		command="$command --exclude=$line"
	done < "${dir}/.gitignore"
	echo "$command"
}

sync() {
	for dir in $dot_directories; do
		printf "\033[34m%s\033[0m\n" "$dir"
		command="rsync -au"
		command=$(exclude_gitignore "$dir" "$command" 2>/dev/null || :)

		case "$command" in
			*"--exclude"*) echo ${command} | sed 's/^rsync -au //' ;;
		esac

		to="$target_dir$dir"
		mkdir -p "$(dirname "$to")"
		$command "$dir" $(dirname "$to") || printf "\033[31merror\033[0m\n"
	done

	date=$(date +"%Y-%m-%d %H:%M:%S")
	git -C "$target_dir" add -A && git -C "$target_dir" commit -m "$date" && git -C "$target_dir" push
}

if [ -z "$1" ] || [ "$1" = "sync" ]; then
	sync
elif [ "1$" = "load" ]; then
	load
elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	printf "${README}\n"
else
	printf "${README}\n"
	return 1
fi

