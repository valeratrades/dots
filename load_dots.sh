#!/bin/bash
dots() {
	current_dir=$(pwd)
	cd /tmp
	rm -rf ./dots
	git clone --depth=1 https://github.com/valeratrades/dots
	cd dots
	./main.sh load
	cd ..
	rm -rf ./dots
	cd $current_dir
}
dots
