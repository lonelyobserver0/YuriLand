#!/bin/bash

# Dimensioni desiderate
WIDTH=900
HEIGHT=600

while true; do
    # Prende info della finestra attiva
    wininfo=$(hyprctl activewindow -j 2>/dev/null)
    [[ -z "$wininfo" ]] && sleep 0.5 && continue

    isfloating=$(echo "$wininfo" | jq -r '.floating')
    wid=$(echo "$wininfo" | jq -r '.address')

    if [[ "$isfloating" == "true" && -n "$wid" ]]; then
        # Ridimensiona la finestra
        hyprctl dispatch resizewindowpixel "$wid" "$WIDTH" "$HEIGHT"

        # Ottieni dimensione monitor e posizione
        monitor=$(echo "$wininfo" | jq -r '.monitor')
        moninfo=$(hyprctl monitors -j | jq ".[$monitor]")

        mon_x=$(echo "$moninfo" | jq -r '.x')
        mon_y=$(echo "$moninfo" | jq -r '.y')
        mon_w=$(echo "$moninfo" | jq -r '.width')
        mon_h=$(echo "$moninfo" | jq -r '.height')

        # Calcola posizione centrata
        new_x=$(( mon_x + (mon_w - WIDTH) / 2 ))
        new_y=$(( mon_y + (mon_h - HEIGHT) / 2 ))

        # Sposta la finestra
        hyprctl dispatch movewindowpixel "$wid" "$new_x" "$new_y"
    fi

    sleep 0.5
done
