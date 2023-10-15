#!/bin/bash

target_dir="${HOME}/.dots"
dot_directories="
	${HOME}/.config/sway
	${HOME}/.config/eww
	${HOME}/.config/nvim
	${HOME}/.config/keyd
	/etc/keyd
	${HOME}/.config/helix
"

exclude_gitignore() {
    local dir="$1"
    local command="$2"
    while IFS= read -r line; do
        command="$command --exclude=$line"
    done < "${dir}/.gitignore"
    echo "$command"
}

for dir in $dot_directories; do
    printf "\033[34m%s\033[0m\n" "$dir"
    command="rsync -au"
    command=$(exclude_gitignore "$dir" "$command" 2>/dev/null || :)
    
    excluding="${command:9}"
		if [[ -n "$excluding" ]]; then
			echo "$excluding"
		fi

    to="$target_dir$dir"
    mkdir -p "$to"
    $command "$dir" "${to}/.."
done

date=$(date +"%Y-%m-%d %H:%M:%S")
git -C "$target_dir" add -A && git -C "$target_dir" commit -m "$date" && git -C "$target_dir" push
