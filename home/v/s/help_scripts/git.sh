# all general git shorthands

alias gu='gitui'
gg() {
	# needs to be processed first, or acceess aliases would have to be turned into functions
	prefix=""
	if [ "$1" = "p" ] || [ "$1" = "-p" ] || [ "$1" = "--prefix" ]; then
		prefix="${2}: "
		shift 2
	fi

	if [ "$1" = "t" ] || [ "$1" = "-t" ] || [ "$1" = "--tag" ]; then
		git tag -a $2 -m "$2"
		shift 2
	fi


	message="_"
	if [ -n "$1" ]; then
		message="$@"
	fi
	message="${prefix}${message}"

	#TODO!!!!: a flag for generating the commit message from git diff with a (preferrably local) fast llm model.
	#repr: f"_: {llm_output}"
	#// main empty comment should be switched to "_" from "."

	squash_if_needed=""
	if [ "$(git log -1 --pretty=format:%s)" = "_" ]; then
		squash_if_needed="--squash HEAD~1"
	fi
	git add -A && git commit ${squash_if_needed} -m "${message}" && git push --follow-tags
}
alias ggf="gg -p feat"
alias ggx="gg -p fix"
alias ggc="gg -p chore"
alias ggs="gg -p style"
alias ggt="gg -p test"
alias ggr="gg -p refactor"
alias ggp="gg -p perf"
alias ggd="gg -p docs"

# # gh aliases
gi() {
	body=""
	title=${1}
	if [ "$2" != "" ]; then
		body=${2}
		shift
	fi
	shift # so I append $@ to the actual evokation

	# auto-assign myself?
	gh issue create -t "${title}" -b "${body}" $@
}
alias gil="gh issue list"
alias gic="gh issue close -r completed"
# r for rejected
alias gir="gh issue close -r \"not planned\""
alias gid="gh issue delete --yes"
#

gc() {
	if rg -q "://" <<< "$1"; then
		url="$1"
	else
		url="https://github.com/$1" 
	fi

	if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """\
#git clone on rails.
	give repo name, it clones into /tmp or provided directory.

  ex: gc neovim/neovim
"""
		return 0
	elif [ "$#" = 1 ]; then
		split_array=$(echo "$1" | tr "/" "\n")
		filename=$(echo "$split_array" | tail -n 1)
		if [ $(pwd) = /tmp/${filename} ]; then # otherwise will delete the directory under ourselves
			cd - &>/dev/null
		fi 
		rm -rf /tmp/${filename}
		git clone --depth=1 "$url" /tmp/${filename} 1>&2
		if [ $? -ne 0 ]; then
			return 1
		fi
		cd /tmp/${filename}
		echo $(pwd)
	elif [ "$#" = 2 ]; then
		git clone --depth=1 "$url" $2
		if [ $? -ne 0 ]; then
			return 1
		fi
	fi
}


gb() {
	if [ "$1" = "nvim" ]; then
		target="neovim/neovim"
	elif [ "$1" = "eww" ]; then
		target="elkowar/eww"
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """\
#build from source helper
	Does git clone into /tmp, and then tries to build until it works.

	ex: build neovim/neovim

	some repositories have shorthands, eg: `build nvim` would work.
"""
		return 0
	else
		target="$1"
	fi

	initial_dir=$(pwd)
	target_dir=$(gc "$target")
	if [ $? -ne 0 ]; then
		return 1
	fi
	cd $target_dir

	if printf "\n\033[34mtrying just cmake\033[0m\n" && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install; then
		:
	elif printf "\n\033[34mtrying -S .\033[0m\n" && cmake -S . -B ./build && cd ./build && sudo make install; then
		:
	elif printf "\n\033[34mtrying go build ./cmd/main.go and save to /usr/local/bin/\033[0m\n" && sudo go build -o /usr/local/bin/ ./cmd/main.go; then
		:
	elif printf "\n\033[34mtrying cargo build --release\033[0m\n" && cargo build --release && sudo mv -f ./target/release/${1} /usr/local/bin/; then
		:
	elif printf "\n\033[34mtrying makepkg\033[0m\n" && makepkg -si; then
		:
	elif printf "\n\033[34mtrying meson\033[0m\n" && meson build && ninja -C build && sudo ninja -C build install; then
		:
	elif printf "\n\033[34mfuck this, asking chat gpt\033[0m\n" && ~/s/help_scripts/gpt_build.py ${target_dir}; then
		:
	else
		return 1
	fi

	cd $initial_dir
	rm -rf $target_dir
}

gn() {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """\
#git create new repo
	arg1: repository name
	arg2: --private or --public

	ex: gn my_new_repo --private
"""
		return 0
	fi
	repo_name=${1}
	if [ "$1" = "--private" ] || [ "$1" = "--public" ]; then
		repo_name=$(basename $(pwd))
	else
		shift
	fi

	git init
	git add .
	git commit -m "Initial Commit"
	gh repo create ${repo_name} ${1} --source=.
	git remote add origin https://github.com/Valera6/${repo_name}.git
	git push -u origin master
}
