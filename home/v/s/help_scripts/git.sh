# all general git shorthands

alias gu='gitui'
gg() {
	if [ "$1" = "t" ] || [ "$1" = "-t" ] || [ "$1" = "tag" ]; then
		git tag -a $2 -m "$2"
		shift 2
	fi

	message="."
	if [ -n "$1" ]; then
		message="$@"
		#TODO!!!!!!: squash all the previous sequential commits with "." into one here.
	fi
	git add -A && git commit -m "$message" && git push --follow-tags

	if [ -f "./Cargo.toml" ]; then
		current_branch=$(git branch --show-current)
		if [ "$current_branch" = "master" ] || [ "$current_branch" = "release" ] || [ "$current_branch" = "stable" ]; then
			cb > /dev/null 2>&1
		fi
	fi
}
alias ggf="gg feat:"
alias ggx="gg fix:"
alias ggc="gg chore:"
alias ggs="gg style:"
alias ggt="gg test:"
alias ggr="gg refactor:"
alias ggp="gg perf:"
alias ggd="gg docs:"

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
