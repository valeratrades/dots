#!/bin/sh
# uninit: placeholder, class error
# outdated: day_ev, class warn
# default: day_ev, class info

MAX_WITHOUT_UPDATE=1
DEFAULT_CONTENT="_"

if day_ev=$(todo manual print-ev); then
	content="$day_ev"
	if last_update=$(todo manual last-ev-update-hours); then
		if [ "$MAX_WITHOUT_UPDATE" -le "$last_update" ]; then
			class="warn"
		else
			class="info"
		fi
	else
		content="panicked"
		class="error"
	fi
else
	content="$DEFAULT_CONTENT"
	class="warn"
fi


echo "{\"content\": \"${content}\", \"class\": \"$class\"}"
