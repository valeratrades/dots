dw() {
	open_after=0
	if [ "$1" = "-o" ] || [ "$1" = "--open" ]; then
		open_after=1
		shift
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """compile document on change
  Usage:
    dw document_name

  The function will start piping compiled version into zathura, if the extension is known\n"""
		return 0
	fi
	name="$1"

	for ext in "pdf" "tex" "md" "typ"; do
		if [ "${name}" = "*.${ext}" ]; then
			name="${name%.${ext}}"
			source_file="${name}"
			break
		fi
	done

	target="/tmp/${name}.pdf"

	if [ -f "${name}.typ" ]; then
		source_file="${name}.typ"
		sudo killall typst
		typst compile "$try_from" "$try_to"
		typst watch "$try_from" "$try_to" > /dev/null 2>&1 &

	elif [ -f "${name}.tex" ]; then
		source_file="${name}.tex"

		printf "\033[31mTODO\n\033[0m"
	elif [ -f "${name}.md" ]; then
		source_file="${name}.md"

		printf "\033[31mTODO\n\033[0m"	
	else
		printf "\033[31mNo documents found with supported extensions and provided name\033[0m\n"
	fi

	zathura "$target" > /dev/null 2>&1 &
	if [ $open_after -eq 1 ]; then
		nvim "$source_file"
	fi
}

