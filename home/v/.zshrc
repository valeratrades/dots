#!/bin/zsh
# btw, this script still will be ran with zash. And also all the scripts sourced from here.
# ~/.zshrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export PATH="$PATH:${HOME}/s/evdev/:${HOME}/.cargo/bin/:${HOME}/go/bin/:/usr/lib/rustup/bin/"
. ~/.credentials.sh
export EDITOR=nvim
edit() $EDITOR
export LESSHISTFILE="-" # don't save history
# currently it is 3,65Gb # And B is for bytes
TOTAL_RAM_B=$(rg  MemTotal /proc/meminfo | awk '{print $2 * 1024}')

# nvim shortcut, that does cd first, to allow for harpoon to detect project directory correctly
# e stands for editor
e() {
	need_cd_out=0
	nvim_commands=""
	if [ "$1" = "flag_load_session" ]; then
		nvim_commands="-c SessionLoad"
		shift
	fi
  if [ -n "$1" ]; then
		if [ -d "$1" ]; then
			_t="$1"
			if [ $_t != $(pwd) ]; then
				cd $_t
				need_cd_out=1
			fi
			shift
			nvim "$@" . "$nvim_commands"
		else
			local could_fix=0
			local try_extensions=("" ".sh" ".rs" ".go" ".py" ".json" ".txt" ".md" ".typst" ".tex" ".html" ".js")
			# note that indexing starts at 1, as we're in a piece of shit shell.
			for i in {1..${#try_extensions[@]}}; do
				local try_path="${1}${try_extensions[$i]}"
				if [ -f "$try_path" ]; then
					_t=$(dirname $try_path)
					if [ _t != $(pwd) ]; then
						cd $_t
						need_cd_out=1
					fi
					basename=$(basename $try_path)
					shift
					nvim $basename $@ $nvim_commands
					could_fix=1
					break
				fi
			done
			if [ $could_fix = 1 ]; then
				return 0
			else
				nvim "$@" "$nvim_commands"
			fi
		fi
		if [ $need_cd_out -eq 1 ]; then
			cd - > /dev/null
		fi
  else
    nvim . "$nvim_commands"
  fi
}
ep() {
	e flag_load_session "$@"
}
# Problematic to do an inclusive script that could be ran with sudo too, so just copying manually; adding `sudo` to everything for now.
#? make a macro with `sed`?
se() {
  if [ -n "$1" ]; then
		if [ -f "$1" ]; then
			cd $(dirname $1)
			basename=$(basename $1)
			shift
			sudo -Es nvim $basename $@
		elif [ -d "$1" ]; then
			cd $1
			shift
			sudo -Es nvim "$@" .
		else
			local could_fix=0
			local try_extensions=(".sh" ".rs" ".go" ".py" ".json" ".txt" ".md" "typst" "tex")
			# note that indexing starts at 1, as we're in a piece of shit shell.
			for i in {1..${#try_extensions[@]}}; do
				local try_path="${1}${try_extensions[$i]}"
				if [ -f "$try_path" ]; then
					cd $(dirname $try_path)
					basename=$(basename $try_path)
					shift
					sudo -Es nvim $basename $@
					could_fix=1
					break
				fi
			done
			if [ $could_fix = 1 ]; then
				return 0
			else
				sudo -Es nvim "$@"
			fi
		fi	
		cd - > /dev/null
  else
    sudo -Es nvim .
  fi
}

# for super ls
sl() {
	if [ -f "$1" ]; then
		cat $1
	else
		ls -Ah $@
	fi
}
mkfile() {
  file_path="$1"
  mkdir -p "$(dirname "${file_path}")"
	touch "${file_path}"
}
cs() {
	cd "$@" || return 1
	. "./run.sh" > /dev/null 2>&1 || :
	sl
}
# # python
alias pip="~/envs/Python/bin/pip"
alias py="~/envs/Python/bin/python3"
#

# ============================================================================
# ABOVE THIS LINE WE RELY ON ALL THE APIS TO STAY CONSTANT, AS THEY ARE USED BY OTHER SH SCRIPTS.
# ----------------------------------------------------------------------------
# BELOW THIS LINE ARE THINGS WE NEVER USE RECURSIVELY.
# ============================================================================
eval "$(jump shell)" # binds to j
chh() {
	sudo chmod -R 777 ~/
}

usb() {
	sudo mkdir -p /mnt/USB
	sudo chown $(whoami):$(whoami) /mnt/USB
	sudo mount /dev/sdb1 /mnt/USB
	cd /mnt/USB
	ls -A
}
function lg() {
	if [ $# = 1 ]; then
		ls -A | rg $1
	#TODO: fix. For some fucking reason it doesn't work.
	elif [ $# = 2 ]; then
		ls -A $1 | rg $2
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


alias z="zathura"
alias senable="sudo systemctl enable"
alias sstart="sudo systemctl start"
alias massren="py ${HOME}/clone/massren/massren -d '' $@"
alias q="py ${HOME}/s/help_scripts/ask_gpt.py -s $@"
alias f="py ${HOME}/s/help_scripts/ask_gpt.py -f $@"
alias jn="jupyter notebook &"
alias ln="sudo ln -s"
alias sr='source ~/.zshrc'
alias tree="tree -I 'target|debug|_*'"
alias lhost="nohup nyxt http://localhost:8080/ > /dev/null 2>&1 &"


# # cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}
mvcd() {
    mv $@ && cd "$@[-1]"
}

alias cc="cd && clear"

alias csc="cs ~/.config"
alias css="cs ~/s"
alias csh="cs ~/s/help_scripts"
alias csv="cs ~/s/valera"
alias csd="cs ~/Downloads"
alias csa="cs ~/s/ai-news-trade-bot"
alias cst="cs ~/tmp"
alias csl="cs ~/s/l"
alias csk="cs /usr/share/X11/xkb/symbols/"
alias csg="cs ~/s/g"
#
# # editor
alias ec="e ~/.config/nvim"
alias es="e ~/.zshrc"
alias ezt="e ~/.config/zsh/theme.zsh"
#? can I do this for rust and go? (maybe something with relative paths there)
alias epy="e ~/envs/Python/lib/python3.11/site-packages" 
alias hx="helix"
#
# # keyd
alias rkeyd="sudo keyd reload && sudo journalctl -eu keyd"
alias lkeyd="sudo keyd -m"
#
# # pm
alias yS="yay -S --noconfirm"
alias yR="yay -R --noconfirm"
alias yRn="yay -Rns --noconfirm"
alias yG="yay -Q | rg"
alias pG="pacman -Q | rg"
alias pY="${HOME}/s/help_scripts/boring.sh"
alias pS="yay -S --noconfirm"
alias pR="yay -R --noconfirm"
alias pRn="yay -Rns --noconfirm"
#
alias phone-wifi="sudo nmcli dev wifi connect Valera password 12345678"
# # cargo
alias c="cargo"
# for super cargo
sc() {
	starttime=$(date +%s)
	${HOME}/s/help_scripts/stop_all_run_cargo.sh $@
	endtime=$(date +%s)
	elapsedtime=$((endtime - starttime))
	if [ $elapsedtime -gt 20 ]; then
		mpv ${HOME}/Sounds/Notification.mp3
	fi
}
#

. ~/s/todo/functions.sh
. ~/s/help_scripts/weird.sh
. ~/s/help_scripts/shell_harpoon/main.zsh
. ~/.config/nnn/setup.sh
. ~/s/help_scripts/server.sh
. ~/s/help_scripts/init_projects.sh
. ~/s/help_scripts/git.sh
. ~/s/help_scripts/document_watch.sh

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

# you can use `export MANPAGER="nvim +Man!"` to see man pages in neovim
