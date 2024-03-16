#!/bin/sh

shared_before() {
	# $1: project_name
	# $2: lang

	project_name="${1}"
	cd "$project_name" || printf "\033[31mproject_name has to be passed as the first argument\033[0m\n"

	lang="${2}" # rust, py, go

	cp ${HOME}/.file_snippets/local_sh/${lang}.sh ./.local.sh
	source ./.local.sh

	rm -f ./.gitignore # created automatically by cargo new
	touch ./.gitignore
	cat ${HOME}/.file_snippets/gitignore/shared > ./.gitignore
	echo "\n" >> ./.gitignore
	cat ${HOME}/.file_snippets/gitignore/${lang} >> ./.gitignore
}

shared_after() {
	# $1: project_name
	# $2: lang

	project_name="${1}"
	lang="${2}" # rust, py, go
	touch TODO.md

	touch README.md
	notify-send ${project_name}
	echo "# ${project_name}\n" >> README.md
	cat ${HOME}/.file_snippets/readme/licenses.md > README.md
	sudo ln ${HOME}/.file_snippets/readme/LICENSE-APACHE ./LICENSE-APACHE
	sudo ln ${HOME}/.file_snippets/readme/LICENSE-MIT ./LICENSE-MIT

	git add -A
	git commit -m "-- New Project Snippet --"
}

can() {
	cargo new "${@}"
	shared_before ${1} "rust"

	sudo ln ${HOME}/.file_snippets/rustfmt.toml ./rustfmt.toml
	sudo ln ${HOME}/.file_snippets/deny.toml ./deny.toml

	shared_after ${1} "rust"
}

pyn() {
	mkdir "$1"
	shared_before ${1} "py"

	sudo ln ${HOME}/.file_snippets/pyproject.toml ./pyproject.toml
	cp ${HOME}/.file_snippets/py_main ./main.py &&  chmod u+x ./main.py

	git init
	shared_after ${1} "py"
}

gon() {
	mkdir "$1"
	shared_before ${1} "go"

	sudo ln ${HOME}/.file_snippets/gofumpt.toml ./gofumpt.toml
	mkdir cmd && cp ${HOME}/.file_snippets/go_main ./cmd/main.go && chmod u+x ./cmd/main.go

	git init
	shared_after ${1} "go"
	go mod init "github.com/${GITHUB_NAME}/$1"
}

lnn() {
	lake new "$@"
	shared_before ${1}

	cp -f ${HOME}/.file_snippets/leanpkg.toml ./leanpkg.toml
}
