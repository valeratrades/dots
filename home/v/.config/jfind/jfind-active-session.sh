#!/bin/bash
set -e

jfind_command() {
    ~/.bin/jfind \
        --hints \
        --history=$HOME/.cache/jfind-history/active-session \
        --accept-non-match
}

format_sessions() {
    tmux list-sessions -F "#S\\n#{session_path} [#{session_windows} windows]"
}

format_sessions | sed 's/\\n/\n/' | jfind_command

