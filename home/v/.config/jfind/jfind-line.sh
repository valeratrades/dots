#!/bin/bash
set -e

OUTPUT="$HOME/.cache/jfind_out"
[ -f "$OUTPUT" ] && rm "$OUTPUT"

format_lines() {
    cat -n "$1" | tac | awk '{
        for (i=2; i<=NF; i++) {
            printf("%s ", $i);
        }
        printf("\n%s\n", $1);
    }'
}

jfind_command() {
    jfind --hints --select-hint
}

format_lines "$1" | jfind_command "$root" | tee "$OUTPUT"
