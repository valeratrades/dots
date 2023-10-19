#!/bin/sh

while :; do case $1 in
    --getsavefilename) file="$2" break ;;
    --version) printf ""; exit ;;
    --*) shift ;;
    *) break ;;
esac done

file="${file##/*/}"

st -c picker sh -c "nnn -J -p - '$file' | awk '{ print system(\"[ -d '\''\"\$0\"'\'' ]\") ? \$0 : \$0\"/$file\" }' > /proc/$$/fd/1"
