#!/bin/sh

while true; do
	port=$(shuf -i 49152-65535 -n 1)

		# Check if the port is in use (suppressing stderr)
		if ! ss -tulwn | grep -q ":$port " 2>/dev/null; then
			echo $port
			break
		fi
done
