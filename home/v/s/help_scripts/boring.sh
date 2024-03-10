#!/bin/sh

sync()  {
	(${HOME}/.dots/main.sh sync "$@" && printf "\033[32msynced dots\033[0m\n" || printf "\033[34mremote repository is up to date\033[0m\n") &
	PID1=$!
	(sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak && sudo sh -c "rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist" && printf "\033[32mupdated mirrors\033[0m\n" || printf "\033[31mupdating mirrors failed\033[0m\n") &
	PID2=$!

	wait $PID1 $PID2
	sudo pacman -Syu --noconfirm && printf "\033[32mupdated system\033[0m\n" || printf "\033[31mpacman -Syu failed\033[0m\n"
	return 0
}

sync "$@"
