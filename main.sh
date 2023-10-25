#!/bin/env sh

README="""\
#sync dots script
  \033[34msync\033[0m to upload local dots
  \033[34mload\033[0m to load global dots"""


target_dir="/home/v/.dots"
dot_directories="
	/home/v/.zshrc
	/home/v/.zprofile
	/home/v/.config/zsh
	/usr/bin/start_sway.sh
	/home/v/s/help_scripts
	/home/v/.config/sway
	/home/v/.config/eww
	/home/v/.config/nvim
	/home/v/.config/keyd
	/etc/keyd
	/home/v/.config/helix
	/home/v/.config/git
	/home/v/.config/greenclip.toml
	/home/v/.config/foot
	/home/v/.config/alacritty
	/home/v/.config/cargo
	/home/v/.config/zathura
	/home/v/.config/mimeapps.list
	/home/v/.local/share/applications/nnn.desktop
	/home/v/.local/share/applications/nvim.desktop
	/home/v/.config/dconf/user
	/home/v/.config/nnn/termfilechooser.sh
	/home/v/.config/nnn/setup.sh
	/home/v/.config/xdg-desktop-portal-termfilechooser/config
	/home/v/.file_snippets
	/home/v/.config/openvpn
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

load() {
	touch "${HOME}/.local.sh"
	for dir in $dot_directories; do
		from="$(pwd)$dir"
		stripped=$(echo "$dir" | sed 's/^\/home\/v//')
		if [[ $stripped != $dir ]]; then
			to="${HOME}${stripped}"
		else
			to="$dir"
		fi
		mkdir -p "$(dirname "$to")"
		rsync -u $from $(dirname "$to")
	done
}

if [ -z "$1" ] || [ "$1" = "sync" ]; then
	sync
elif [ "$1" = "load" ]; then
	load
elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	printf "${README}\n"
else
	printf "${README}\n"
	return 1
fi

