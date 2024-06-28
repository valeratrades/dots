cwd=$(/bin/pwd -P)
sed '/^$/d' ~/.config/jfind/projects | while read line 
do
    if [[ "$cwd" == "$line"* ]]; then
        echo "$line"
        break;
    fi
done
