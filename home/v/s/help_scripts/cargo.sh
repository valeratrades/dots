alias caclip="cargo clippy --tests -- -Dclippy::all"
alias ctn="cargo test -- --nocapture"
alias cpad="cargo publish --allow-dirty"

cb() {
	guess_name=$(basename $(pwd))
	if [ -n "$1" ]; then
		if [ "$1" = "-d" ] || [ "$1" = "--dev" ]; then
			path_to_build="target/debug/${guess_name}"
			cargo build --profile dev
		else
			return 1
		fi
	else
		path_to_build="target/release/${guess_name}"
		cargo build --release
	fi
	
	if [ -f "./${path_to_build}" ]; then
		sudo cp -f "./${path_to_build}" /usr/local/bin/
	elif [ -f "../${path_to_build}" ]; then
		sudo cp -f "../${path_to_build}" /usr/local/bin/
	else
		printf "Could not guess the built binary location\n"
		return 1
	fi
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

cpublish() {
	cargo release --no-confirm --execute ${@}
}


pause_greedy() {
	greedy="discord telegram"

	trap 'for pid in $paused_pids; do [ -e /proc/$pid ] && kill -CONT $pid; done; exit 1' INT
	trap 'for pid in $paused_pids; do [ -e /proc/$pid ] && kill -CONT $pid; done' EXIT

	paused_pids=""

	for app in $greedy; do
		app_pids=$(ps aux | awk -v app="$app" '$0 ~ app {print $2}')
		for pid in $app_pids; do
			state=$(ps -o state= -p $pid)
			if [ "$state" != "T" ]; then
				paused_pids="$paused_pids $pid"
				kill -STOP $pid
			fi
		done
	done
}
stop_all_run_cargo() {
	pause_greedy > /dev/null 2>&1
	cargo "$@"
}

c() {
	todo manual counter-step --dev-runs;
	cargo ${@}
}

cw() {
	# not sure is duplication of processes is the best way to do it, but eh good enough
	cargo watch -- todo manual counter-step --cargo-watch >/dev/null 2>&1 &
	pid1=$!

	cleanup() {
		kill $pid1 2>/dev/null
		wait $pid1 2>/dev/null
		trap - INT
	}

	trap cleanup INT

	cargo watch -c -x "b"
	cleanup
}
alias cu="cargo clean && cargo update"
#TODO: want `-Z timeings`, `llvm-lines` and `machete` to be ran and shown
alias c_debug_build="cargo "
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

	if [ "$#" = "0" ]; then
		ct r
		run_after="false"
	elif [ $1 = "r" ]; then
		shift
		stop_all_run_cargo lbuild ${@}
		run_after="true"
	elif [ $1 = "b" ]; then
		shift
		cargo build --release ${@}
	elif [ $1 = "c" ]; then
		shift
		stop_all_run_cargo lcheck ${@}
	else
		printf "Only takes \"c\", \"r\" or \"b\". Provided: $1\n"
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
