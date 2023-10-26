#!/bin/sh

cn() {
	cargo new "$@"
	project_name="${!#}"
	cd "$project_name" || printf "\033[31m'cn' assumes project_name being the last argument\033[0m\n"
	cp ${HOME}/.file_snippets/run.sh ./run.sh
	cp ${HOME}/.file_snippets/rustfmt.toml ./rustfmt.toml
	cp ${HOME}/.file_snippets/rust_gitignore ./.gitignore
	git add -A
	git commit -m "-- New Project Snippet --"
}

pn() {
	mkdir "$1"
	cd "$1"
	cp ${HOME}/.file_snippets/run.sh ./run.sh
	git init
	git add -A
	git commit -m "-- New Project Snippet --"
}
