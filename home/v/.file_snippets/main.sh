#!/bin/sh
#TODO: add presets. For example, --clap on `can` would add clap with "derive" to dependencies, then the main func would have hell world example specifically with clap, so I don't have to remember all the intricasies

#TODO: add github hook for copying config file (assume "${same_name_as_crate}.toml") if it exists

shared_before() {
	# $1: project_name
	# $2: lang

	project_name="${1}"
	cd "$project_name" || printf "\033[31mproject_name has to be passed as the first argument\033[0m\n"

	lang="${2}" # rs, py, go

	cp ${HOME}/.file_snippets/local_sh/${lang}.sh ./.local.sh
	source ./.local.sh

	rm -f ./.gitignore # created automatically by cargo new
	cat ${HOME}/.file_snippets/gitignore/shared > ./.gitignore
	echo "\n" >> ./.gitignore
	cat ${HOME}/.file_snippets/gitignore/${lang} >> ./.gitignore

	cat ${HOME}/.file_snippets/readme/header.md > README.md
	cat ${HOME}/.file_snippets/readme/badges/${lang} | reasonable_envsubst - >> README.md
	mkdir -p docs/.assets
	cat ${HOME}/.file_snippets/docs/ARCHITECTURE.md > docs/ARCHITECTURE.md
}

shared_after() {
	# $1: project_name
	# $2: lang

	project_name="${1}"
	lang="${2}" # rust, py, go
	touch TODO.md

	sed -i "s/PROJECT_NAME_PLACEHOLDER/${project_name}/g" README.md
	cat ${HOME}/.file_snippets/readme/footer.md >> README.md
	sudo ln ${HOME}/.file_snippets/readme/LICENSE-APACHE ./LICENSE-APACHE
	sudo ln ${HOME}/.file_snippets/readme/LICENSE-MIT ./LICENSE-MIT

	git add -A
	git commit -m "-- New Project Snippet --"
	git branch "release"
	set +e
}

can() {
	cargo new "${@}"
	lang="rs"
	shared_before ${1} ${lang}

	sudo ln ${HOME}/.file_snippets/${lang}/rustfmt.toml ./rustfmt.toml
	sudo ln ${HOME}/.file_snippets/${lang}/deny.toml ./deny.toml
	cat ${HOME}/.file_snippets/${lang}/default_dependencies >> Cargo.toml
	cp -f ${HOME}/.file_snippets/main/${lang} ./src/main.${lang} && chmod u+x ./src/main.${lang}
	mkdir -p .github/workflows && cp -r ${HOME}/.file_snippets/.github/workflows/${lang}/ci.yml ./.github/workflows/ci.yml
	mkdir tests && cp ${HOME}/.file_snippets/tests/${lang}/* ./tests/

	shared_after ${1} ${lang}
}

pyn() {
	mkdir "$1"
	lang="py"
	shared_before ${1} ${lang}

	sudo ln ${HOME}/.file_snippets/${lang}/pyproject.toml ./pyproject.toml
	mkdir ./src
	cp ${HOME}/.file_snippets/main/${lang} ./src/main.${lang} &&  chmod u+x ./src/main.${lang}

	git init
	shared_after ${1} ${lang}
}

gon() {
	mkdir "$1"
	lang="go"
	shared_before ${1} ${lang}

	sudo ln ${HOME}/.file_snippets/${lang}/gofumpt.toml ./gofumpt.toml
	# go's convention of cmd/ as the access point prevents placeing this operation in shared_before
	mkdir cmd && cp ${HOME}/.file_snippets/main/${lang} ./cmd/main.${lang} && chmod u+x ./cmd/main.${lang}

	git init
	shared_after ${1} ${lang}
	go mod init "github.com/${GITHUB_NAME}/$1"
}

lnn() {
	lake new "$@"
	shared_before ${1}

	cp -f ${HOME}/.file_snippets/leanpkg.toml ./leanpkg.toml
}
