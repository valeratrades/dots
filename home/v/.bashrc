#!/bin/sh 
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export PATH="$PATH:~/s/evdev/:~/.cargo/bin/:~/s/sh_scripts/:~/go/bin/:/usr/lib/rustup/bin/"

PS1='[\u@\h \W]\$ '

# currently it is 3,65Gb # And B is for bytes
TOTAL_RAM_B=$(rg  MemTotal /proc/meminfo | awk '{print $2 * 1024}')

# nvim shortcut, that does cd first, to allow for harpoon to detect project directory correctly
v() {
  if [ -n "$1" ]; then
    split_array=$(echo "$1" | tr "/" "\n")
    last_element=$(echo "$split_array" | tail -n 1)

    cd "$1" && shift && nvim "$@" . || cd "${1%$last_element}" && shift && nvim $last_element $@ 

    cd - > /dev/null
  else
    nvim .
  fi
}
sv() {
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
mkp() {
  file_path="$1"
  mkdir -p "$(dirname "${file_path}")"
	touch "${file_path}" || mkdir "${file_path}"
}
cs() {
	cd "$@" && ls
}

# ============================================================================
# ABOVE THIS LINE WE RELY ON ALL THE APIS TO STAY CONSTANT, AS THEY ARE USED BY OTHER SH SCRIPTS.
# ----------------------------------------------------------------------------
# BELOW THIS LINE ARE THINGS WE NEVER USE RECURSIVELY.
# ============================================================================
chh() {
	sudo chmod -R 777 ~/
}

alias l="sudo ln -s"
alias gc="cd ~/tmp && git clone --depth=1"
alias sr='source ~/.bashrc'
# nvim
alias vc='v ~/.config/nvim'
alias vb='v ~/.bashrc'
# keyd
alias rkeyd="sudo keyd reload && sudo journalctl -eu keyd"
alias lkeyd="sudo keyd -m"
# pacman
alias pS="sudo pacman -Su --noconfirm"
alias pR="sudo pacman -R --noconfirm"
alias pRn="sudo pacman -Rns --noconfirm"
alias pQ="pacman -Q | rg"
alias pY="system_sync.sh"
# yay
alias yS="yay -Su --noconfirm"
alias yR="yay -Rns --noconfirm"
alias yQ="yay -Q | rg"
#
alias phone-wifi="sudo nmcli dev wifi connect Valera password 12345678"
# cargo
alias c="cargo"
alias ck="stop_all_run_cargo.sh"
# python
alias pip="~/envs/Python/bin/pip"
alias py="~/envs/Python/bin/python3"
#

. ~/s/todo/functions.sh
. ~/s/sh_scripts/weird.sh
. ~/.credentials.sh
