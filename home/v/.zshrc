#!/bin/zsh
# btw, this script still will be ran with zash. And also all the scripts sourced from here.
# ~/.zshrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export PATH="$PATH:${HOME}/s/evdev/:${HOME}/.cargo/bin/:${HOME}/go/bin/:/usr/lib/rustup/bin/"
. ~/.credentials.sh

# currently it is 3,65Gb # And B is for bytes
TOTAL_RAM_B=$(rg  MemTotal /proc/meminfo | awk '{print $2 * 1024}')

# nvim shortcut, that does cd first, to allow for harpoon to detect project directory correctly
# e stands for editor
e() {
  if [ -n "$1" ]; then
		if [ -f "$1" ]; then
			cd $(dirname $1)
			basename=$(basename $1)
			shift
			nvim $basename $@
		elif [ -d "$1" ]; then
			cd $1
			shift
			nvim "$@" .
		else
			local could_fix=0
			local try_extensions=(".sh" ".rs" ".go" ".py" ".json" ".txt")
			# note that indexing starts at 1, as we're in a piece of shit shell.
			for i in {1..${#try_extensions[@]}}; do
				local try_path="${1}${try_extensions[$i]}"
				if [ -f "$try_path" ]; then
					cd $(dirname $try_path)
					basename=$(basename $try_path)
					shift
					nvim $basename $@
					could_fix=1
					break
				fi
			done
			if [ $could_fix = 1 ]; then
				return 0
			else
				nvim "$@"
				#return 1
			fi
		fi
	
		cd - > /dev/null
  else
    nvim .
  fi
}
#TODO: in a few days, given `e` works correctly, update this to be the same.
se() {
  if [ -n "$1" ]; then
    split_array=$(echo "$1" | tr "/" "\n")
    last_element=$(echo "$split_array" | tail -n 1)

    cd "$1" && shift && sudo -Es nvim "$@" . || cd "${1%$last_element}" && shift && sudo -Es nvim $last_element $@ 

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
		ls -A $@
	fi
}
mkfile() {
  file_path="$1"
  mkdir -p "$(dirname "${file_path}")"
	touch "${file_path}"
}
cs() {
	cd "$@"
	. "./run.sh" > /dev/null 2>&1
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
z() {
	ending=".pdf"
	zathura "$1$ending"
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

alias mr="py ${HOME}/s/help_scripts/massren/massren -d '!' $@"
alias q="py ${HOME}/s/help_scripts/ask_gpt.py $@"
alias jn="jupyter notebook &"
alias ln="sudo ln -s"
alias sr='source ~/.zshrc'

# # cd
alias cc="cd && clear"

alias csc="cs ~/.config"
alias css="cs ~/s"
alias csh="cs ~/s/help_scripts"
alias csv="cs ~/s/valera"
alias csd="cs ~/Downloads"
alias csa="cs ~/s/ai-news-trade-bot"
alias cst="cs ~/s/tmp"
#
# # editor
alias ec="e ~/.config/nvim"
alias es="e ~/.zshrc"
alias ezt="e ~/.config/zsh/themes/minimal.zsh"
#? can I do this for rust and go? (maybe something with relative paths there)
alias ep="e ~/envs/Python/lib/python3.11/site-packages" 
alias hx="helix"
#
# # keyd
alias rkeyd="sudo keyd reload && sudo journalctl -eu keyd"
alias lkeyd="sudo keyd -m"
#
# # pacman
alias pS="sudo pacman -S --noconfirm"
alias pR="sudo pacman -R --noconfirm"
alias pRn="sudo pacman -Rns --noconfirm"
alias pG="pacman -Q | rg"
alias pY="${HOME}/s/help_scripts/boring.sh"
#
# # yay
alias yS="yay -S --noconfirm"
alias yR="yay -R --noconfirm"
alias yR="yay -Rns --noconfirm"
alias yG="yay -Q | rg"
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
. ~/s/help_scripts/shell_harpoon/main.sh
. ~/.config/nnn/setup.sh
. ~/s/help_scripts/server.sh
. ~/s/help_scripts/init_projects.sh
. ~/s/help_scripts/git.sh

# last one, so local changes can overwrite global.
if [ -f "${HOME}/.local.sh" ]; then
	source "${HOME}/.local.sh"
else
	ZSH_THEME="${HOME}/.config/zsh/themes/minimal.zsh"
	source $ZSH_THEME
fi
