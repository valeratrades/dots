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
cs() {
	cd "$@" || return 1
	. "./.local.sh" > /dev/null 2>&1 || :
	sl
}

# # cargo
cb() {
	cargo machete
	guess_name=$(basename $(pwd))
	if [ -f "./src/lib.rs" ]; then
		return 0
	fi
	cargo build --release && sudo mv ./target/release/${guess_name} /usr/local/bin/
}
cq() {
	local stderr_temp_file=$(mktemp)
	cargo --color always --quiet $@ 2>"$stderr_temp_file"
	local exit_status=$?

	if [ $exit_status!=0 ]; then
		# note that when running `cargo check`, the warnings are piped to stdout, so still will be printed. However, we probably want that for `check`.
		cat "$stderr_temp_file" 1>&2
	fi

	rm -f "$stderr_temp_file"
	return $exit_status
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

alias fd="fd -I"         # Creates an alias 'fd' for 'fd -I', ignoring .gitignore and .ignore files.
alias rg="rg -I --glob '!.git'" # Creates an alias 'rg' for 'rg -I --glob '!.git'', ignoring case sensitivity and .git directories.
alias ureload="pkill -u $(whoami)" # Creates an alias 'ureload' to kill all processes of the current user.
alias rf="sudo rm -rf"
alias srf="sudo rm -rf"
alias za="zathura"
alias zp="zathura --mode presentation"
alias z="zoxide"
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
alias mvt="ls -t | head -n 1 | xargs -I {} mv {}" # although, not sure if actually needed, as I could just write out `${command} "$(ls -t | head -n 1)" ${path}`, and get the same, but for the general case.
alias ll="exa -lA"
alias sound="qpwgraph"

# # cli_translate
alias ttf="cli_translate -f"
alias tte="cli_translate -e"
alias ttr="cli_translate -r"
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
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
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
csu() {
	_path="${HOME}/uni/"
	if [ -n "$1" ]; then
		_path+="${1}"
	fi
	cs $_path
}
# }}}

# # editor
alias ec="e ~/.config/nvim"
alias es="nvim ~/.zshrc"
alias ezt="e ~/.config/zsh/theme.zsh"
#? can I do this for rust and go? (maybe something with relative paths there)
alias epy="e ~/envs/Python/lib/python3.11/site-packages" 
alias et="nvim /tmp/a_temporary_note.md -c 'nnoremap q gg^vG^g_\"+y:qa!<CR>' -c 'startinsert'"
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
beep() {	
	if [ $# = 1 ]; then
		if [ "$1" = "l" ] || [ "$1" = "-l" ] || [ "$1" = "loud" ]; then # loud beep
			mute=$(pamixer --get-mute)
			if [ "$mute" = "true" ]; then
				pamixer --unmute
			fi

			volume=$(pamixer --get-volume)
			pamixer --set-volume 100
			mpv ${HOME}/Sounds/Notification.mp3 > /dev/null 2>&1
			pamixer --set-volume $volume

			if [ "$mute" = "true" ]; then
				pamixer --mute
			fi

			notify-send "beep"
			return 0
		else
			printf "Only takes \"l\" || \"loud\" || \"-l\". Provided: $1\n"
			return 1
		fi
	else # normal beep
		mpv ${HOME}/Sounds/Notification.mp3 > /dev/null 2>&1
		return 0
	fi
}	

# # cargo
alias c="cargo"
# for cargo timed
ct() {
	cleanup() {
		eww update cargo_compiling=false
	}
	trap cleanup EXIT
	trap cleanup INT

	starttime=$(date +%s)
	run_after="false"
	eww update cargo_compiling=true

	if [ $1 = "c" ]; then
		shift
		${HOME}/s/help_scripts/stop_all_run_cargo.sh lcheck ${@}
	elif [ $1 = "r" ]; then
		shift
		${HOME}/s/help_scripts/stop_all_run_cargo.sh lbuild ${@}
		run_after="true"
	else
		printf "Only takes \"c\" or \"r\". Provided: $1\n"
	fi
	endtime=$(date +%s)
	cleanup

	elapsedtime=$((endtime - starttime))
	if [ $elapsedtime -gt 20 ]; then
		beep
		notify-send "cargo compiled"
	fi

	if [ "$run_after" = "true" ]; then
		cargo run ${@}
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
# what the fuck they're doing other there
. /etc/profile.d/google-cloud-cli.sh

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
