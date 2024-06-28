#!/bin/bash
set -e

OUTPUT="$HOME/.cache/jfind_out"
[ -f "$OUTPUT" ] && rm "$OUTPUT"

read_sources() {
    sed '/^$/d' ~/.config/jfind/sources
}

jfind_command() {
    jfind \
        $1 \
        --hints \
        --select-hint \
        --history=~/.cache/jfind-history/sources
}

read_sources | jfind_command "$1" | tee "$OUTPUT"
