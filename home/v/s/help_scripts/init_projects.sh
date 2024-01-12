#!/bin/sh

#? do I actually want the `run` thing?

can() {
	cargo new "$@"
	project_name="${!#}"
	cd "$project_name" || printf "\033[31m'can' assumes project_name being the last argument\033[0m\n"
	cp ${HOME}/.file_snippets/run.sh ./run.sh
	ln ${HOME}/.file_snippets/rustfmt.toml ./rustfmt.toml
	ln ${HOME}/.file_snippets/rust_gitignore ./.gitignore
	git add -A
	git commit -m "-- New Project Snippet --"
}

pyn() {
	mkdir "$1"
	cd "$1"
	cp ${HOME}/.file_snippets/run.sh ./run.sh
	ln ${HOME}/.file_snippets/pyproject.toml ./pyproject.toml
	ln ${HOME}/.file_snippets/python_gitignore ./.gitignore
	git init
	git add -A
	git commit -m "-- New Project Snippet --"
}

gon() {
	mkdir "$1"
	cd "$1"
	cp ${HOME}/.file_snippets/run.sh ./run.sh
	ln ${HOME}/.file_snippets/gofumpt.toml ./gofumpt.toml
	ln ${HOME}/.file_snippets/go_gitignore ./.gitignore
	git init
	git add -A
	git commit -m "-- New Project Snippet --"
}
