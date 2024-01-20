#!/bin/sh

greedy="discord telegram"

pause_greedy() {
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

pause_greedy > /dev/null 2>&1
cargo "$@"
