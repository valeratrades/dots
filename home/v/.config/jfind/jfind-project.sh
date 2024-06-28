#!/bin/bash
set -e

match_project() {
    cwd=$(/bin/pwd -P)
    sed '/^$/d' ~/.config/jfind/projects | while read line 
    do
        if [[ "$cwd" == "$line"* ]]; then
            echo "$line"
            break;
        fi
    done
}

project_root=$(match_project)

$HOME/.config/jfind/jfind-recursive.sh "$project_root"
