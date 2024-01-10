# all general git shorthands

alias gu='gitui'
gg() {
	message="."
	if [ -n "$1" ]; then
		message="$@"
	fi
	git add -A && git commit -m "$message" && git push

	if [ -f "./Cargo.toml" ]; then
		cb > /dev/null 2>&1
	fi
}
alias gr="git reset --hard"

gc() {
	if rg -q "://" <<< "$1"; then
		url="$1"
	else
		url="https://github.com/$1" 
	fi

	if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """\
#git clone on rails
  for more info, cat ~/s/help_scripts/git.sh

  ex: gc neovim/neovim
"""
		return 0
	elif [ "$#" = 1 ]; then
		split_array=$(echo "$1" | tr "/" "\n")
		filename=$(echo "$split_array" | tail -n 1)
		cd /tmp && rm -rf ./${filename} && git clone --depth=1 "$url" 1>&2
		cd "$filename"
		echo $(pwd)
	elif [ "$#" = 2 ]; then
		git clone --depth=1 "$url" $2
	fi
}

gb() {
	if [ "$1" = "nvim" ]; then
		target="neovim/neovim"
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """\
#build from source helper
	Does git clone into /tmp, and then tries to build with cmake.

	ex: build neovim/neovim

	some repositories have shorthands, eg: build nvim would work.
"""
		return 0
	else
		target="$1"
	fi

	initial_dir=$(pwd)
	target_dir=$(gc "$target")
	cd $target_dir

	# # Try cmake
	if printf "\n\033[34mtrying just cmake\033[0m\n" && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install; then
    :
  elif printf "\n\033[34mtrying -S .\033[0m\n" && cmake -S . -B ./build && cd ./build && sudo make install; then
    :
	elif printf "\n\033[34mtrying go build ./cmd/main.go and save to /usr/local/bin/\033[0m\n" && sudo go build -o /usr/local/bin/ ./cmd/main.go; then
		:
  elif printf "\n\033[34mtrying cargo build --release\033[0m\n" && cargo build --release; then
    :
  else
    return 1
  fi
	#
	return 1

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
	elif [ "$#" = 2 ]; then
		git init
		git add .
		git commit -m "Initial Commit"
		gh repo create ${1} ${2} --source=.
		git remote add origin https://github.com/Valera6/${1}.git
		git push -u origin master
	else
		return 1
	fi
}
