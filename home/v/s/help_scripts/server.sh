#!/bin/env sh

local README="""\
#server ssh script
  do \033[34mserver\033[0m to ssh into vincent
  do \033[34mserver disconnect\033[0m to close all sessions"""

vincent_ssh() {
	export VINCENT_SSH_PASSWORD VINCENT_SSH_HOST
	expect -c "
	spawn ssh $VINCENT_SSH_HOST
	expect -re \".*password: \"
	send \"$VINCENT_SSH_PASSWORD\r\"
	interact
	"
}
vincent_connect() {
	export VINCENT_SERVER_USERNAME VINCENT_SERVER_PASSWORD
	expect -c "
	spawn sudo openvpn --config ${HOME}/.config/openvpn/client.ovpn;
	expect \"Enter Auth Username: \";
	send \"\$env(VINCENT_SERVER_USERNAME)\r\";
	expect \"Enter Auth Password: \";
	send \"\$env(VINCENT_SERVER_PASSWORD)\r\";
	interact
	"
}

server() {
	if [ -z "$1" ] || [ "$1" = "ssh" ]; then
		#BUG: doesn't work in sequence. The next `expect` command hops onto the previous `expect` session no matter what.
		#if [ "$(eww get openvpn_poll)" != "1" ]; then
		#	vincent_connect &
		#fi
		vincent_ssh
	elif [ "$1" = "connect" ]; then
		vincent_connect &
	elif [ "$1" = "disconnect" ]; then
		sudo killall openvpn
	elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
		printf "${README}\n"
	else
		printf "${README}\n"
		return 1
	fi
}
