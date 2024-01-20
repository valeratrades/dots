#!/bin/sh
query=$(echo "info E8:EE:CC:36:53:49" | bluetoothctl)

case "$query" in
  *"Connected: yes"*)
    output=""
    
    if pactl list sources | grep -q "NoiseTorch"; then
      noisetorch="on"
    else
      noisetorch="off"
    fi
    
    case "$noisetorch" in
      "on")
        output="${output}"
      ;;
    esac

    echo "$output"
  ;;
  *)
    echo ""
  ;;
esac

