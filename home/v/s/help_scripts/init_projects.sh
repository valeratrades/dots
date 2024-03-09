#!/bin/sh

can() {
	cargo new "${@}"
	project_name="${1}"
	cd "$project_name" || printf "\033[31m'can' assumes project_name being the first argument\033[0m\n"
	cp ${HOME}/.file_snippets/rust_local.sh ./.local.sh
	source ./.local.sh
	ln ${HOME}/.file_snippets/rustfmt.toml ./rustfmt.toml
	ln ${HOME}/.file_snippets/rust_gitignore ./.gitignore -f
	git add -A
	git commit -m "-- New Project Snippet --"
}

pyn() {
	mkdir "$1"
	cd "$1"
	cp ${HOME}/.file_snippets/py_local.sh ./.local.sh
	source ./.local.sh
	ln ${HOME}/.file_snippets/pyproject.toml ./pyproject.toml
	ln ${HOME}/.file_snippets/python_gitignore ./.gitignore
	cp ${HOME}/.file_snippets/py_main ./main.py &&  chmod u+x ./main.py
	git init
	git add -A
	git commit -m "-- New Project Snippet --"
}

gon() {
	mkdir "$1"
	cd "$1"
	cp ${HOME}/.file_snippets/go_local.sh ./.local.sh
	source ./.local.sh
	ln ${HOME}/.file_snippets/gofumpt.toml ./gofumpt.toml
	ln ${HOME}/.file_snippets/go_gitignore ./.gitignore
	mkdir cmd && cp ${HOME}/.file_snippets/go_main ./cmd/main.go && chmod u+x ./cmd/main.go
	git init
	git add -A
	git commit -m "-- New Project Snippet --"
	go mod init "github.com/${GITHUB_NAME}/$1"
}

lnn() {
	lake new "$@"
	cd "$1"
	cp -f ${HOME}/.file_snippets/leanpkg.toml ./leanpkg.toml
}
