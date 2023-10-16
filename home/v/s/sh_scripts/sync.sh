#!/bin/bash

function pY() {
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    sudo sh -c "rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist"
    echo "\033[32mupdated mirrors\033[0m"

    # /home/v/.dots/sync_git.sh
    echo "\033[32msynced dots\033[0m"

    sudo pacman -Rns --noconfirm ttf-jetbrains-mono-nerd
    sudo pacman -Syu --noconfirm
    echo "\033[32mupdated system\033[0m"
}

