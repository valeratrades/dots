#!/bin/zsh
# btw, this script still will be ran with zash. And also all the scripts sourced from here.
# ~/.zshrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export MODULAR_HOME="$HOME/.modular"
export PATH="$PATH:${HOME}/s/evdev/:${HOME}/.cargo/bin/:${HOME}/go/bin/:/usr/lib/rustup/bin/:${HOME}/.local/bin/:$MODULAR_HOME/pkg/packages.modular.com_mojo/bin:/${HOME}/.local/share/flatpak/:/var/lib/flatpak/"
export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:${HOME}/.local/share/flatpak/exports/share"
fpath+="${HOME}/.config/zsh/.zfunc"
. ~/.private/credentials.sh
export EDITOR=nvim
edit() $EDITOR
export LESSHISTFILE="-" # don't save history
export HISTCONTROL=ignorespace # doesn't append command to history if first character is space, so `cd /` is recorded, but ` cd /` is not.

export WAKETIME="5:00" # utc, with french utc+2, corresponds to 7:00
export DAY_SECTION_BORDERS="2.5:10.5:16" # meaning: morning is watektime, (wt), + 2.5h, work-day is `wt+2.5< t <= wt+10.5` and evening is `wt+8.5< t <=16`, after which you sleep.
export TOTAL_RAM_B=$(rg  MemTotal /proc/meminfo | awk '{print $2 * 1024}') # currently it is 3,65Gb # And B is for bytes
#export MANPAGER='nvim +Man!'
export LC_TIME=en_GB.UTF-8

. ~/.config/nvim/functions.sh
mkdir -p /home/v/Videos/obs/ >/dev/null 2>&1

alias exa="eza"
# for super ls
sl() {
	if [ -f "$1" ]; then
		bat $1
	else
		exa -Ah $@
	fi
}
mkfile() {
  file_path="$1"
  mkdir -p "$(dirname "${file_path}")"
	touch "${file_path}"
}
mkf="mkfile"
cs() {
	if [ -f "$1" ]; then
		e "$1"
	else
		cd "$@" || return 1

		. "./.local.sh" > /dev/null 2>&1 || :
		. "./tmp/.local.sh" > /dev/null 2>&1 || :

		if [ "$VIRTUAL_ENV" != "" ]; then
			deactivate
			unset VIRTUAL_ENV
		fi

		. "venv/bin/activate" > /dev/null 2>&1 || :
		sl
	fi
}

# # go
go() {
	todo manual counter-step --dev-runs;
	/usr/bin/go $@
}
#

# # python
py() {
	todo manual counter-step --dev-runs;
	python3 ${@}
}
spy() {
	todo manual counter-step --dev-runs;
	sudo python3 ${@}
}
pp() {
	pip ${@} --break-system-packages
}
pu() {
	${HOME}/s/help_scripts/pip_upload.sh
}
alias pt="pytest"
alias pk="pytest -k "
alias pm="py src/main.py"
#

# ============================================================================
# ABOVE THIS LINE WE RELY ON ALL THE APIS TO STAY CONSTANT, AS THEY ARE USED BY OTHER SH SCRIPTS.
# ----------------------------------------------------------------------------
# BELOW THIS LINE ARE THINGS WE NEVER USE RECURSIVELY.
# ============================================================================
chh() {
	sudo chmod -R 777 ~/
}

usb() {
	partition=${1:-"/dev/sdb1"}
	sudo mkdir -p /mnt/usb
	sudo chown $(whoami):$(whoami) /mnt/usb
	sudo mount -o rw ${partition} /mnt/usb
	cd /mnt/usb
	exa -A
}
creds() {
	_dir="${HOME}/.private/"
	git -C "$1" pull > /dev/null 2>&1
	nvim "${_dir}/credentials.sh"
	git -C "$_dir" add -A && git -C "$_dir" commit -m "." && git -C "$_dir" push
}
function lg() {
	if [ $# = 1 ]; then
		ls -lA | rg $1
	#TODO: fix. For some fucking reason it doesn't work.
	elif [ $# = 2 ]; then
		ls -lA $1 | rg $2
	fi
}
fz() {
	fd $@ | jfind
}
# sync dots
sd() {
	${HOME}/.dots/main.sh sync "$@" > /tmp/dots_log.txt 2>&1 &
}
chess() {
	source ${HOME}/envs/Python/bin/activate
	py -m cli_chess --token lip_sjCnAuNz1D3PM5plORrC
}
# move head
mvt() { # although, not sure if actually needed, as I could just write out `${command} "$(ls -t | head -n 1)" ${path}`, and get the same, but for the general case.
	#NB: {from} cannot end with explicit "/" !
	from="."
	to=${1}
	if [ $1 = "-p" ] || [ $1 = "--paper" ]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Papers"
	elif [ $1 = "-b" ] || [ $1 = "--book" ]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Books"
	elif [ $1 = "-n" ] || [ $1 = "--notes" ]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Notes"
	elif [ $1 = "-c" ] || [ $1 = "--courses" ]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Courses"
	elif [ $1 = "-w" ] || [ $1 = "--wine" ]; then
		from="${HOME}/Downloads"
		to="${HOME}/.wine/drive_c/users/v/Downloads"
	fi
	
	mv "${from}/$(ls ${from} -t | head -n 1)" ${to}
}

matrix() {
	cleanup() {
		sed -i "s/#import =/import =/" ~/.config//alacritty/alacritty.toml
	}
	trap cleanup EXIT
	trap cleanup INT

	sed -i "s/import =/#import =/" ~/.config//alacritty/alacritty.toml
	unimatrix -s96 -fa
	cleanup
}

alias fd="fd -I"         # Creates an alias 'fd' for 'fd -I', ignoring .gitignore and .ignore files.
alias rg="rg -I --glob '!.git'" # Creates an alias 'rg' for 'rg -I --glob '!.git'', ignoring case sensitivity and .git directories.
alias ureload="pkill -u $(whoami)" # Creates an alias 'ureload' to kill all processes of the current user.
alias rf="sudo rm -rf"
alias srf="sudo rm -rf"
alias za="zathura"
alias zp="zathura --mode presentation"
alias massren="py ${HOME}/clone/massren/massren -d '' $@"
alias q="py ${HOME}/s/help_scripts/ask_gpt.py -s $@"
alias f="py ${HOME}/s/help_scripts/ask_gpt.py -f $@"
alias jp="jupyter lab -y"
alias sr='source ~/.zshrc'
alias tree="tree -I 'target|debug|_*'"
alias lhost="nohup nyxt http://localhost:8080/ > /dev/null 2>&1 &"
alias ll="exa -lA"
alias sound="qpwgraph"
alias choose_port="${HOME}/s/help_scripts/choose_port.sh"
alias obs="mkdir ~/Videos/obs >/dev/null; sudo modprobe v4l2loopback video_nr=2 card_label=\"OBS Virtual Camera\" && pamixer --default-source --set-volume 95 && obs" # needed for virtual camera to work // obviously, virtual-cam plugin is pre-requisit
alias video_cut="video-cut"
alias ss="sudo systemctl"
alias cl="wl-copy"
alias wl_copy="wl-copy"
alias gz="tar -xvzf -C"
alias toggle_theme="${HOME}/s/help_scripts/theme_toggle.sh"
alias tokej="tokei -o json | jq . > /tmp/tokei.json"
alias book="booktyping run --myopia"
alias tokio-console="tokio-console --lang en_US.UTF-8"
alias tokio_console="tokio-console"
alias fm="yazi" # for file-manager
alias t="ls -t | head -n 1"
alias mongodb="mongosh "mongodb+srv://test.di2kklr.mongodb.net/" --apiVersion 1 --username valeratrades --password qOcydRtmgFfJnnpd"
alias sql="sqlite3"
alias poetry="POETRY_KEYRING_DISABLED=true poetry"
alias dk="sudo docker"
alias hardware="sudo lshw"
alias home_wifi="nmcli connection up id \"Livebox-3B70\"" #dbg
alias keys="xev -event keyboard"
alias audio="qpwgraph"
alias test_mic="arecord -c1 -vvv /tmp/mic.wav"
alias nano="nvim"
alias pro_audio="pulsemixer"
alias wayland_wine="DISPLAY='' wine64" # set it up to work with wayland, following https://youtu.be/bg-xugXfSGM?si=neo2TQN8yQHQEIip. Still doesn't really work (or I'm dumb).
alias pfind="procs --tree | fzf"
alias tree="fd . | as-tree"
alias bak="XDG_CONFIG_HOME=/home/v/.dots/home/v/.config"
#gpg id = gpg --list-keys --with-colons | awk -F: '/uid/ && /valeratrades@gmail.com/ {getline; print $5}'

play_last() {
	last=$(ls -t ~/Videos/obs| head -n 1)
	vlc --one-instance ~/Videos/obs/$last
}

# # cli_translate
cli_translate="${HOME}/s/help_scripts/cli_translate.py"
alias ttf="$cli_translate -f"
alias tte="$cli_translate -e"
alias ttr="$cli_translate -r"
# the following aliases are only for comportability with my chrome translate shortcuts.
alias tef="$cli_translate -f"
alias trf="$cli_translate -f"
alias tfe="$cli_translate -e"
alias tre="$cli_translate -e"
alias ter="$cli_translate -r"
alias tfr="$cli_translate -r"
#

# # cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}
mvcd() {
    mv $@ && cd "$@[-1]"
}


alias cc="cd && clear"
# cs{} aliases {{{
csc() {
	_path="${HOME}/.config/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
css() {
	_path="${HOME}/s/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csh() {
	_path="${HOME}/s/help_scripts/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csv() {
	_path="${HOME}/s/valera/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csd() {
	_path="${HOME}/Downloads/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csa() {
	_path="${HOME}/s/ai-news-trade-bot/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
cst() {
	_path="${HOME}/tmp/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csl() {
	_path="${HOME}/s/l/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csg() {
	_path="${HOME}/g/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
cssg() {
	_path="${HOME}/s/g/"
	parent=0
	if [ -n "$1" ]; then
		_path+="${1}"
		parent=1
	fi
	cs $_path
	if [ $parent = 1 ]; then
		git pull
	fi
}
csb() {
	_path="${HOME}/Documents/Books/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csp() {
	_path="${HOME}/Documents/Papers"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csn() {
	_path="${HOME}/Documents/SheetMusic"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csu() {
	_path="${HOME}/uni/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
csm() {
	_path="${HOME}/math/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
# }}}

# # keyd
alias rkeyd="sudo keyd reload && sudo journalctl -eu keyd"
alias lkeyd="sudo keyd -m"
#
# # pm
yS() {
	yay -S ${@} --noconfirm && return 0
	${HOME}/s/help_scripts/refresh_mirrorlist.sh && yay -S ${@} --noconfirm
}

alias yR="yay -R --noconfirm"
alias yRn="yay -Rns --noconfirm"
alias yG="yay -Q | rg"
alias yQ="yay -Q"
alias ys="yay -s"

alias pS="sudo pacman --noconfirm -S"
alias pR="sudo pacman --noconfirm -R"
alias pRn="sudo pacman --noconfirm -Rn"
alias pSyy="sudo pacman --noconfirm -Syy"
alias pSyu="sudo pacman --noconfirm -Syu"
alias pG="pacman -Q | rg"

alias pY="${HOME}/s/help_scripts/maintenance/main.sh"
#
alias phone-wifi="sudo nmcli dev wifi connect Valera password 12345678"
alias phone_wifi="phone-wifi"
#TODO!!!!!!!!: fix the bug, where it it blows your ears off when another sound is ongoing when the beep with -l option happens.
# Should be fine if I just implement a global limit on volume, conditional on headphones. But currently fuck the sound-maxing feature.
beep() {	
	if [ $# = 1 ]; then
		if [ "$1" = "-l" ] || [ "$1" = "--loud" ]; then
			mute=$(pamixer --get-mute)
			if [ "$mute" = "true" ]; then
				pamixer --unmute
			fi

			volume=$(pamixer --get-volume)
			#pamixer --set-volume 100
			#mpv ${HOME}/Sounds/Notification.mp3 > /dev/null 2>&1
			#pamixer --set-volume $volume

			if [ "$mute" = "true" ]; then
				pamixer --mute
			fi

			notify-send "beep" -t 600000 # 10min
			return 0
		else
			printf "Only takes \"-l\"/\"--loud\". Provided: $1\n"
			return 1
		fi
	else # normal beep
		notify-send "beep"
		mpv ${HOME}/Sounds/Notification.mp3 > /dev/null 2>&1
		return 0
	fi
}	
timer() {
	trap 'eww update timer="";return 1' INT
	trap 'eww update timer=""' EXIT
	no_beep="false"
	if [ "$1" = "-q" ]; then
		no_beep="true"
		shift
	fi
	if [ "$2" = "-q" ]; then
		no_beep="true"
	fi

	if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """\
Usage: timer [time] [-q]

Arguments:
	time: time in seconds or in format \"mm:ss\".
	-q: quiet mode, shows forever notif instead of beeping.
"""
		return 0
	fi


	input=$1
	if [[ "$input" == *":"* ]]; then
		IFS=: read mins secs <<< "$input"
		left=$((mins * 60 + secs))
	else
		left=$input
	fi

	while [ $left -gt 0 ]; do
		mins=$((left / 60))
		secs=$((left % 60))
		formatted_secs=$(printf "%02d" $secs)
		eww update timer="${mins}:${formatted_secs}"
		sleep 1
		left=$((left - 1))
	done	
	eww update timer=""


	if [ "$no_beep" = "false" ]; then
		beep --loud
	else
		notify-send "timer finished" -t 2147483647
		return 0
	fi
}

. /etc/profile.d/google-cloud-cli.sh # what the fuck they're doing other there
. ~/.config/nnn/setup.sh
. ~/.config/tmux/functions.sh
. ~/.config/zoxide/setup.sh
. ~/.file_snippets/main.sh
. ~/.local.sh
. ~/notes/functions.sh
. ~/s/help_scripts/cargo.sh
. ~/s/help_scripts/document_watch.sh
. ~/s/help_scripts/git.sh
. ~/s/help_scripts/go.sh
. ~/s/help_scripts/goShellScripts/functions.sh
. ~/s/help_scripts/server.sh
. ~/s/help_scripts/shell_harpoon/main.zsh
. ~/s/help_scripts/video_editting.sh
. ~/s/help_scripts/weird.sh
. ~/s/tg/functions.sh
. ~/s/todo/functions.sh

source ${HOME}/.config/zsh/other.zsh

ZSH_THEME="${HOME}/.config/zsh/theme.zsh"
source $ZSH_THEME

# pnpm
export PNPM_HOME="/home/v/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
. "$HOME/.cargo/env"
#[BEGIN SKAR_CONFIG]
alias '?'='/home/v/.cargo/bin/skar shell complete'
alias '??'='/home/v/.cargo/bin/skar shell explain'
alias '?!'='/home/v/.cargo/bin/skar shell generate'
alias '?-'='/home/v/.cargo/bin/skar chat'
#[END SKAR_CONFIG]

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
export filter_mode_shell_up_key_binding="directory"
bindkey "^r" 'atuin-up-search' # only for current dir
bindkey "^g" 'atuin-search' # global search
# and then the actual Up is searching through the session history, as is the default.

#TODO!: figure out direnv
#eval "$(direnv hook zsh)"
