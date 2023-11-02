#!/bin/sh
# Following is a standard set of rust run shortcuts

alias b="cargo build --release"
alias r="cargo run"
alias t="cargo test"

# f for full
alias f="cargo build --release && my_todo"
## e for executable
#alias e="my_todo"
alias g="git add -A && git commit -m '.' && git push"
alias gr="git reset --hard"
