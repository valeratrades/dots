#!/bin/sh
#TODO: add presets. For example, --clap on `can` would add clap with "derive" to dependencies, then the main func would have hell world example specifically with clap, so I don't have to remember all the intricasies

#TODO: add github hook for copying config file, (assume "~/.config/${same_name_as_crate}.toml"), if it exists

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
	cat ${HOME}/.file_snippets/readme/badges/${lang}.md | reasonable_envsubst - >> README.md
	mkdir -p docs/.assets
	cat ${HOME}/.file_snippets/docs/ARCHITECTURE.md > docs/ARCHITECTURE.md
}

shared_after() {
	# $1: project_name
	# $2: lang

	project_name="${1}"
	lang="${2}" # rs, py, go

	git init
	cp ${HOME}/.file_snippets/.git/hooks/pre-commit .git/hooks/pre-commit && chmod u+x .git/hooks/pre-commit

	fd --type f --exclude .git | rg -v --file <(git ls-files --others --ignored --exclude-standard) | while IFS= read -r file; do
		sed -i "s/PROJECT_NAME_PLACEHOLDER/${project_name}/g" "$file"
	done
	sed -i "s/PROJECT_NAME_PLACEHOLDER/${project_name}/g" ".git/hooks/pre-commit"

	cat ${HOME}/.file_snippets/readme/footer.md >> README.md
	sudo ln ${HOME}/.file_snippets/readme/LICENSE-APACHE ./LICENSE-APACHE
	sudo ln ${HOME}/.file_snippets/readme/LICENSE-MIT ./LICENSE-MIT

	git add -A
	git commit -m "-- New Project Snippet --"
	git branch "release"
	set +e
}

can() {
	preset=""
	if [ "${1#--}" != "$1" ]; then
		preset="${1}"
		shift
	fi
	cargo new "${@}"
	lang="rs"
	shared_before ${1} ${lang}

	sudo ln ${HOME}/.file_snippets/${lang}/rustfmt.toml ./rustfmt.toml
	sudo ln ${HOME}/.file_snippets/${lang}/deny.toml ./deny.toml
	# removes the [dependencies] line, as it's added by the snippet
	sed -i '$d' Cargo.toml
	cat ${HOME}/.file_snippets/${lang}/default_dependencies.toml >> Cargo.toml

	touch src/lib.${lang}
	if [ "$preset" = "--clap" ]; then
		cp -f ${HOME}/.file_snippets/presets/${lang}/clap/main ./src/main.${lang}
		cat ${HOME}/.file_snippets/presets/${lang}/clap/additional_dependencies.toml >> Cargo.toml
	else
		cp -f ${HOME}/.file_snippets/presets/${lang}/main ./src/main.${lang}
	fi

	mkdir -p .github/workflows && cp -r ${HOME}/.file_snippets/.github/workflows/${lang}/ci.yml ./.github/workflows/ci.yml
	mkdir tests && cp -r ${HOME}/.file_snippets/tests/${lang}/* ./tests/

	shared_after ${1} ${lang}
}

pyn() {
	mkdir "$1"
	lang="py"
	shared_before ${1} ${lang}

	sudo ln ${HOME}/.file_snippets/${lang}/pyproject.toml ./pyproject.toml
	mkdir ./src
	cp ${HOME}/.file_snippets/presets/${lang}/main ./src/main.${lang} &&  chmod u+x ./src/main.${lang}

	shared_after ${1} ${lang}
}

gon() {
	mkdir "$1"
	lang="go"
	shared_before ${1} ${lang}

	sudo ln ${HOME}/.file_snippets/${lang}/gofumpt.toml ./gofumpt.toml
	# go's convention of cmd/ as the access point prevents placeing this operation in shared_before
	mkdir cmd && cp ${HOME}/.file_snippets/presets/${lang}/main ./cmd/main.${lang} && chmod u+x ./cmd/main.${lang}

	shared_after ${1} ${lang}
	go mod init "github.com/${GITHUB_NAME}/$1"
}

lnn() {
	lake new "$@"
	shared_before ${1}

	cp -f ${HOME}/.file_snippets/leanpkg.toml ./leanpkg.toml
}
