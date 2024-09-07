cpp_watch() {
	# Check if inotifywait is installed
	if ! command -v inotifywait >/dev/null 2>&1; then
		echo "inotifywait not found, attempting to install..."
		if command -v apt-get >/dev/null 2>&1; then
			sudo apt-get update && sudo apt-get install -y inotify-tools
		elif command -v dnf >/dev/null 2>&1; then
			sudo dnf install -y inotify-tools
		elif command -v pacman >/dev/null 2>&1; then
			sudo pacman -S inotify-tools --noconfirm
		else
			echo "Package manager not found or unsupported. Please install inotify-tools manually."
			return 1
		fi
	fi

	while :; do
		clear
		g++ -g -o ./target/debug/$(basename $(pwd)) ./src/*.cpp
		inotifywait -e modify,create,delete ./src/*.cpp 2>&1 | grep -v -e "Setting up watches." -e "Watches established." # to prevent annoying confirmation
	done
}
