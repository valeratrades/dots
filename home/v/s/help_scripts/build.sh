local README="""\
#build from source helper
  Call build with the name of the target.
  Only works with those I cared to include though.

	ex:
	build nvim"""

build() {
	initial_dir=$(pwd)
	cd /tmp
	
	if [ "$1" = "nvim" ] || [ "$1" = "neovim" ]; then
		git clone --depth=1 https://github.com/neovim/neovim
		cd neovim
		make CMAKE_BUILD_TYPE=RelWithDebInfo
		sudo make install
		cd ..
		rm -rf ./neovim
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf "${README}\n"
	else
		printf "${README}\n"
		return 1
	fi

	cd $initial_dir
}
