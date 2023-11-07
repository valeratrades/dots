#!/bin/sh

wallpaper_dir="${HOME}/Wallpapers"
#------------------------------------------------------------------------------

file_with_current_wallpaper_ordinal="${HOME}/tmp/.current_wallpaper_ordinal"
mkdir -p $(dirname $file_with_current_wallpaper_ordinal)

if [ -f "$file_with_current_wallpaper_ordinal" ]; then
	CURRENT_WALLPAPER_ORDINAL=$(cat "$file_with_current_wallpaper_ordinal")
else
	CURRENT_WALLPAPER_ORDINAL=1
fi

wallpapers=$(ls "${wallpaper_dir}" | grep -v '^\.' | sort)

wallpaper_count=0
for wallpaper in $wallpapers; do
  wallpaper_count=$((wallpaper_count + 1))
done

get_wallpaper_by_index() {
    i=1
    for wallpaper in $wallpapers; do
        if [ $i -eq $CURRENT_WALLPAPER_ORDINAL ]; then
            echo $wallpaper
            return
        fi
        i=$((i + 1))
    done
}

update_wallpaper() {
	wallpaper=$(get_wallpaper_by_index)
	swaymsg output '*' background "${wallpaper_dir}/${wallpaper}" fill
	echo $CURRENT_WALLPAPER_ORDINAL > "$file_with_current_wallpaper_ordinal"
}

f() {
	CURRENT_WALLPAPER_ORDINAL=$((CURRENT_WALLPAPER_ORDINAL % wallpaper_count + 1))
	update_wallpaper
}
b() {
	CURRENT_WALLPAPER_ORDINAL=$((CURRENT_WALLPAPER_ORDINAL - 1))
	if [ $CURRENT_WALLPAPER_ORDINAL -le 0 ]; then
		CURRENT_WALLPAPER_ORDINAL=$wallpaper_count
	fi
	update_wallpaper
}
case "$1" in
    f) f ;;
    b) b ;;
    *) printf "\033[31mPossible commands: [ f, b ]\033[0m\n" ;;
esac
