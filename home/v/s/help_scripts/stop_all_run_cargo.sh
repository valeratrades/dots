#!/bin/bash

trap 'for pid in "${paused_pids[@]}"; do kill -CONT $pid; done; exit 1' INT
trap 'for pid in "${paused_pids[@]}"; do kill -CONT $pid; done' EXIT

apps=("discord" "chrome")
paused_pids=()

for app in "${apps[@]}"; do
  app_pids=$(ps aux | rg "$app" | awk '{print $2}')
  for pid in $app_pids; do
    state=$(ps -ho state -p $pid)
    if [ "$state" != "T" ]; then
      paused_pids+=($pid)
      kill -STOP $pid
    fi
  done
done

cargo "$@" 
