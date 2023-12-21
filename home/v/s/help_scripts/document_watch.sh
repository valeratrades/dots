# for document watch
dw() {
	if [ -z "$1" ]; then
		name="main"
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf """compile document on change
  Usage:
    dw document_name

  The function will start piping compiled version into zathura, if the extension is known\n"""
		return 0
	else
		name="$1"
	fi

	if [ -f "${name}.typ" ]; then
		try_from="${name}.typ"
		try_to="${name}.pdf"
		sudo killall typst
		typst compile "$try_from" "$try_to"
		typst watch "$try_from" "$try_to" > /dev/null 2>&1 &
		zathura "$try_to" > /dev/null 2>&1 &
		nvim "$try_from"
	elif [ -f "${name}.tex" ]; then
		printf "\033[31mTODO\n\033[0m"
	elif [ -f "${name}.md" ]; then
		printf "\033[31mTODO\n\033[0m"	
	else
		printf "\033[31mNo documents found with supported extensions and provided name\033[0m\n"
	fi
}

