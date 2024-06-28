#!/bin/bash
set -e

read_sessions() {
    awk '{print $1; $1 = ""; $2 = ""; print $3}' \
        ~/.config/tmux/sessions
}

jfind_command() {
    jfind \
        --query-position=top \
        --external-border \
        --hints \
        --history="~/.cache/jfind-history/sessions"
}

read_sessions | jfind_command
