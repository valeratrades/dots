#!/bin/sh

README="""\
#sync dots script
  \033[34msync\033[0m to upload local dots
  \033[34mload\033[0m to load global dots

  -m to add a commit message"""


target_dir="/home/v/.dots"
dot_directories="
	/etc/keyd
	/etc/systemd/system/getty@tty1.service.d/override.conf
	/home/v/.cargo/config.toml
	/home/v/.config/alacritty
	/home/v/.config/btc_line.toml
	/home/v/.config/cargo
	/home/v/.config/dconf/user
	/home/v/.config/discord/settings.json
	/home/v/.config/eww
	/home/v/.config/foot
	/home/v/.config/gh/config.yml
	/home/v/.config/git
	/home/v/.config/greenclip.toml
	/home/v/.config/helix
	/home/v/.config/jfind
	/home/v/.config/keyd
	/home/v/.config/mimeapps.list
	/home/v/.config/nnn/setup.sh
	/home/v/.config/nnn/termfilechooser.sh
	/home/v/.config/nvim
	/home/v/.config/openvpn
	/home/v/.config/sway
	/home/v/.config/tmux
	/home/v/.config/todo.toml
	/home/v/.config/xdg-desktop-portal-termfilechooser/config
	/home/v/.config/zathura
	/home/v/.config/zellij
	/home/v/.config/zoxide/setup.sh
	/home/v/.config/zsh
	/home/v/.file_snippets
	/home/v/.lesskey
	/home/v/.local/share/applications/nnn.desktop
	/home/v/.local/share/applications/nvim.desktop
	/home/v/.profile
	/home/v/.zprofile
	/home/v/.zshrc
	/home/v/Wallpapers
	/home/v/g/README.md
	/home/v/s/g/README.md	
	/home/v/s/help_scripts
	/home/v/s/l/README.md
	/usr/bin/start_sway.sh
	/usr/share/X11/xkb/symbols/ru
	/usr/share/X11/xkb/symbols/semimak
	/usr/share/X11/xkb/symbols/us
"

commit() {
	local message="_"
	if [ -n "$1" ]; then
		message="$@"
	fi
	git -C "$target_dir" add -A && git -C "$target_dir" commit -m "$message" && git -C "$target_dir" push
}

exclude_gitignore() {
	local dir="$1"
	local command="$2"
	while IFS= read -r line; do
		command="$command --exclude=$line"
	done < "${dir}/.gitignore"
	echo "$command"
}

sync() {
	#rm -rf the old sync first (to distinguish, we remove all dirs that are not '.git')
	find "${HOME}/.dots/" -mindepth 1 -maxdepth 1 -type d ! -name '.git' -exec rm -rf {} +

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
}

#TODO: `reverse()`, that would sync it back in place after I made changes on the side of the git repo, which I want to sync locally

load() {
	force=${1}
	touch "${HOME}/.local.sh"
	for dir in $dot_directories; do
		from="$(pwd)$dir"
		stripped=$(echo "$dir" | sed 's/^\/home\/v//')
		if [ "$stripped" != "$dir" ]; then
			to="${HOME}${stripped}"
		else
			if [ "$force" = "1" ]; then
				to="$dir"
			else
				# normally, all the things outside ${HOME} are working on the daemon level, and should not be exported
				printf "\033[31m%s\033[0m\n" "skipping $dir"
				continue
			fi
		fi
		mkdir -p "$(dirname "$to")"
		rsync -ru $from $(dirname "$to")
	done

	# # load gits
	mkdir -p ${HOME}/.config/zsh/plugins
	git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.config/zsh/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting ${HOME}/.config/zsh/plugins/zsh-syntax-highlighting
	mkdir -p ${HOME}/clone
	git clone https://github.com/jake-stewart/massren ${HOME}/clone/massren
	#
}

if [ -z "$1" ] || [ "$1" = "sync" ]; then
	shift
	sync
	if [ "$1" = "-m" ]; then
		shift
		commit "$@"
	else
		commit
	fi
elif [ "$1" = "load" ]; then
	if [ "$2" = "-f" ]; then
		load 1
	else
		load 0
	fi
elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	printf "${README}\n"
else
	printf "${README}\n"
	return 1
fi

