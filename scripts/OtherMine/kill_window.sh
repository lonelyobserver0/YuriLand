#!/bin/bash
hyprctl clients -j | jq -r '.[] | "\(.title) [\(.address)]"' | \
wofi --dmenu -p "Chiudi finestra:" | \
grep -o '\[.*\]' | tr -d '[]' | \
xargs -r hyprctl dispatch killwindow address
