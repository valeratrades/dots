#!/bin/zsh
# btw, this script still will be ran with zash. And also all the scripts sourced from here.
# ~/.zshrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export PATH="$PATH:${HOME}/s/evdev/:${HOME}/.cargo/bin/:${HOME}/go/bin/:/usr/lib/rustup/bin/:${HOME}/.local/bin/"
. ~/.private/credentials.sh
export EDITOR=nvim
edit() $EDITOR
export LESSHISTFILE="-" # don't save history
export HISTCONTROL=ignorespace # doesn't append command to history if first character is space, so `cd /` is recorded, but ` cd /` is not.

export WAKETIME="7:00"
export DAY_SECTION_BORDERS="2.5:10.5:16" # meaning: morning is watektime, (wt), + 2.5h, work-day is `wt+2.5< t <= wt+10.5` and evening is `wt+8.5< t <=16`, after which you sleep.
export TOTAL_RAM_B=$(rg  MemTotal /proc/meminfo | awk '{print $2 * 1024}') # currently it is 3,65Gb # And B is for bytes


# nvim shortcut, that does cd first, to allow for harpoon to detect project directory correctly
# e stands for editor
#NB: $1 nvim arg has to be the path
e() {
	nvim_commands=""
	if [ "$1" = "--flag_load_session" ]; then
		nvim_commands="-c SessionLoad"
		shift
	fi
	nvim_evocation="nvim"
	if [ "$1" = "--use_sudo_env" ]; then
		nvim_evocation="sudo -Es -- nvim"
		shift
	fi
	#git_push_after="false"
	#if [ "$1" = "--git_sync" ]; then
	#	git_push_after="true"
	#	shift
	#	git -C "$1" pull > /dev/null 2>&1
	#fi
	local full_command="${nvim_evocation} ."
	if [ -n "$1" ]; then
		if [ -d "$1" ]; then
			pushd ${1} &> /dev/null
			shift
			full_command="${nvim_evocation} ${@} ."
		else
			local could_fix=0
			local try_extensions=("" ".sh" ".rs" ".go" ".py" ".json" ".txt" ".md" ".typ" ".tex" ".html" ".js" ".toml")
			# note that indexing starts at 1, as we're in a piece of shit zsh.
			for i in {1..${#try_extensions[@]}}; do
				local try_path="${1}${try_extensions[$i]}"
				if [ -f "$try_path" ]; then
					pushd $(dirname $try_path) &> /dev/null
					shift
					full_command="${nvim_evocation} $(basename $try_path) ${@} ${nvim_commands}"
					eval ${full_command}
					popd &> /dev/null
					#if git_push_after; then
					#	push ${1}
					#fi
					return 0
				fi
			done
			full_command="${nvim_evocation} ${@}"
		fi
	fi

	full_command+=" ${nvim_commands}"
	eval ${full_command}

	# clean the whole dir stack, which would drop back if `pushd` was executed, and do nothing otherwise.
	# hopefuly I'm not breaking anything by doing so.
	while [ "$(dirs -v | wc -l)" -gt 1 ]; do popd; done > /dev/null 2>&1

	
	#if [ "$git_push_after" = "true" ]; then
	#	push ${1}
	#fi
}
ep() {
	e --flag_load_session "$@"
}
se() {
	e --use_sudo_env ${@}
}

# for super ls
sl() {
	if [ -f "$1" ]; then
		cat $1
	else
		ls -Ah $@
	fi
}
alias ll="ls -lA"
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

# # cargo
cb() {
	guess_name=$(basename $(pwd))
	if [ -f "./src/lib.rs" ]; then
		return 0
	fi
	sc build --release && sudo mv ./target/release/${guess_name} /usr/local/bin/
}
#
alias py="python3"
pp() {
	pip ${@} --break-system-packages
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

usb() {
	sudo mkdir -p /mnt/USB
	sudo chown $(whoami):$(whoami) /mnt/USB
	sudo mount /dev/sdb1 /mnt/USB
	cd /mnt/USB
	ls -A
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

alias fd="fd -I"         # Creates an alias 'fd' for 'fd -I', ignoring .gitignore and .ignore files.
alias rg="rg -I --glob '!.git'" # Creates an alias 'rg' for 'rg -I --glob '!.git'', ignoring case sensitivity and .git directories.
alias ureload="pkill -u $(whoami)" # Creates an alias 'ureload' to kill all processes of the current user.
alias rf="rm -rf"
alias srf="sudo rm -rf"
alias z="zathura"
alias zp="zathura --mode presentation"
alias senable="sudo systemctl enable"
alias sstart="sudo systemctl start"
alias massren="py ${HOME}/clone/massren/massren -d '' $@"
alias q="py ${HOME}/s/help_scripts/ask_gpt.py -s $@"
alias f="py ${HOME}/s/help_scripts/ask_gpt.py -f $@"
alias jn="jupyter notebook &"
alias sr='source ~/.zshrc'
alias tree="tree -I 'target|debug|_*'"
alias lhost="nohup nyxt http://localhost:8080/ > /dev/null 2>&1 &"
alias tg="py ${HOME}/s/help_scripts/tg_message_to_self.py"
alias tmux="TERM='alacritty-direct' tmux"
alias obs="sudo modprobe v4l2loopback video_nr=2 card_label=\"OBS Virtual Camera\" && obs"

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
alias csg="cs ~/g"
alias cssg="cs ~/s/g"
alias csb="cs ~/Documents/Books"
alias csu="cs ~/s/utils"
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
#alias yS="yay -S --noconfirm"
yS() {
	yay -S ${@} --noconfirm && return 0
	sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak && sudo sh -c "rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist" && yay -S ${@} --noconfirm
}

alias yR="yay -R --noconfirm"
alias yRn="yay -Rns --noconfirm"
alias yG="yay -Q | rg"
alias pG="pacman -Q | rg"
alias pY="${HOME}/s/help_scripts/boring.sh"
#alias pS="yay -S --noconfirm"
#pS() {
#	'yay -S ${@} --noconfirm' || 'sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak && sudo sh -c "rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist" && yay -S ${@} --noconfirm'
#}
#alias pR="yay -R --noconfirm"
#alias pRn="yay -Rns --noconfirm"
#
alias phone-wifi="sudo nmcli dev wifi connect Valera password 12345678"
alias beep="mpv ${HOME}/Sounds/Notification.mp3"

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
. ~/notes/functions.sh
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
