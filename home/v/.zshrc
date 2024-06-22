#!/bin/zsh
# btw, this script still will be ran with zash. And also all the scripts sourced from here.
# ~/.zshrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export MODULAR_HOME="$HOME/.modular"
export PATH="$PATH:${HOME}/s/evdev/:${HOME}/.cargo/bin/:${HOME}/go/bin/:/usr/lib/rustup/bin/:${HOME}/.local/bin/:$MODULAR_HOME/pkg/packages.modular.com_mojo/bin"
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

. ~/.config/nvim/functions.sh

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
	go $@
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
	sudo mkdir -p /mnt/USB
	sudo chown $(whoami):$(whoami) /mnt/USB
	sudo mount /dev/sdb1 /mnt/USB
	cd /mnt/USB
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
	if [ $1 = "-p" ] || [ $1 = "--paper"]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Papers"
	elif [ $1 = "-b" ] || [ $1 = "--book"]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Books"
	elif [ $1 = "-n" ] || [ $1 = "--notes"]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Notes"
	elif [ $1 = "-c" ] || [ $1 = "--courses"]; then
		from="${HOME}/Downloads"
		to="${HOME}/Documents/Courses"
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
alias senable="sudo systemctl enable"
alias sstart="sudo systemctl start"
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
alias obs="mkdir ~/Videos/obs >/dev/null; sudo modprobe v4l2loopback video_nr=2 card_label=\"OBS Virtual Camera\" && pamixer --default-source --set-volume 95 && obs"
alias video_cut="video-cut"
# for some reason there is a weird caching happening, so have to physically cd next to target instead currently...
alias ss="sudo systemctl"
alias cl="wl-copy"
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

play_last() {
	last=$(ls -t ~/Videos/obs| head -n 1)
	vlc --one-instance ~/Videos/obs/$last
}

# # tmux
alias tmux="TERM='alacritty-direct' tmux"
#TODO!!!: make it bail if opening new session failed (could already exist or we could be in another active session now). If former, currently adds new windows to it.
tn() {
	if [ "$TMUX" != "" ]; then
		echo "Already in a tmux session."
		return 1
	fi
	if [ -n "$2" ]; then
		cd $2 || return 1
	fi
	SESSION_NAME=${1:-$(basename "$(pwd)")}
	if [ "${SESSION_NAME}" = ".${SESSION_NAME:1}" ]; then
		SESSION_NAME="_${SESSION_NAME:1}"
	fi
	if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
		echo "Session ${SESSION_NAME} already exists."
		return 1
	fi

	tmux new-session -d -s "${SESSION_NAME}" -n "source"
	tmux send-keys -t "${SESSION_NAME}:source.0" 'nvim .' Enter

	tmux new-window -t "${SESSION_NAME}" -n "build"
	tmux split-window -h -t "${SESSION_NAME}:build"
	tmux send-keys -t "${SESSION_NAME}:build.0" 'cs .' Enter
	tmux send-keys -t "${SESSION_NAME}:build.1" 'cs .' Enter
	tmux select-pane -t "${SESSION_NAME}:build.0"

	tmux new-window -t "${SESSION_NAME}" -n "ref"

	tmux new-window -t "${SESSION_NAME}" -n "tmp"
	tmux send-keys -t "${SESSION_NAME}:tmp.0" 'cd tmp; clear' Enter
	tmux split-window -h -t "${SESSION_NAME}:tmp"
	tmux send-keys -t "${SESSION_NAME}:tmp.1" 'cd tmp; clear' Enter
	tmux split-window -v -t "${SESSION_NAME}:tmp.1"
	tmux send-keys -t "${SESSION_NAME}:tmp.2" 'cd tmp; clear' Enter
	tmux send-keys -t "${SESSION_NAME}:tmp.0" 'nvim .' Enter
	tmux select-pane -t "${SESSION_NAME}:tmp.0"

	tmux attach-session -t "${SESSION_NAME}:source.0"
}
alias ta="tmux attach -t"
alias tl="tmux ls"
alias tk="tmux kill-session -t"
alias tks="tmux kill-server"
#

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
csk() {
	_path="/usr/share/X11/xkb/symbols/"
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
	_path="${HOME}/Documents/Notes"
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
	sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak && sudo sh -c "rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist" && yay -S ${@} --noconfirm
}

alias yR="yay -R --noconfirm"
alias yRn="yay -Rns --noconfirm"
alias yG="yay -Q | rg"
alias ys="yay -s"
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

. ~/s/todo/functions.sh
. ~/notes/functions.sh
. ~/s/help_scripts/tg/functions.sh
. ~/s/help_scripts/git.sh
. ~/s/help_scripts/cargo.sh
. ~/s/help_scripts/weird.sh
. ~/s/help_scripts/shell_harpoon/main.zsh
. ~/.config/nnn/setup.sh
. ~/s/help_scripts/server.sh
. ~/.file_snippets/main.sh
. ~/s/help_scripts/document_watch.sh
# what the fuck they're doing other there
. /etc/profile.d/google-cloud-cli.sh
. ~/.config/zoxide/setup.sh
. ~/s/help_scripts/video_editting.sh

source ${HOME}/.config/zsh/other.zsh

# last one, so local changes can overwrite global.
if [ -f "${HOME}/.local.sh" ]; then
	source "${HOME}/.local.sh"
else
	ZSH_THEME="${HOME}/.config/zsh/theme.zsh"
	source $ZSH_THEME
fi

# pnpm
export PNPM_HOME="/home/v/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
. "$HOME/.cargo/env"
