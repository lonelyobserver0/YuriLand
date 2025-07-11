#!/bin/bash

OUT_FILE="/tmp/hyprlock_mpris.txt"

while true; do
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    status=$(playerctl status 2>/dev/null)

    if [[ -n "$title" && -n "$artist" ]]; then
        if [[ "$status" == "Playing" ]]; then
            icon=""
        elif [[ "$status" == "Paused" ]]; then
            icon=""
        else
            icon=""
        fi

        echo "$icon  $artist - $title" > "$OUT_FILE"
    else
        echo "" > "$OUT_FILE"
    fi

    sleep 2
done
