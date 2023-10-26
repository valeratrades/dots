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

alias ls="ls -A"
mkfile() {
  file_path="$1"
  mkdir -p "$(dirname "${file_path}")"
	touch "${file_path}"
}
cs() {
	cd "$@"
	. "./run.sh" > /dev/null 2>&1
	ls
}

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
# Doesn't work
vcp() {
	scp "${1} ${VINCENT_SSH_HOST}:${2}"
}

alias jn="jupyter notebook &"
alias l="sudo ln -s"
alias gc="cd ~/tmp && git clone --depth=1"
alias sr='source ~/.zshrc'
alias gu='gitui'
# # cd
alias csc="cs ~/.config"
alias css="cs ~/s"
alias csh="cs ~/s/help_scripts"
alias csv="cs ~/s/valera"
alias csd="cs ~/Downloads"
alias csa="cs ~/s/ai-news-trade-bot"
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
alias pS="sudo pacman -Su --noconfirm"
alias pR="sudo pacman -R --noconfirm"
alias pRn="sudo pacman -Rns --noconfirm"
alias pQ="pacman -Q | rg"
alias pY="${HOME}/s/help_scripts/system_sync.sh"
#
# # yay
alias yS="yay -Su --noconfirm"
alias yR="yay -R --noconfirm"
alias yR="yay -Rns --noconfirm"
alias yQ="yay -Q | rg"
#
alias phone-wifi="sudo nmcli dev wifi connect Valera password 12345678"
# # cargo
alias c="cargo"
alias ck="stop_all_run_cargo.sh"
#
# # python
alias pip="~/envs/Python/bin/pip"
alias py="~/envs/Python/bin/python3"
#

. ~/s/todo/functions.sh
. ~/s/help_scripts/weird.sh
. ~/s/help_scripts/shell_harpoon/main.sh
. ~/.config/nnn/setup.sh
. ~/s/help_scripts/server.sh
. ~/s/help_scripts/init_projects.sh

# last one, so local changes can overwrite global.
if [ -f "${HOME}/.local.sh" ]; then
	source "${HOME}/.local.sh"
else
	ZSH_THEME="${HOME}/.config/zsh/themes/minimal.zsh"
	source $ZSH_THEME
fi
