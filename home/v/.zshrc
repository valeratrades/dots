#!/bin/zsh
# btw, this script still will be ran with zash. And also all the scripts sourced from here.
# ~/.zshrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export PATH="$PATH:~/s/evdev/:~/.cargo/bin/:~/s/help_scripts/:~/go/bin/:/usr/lib/rustup/bin/"

ZSH_THEME="${HOME}/.config/zsh/themes/minimal.zsh"
source $ZSH_THEME

# currently it is 3,65Gb # And B is for bytes
TOTAL_RAM_B=$(rg  MemTotal /proc/meminfo | awk '{print $2 * 1024}')

# nvim shortcut, that does cd first, to allow for harpoon to detect project directory correctly
# e stands for editor
e() {
  if [ -n "$1" ]; then
    split_array=$(echo "$1" | tr "/" "\n")
    last_element=$(echo "$split_array" | tail -n 1)

    cd "$1" && shift && nvim "$@" . || cd "${1%$last_element}" && shift && nvim $last_element $@ 

    cd - > /dev/null
  else
    nvim .
  fi
}
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
mkp() {
  file_path="$1"
  mkdir -p "$(dirname "${file_path}")"
	touch "${file_path}" || mkdir "${file_path}"
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
chh() {
	sudo chmod -R 777 ~/
}
z() {
	ending=".pdf"
	zathura "$1$ending"
}

eval "$(jump shell)" # binds to j
alias l="sudo ln -s"
alias gc="cd ~/tmp && git clone --depth=1"
alias sr='source ~/.zshrc'
# # editor
# for editor config
alias ec='e ~/.config/nvim'
# for edit shell
alias es='e ~/.zshrc'
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
cn() {
	cargo new "$@"
	project_name="${!#}"
	cd "$project_name" || printf "\033[31m'cn' assumes project_name being the last argument\033[0m\n"
	cp ${HOME}/.file_snippets/run.sh ./run.sh
	cp ${HOME}/.file_snippets/rustfmt.toml ./rustfmt.toml
	cp ${HOME}/.file_snippets/rust_gitignore ./.gitignore
	git add -A
	git commit -m "-- New Project Snippet --"
}
#
# # python
alias pip="~/envs/Python/bin/pip"
alias py="~/envs/Python/bin/python3"
#

. ~/s/todo/functions.sh
. ~/s/help_scripts/weird.sh
. ~/.credentials.sh
. ~/s/help_scripts/shell_harpoon/main.sh
. ~/.config/nnn/setup.sh
