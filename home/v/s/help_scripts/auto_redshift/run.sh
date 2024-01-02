#!/bin/sh

alias b="cargo build --release && sudo mv ./target/release/auto_redshift /usr/local/bin/"
alias r="cargo run -- 7:00"
