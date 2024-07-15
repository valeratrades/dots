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
	tmux send-keys -t "${SESSION_NAME}:build.0" 'cs .' Enter
	tmux split-window -h -t "${SESSION_NAME}:build"
	tmux send-keys -t "${SESSION_NAME}:build.1" 'cs .' Enter
	tmux split-window -v -t "${SESSION_NAME}:build.1"
	tmux send-keys -t "${SESSION_NAME}:build.2" 'cs .; clear' Enter
	tmux send-keys -t "${SESSION_NAME}:build.2" 'gil' Enter
	tmux send-keys -t "${SESSION_NAME}:build.2" 'gifa' Enter
	tmux resize-pane -t "${SESSION_NAME}:build.2" -D 30
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
