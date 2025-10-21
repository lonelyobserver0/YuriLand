#!/bin/bash

# Script per aprire un menu contestuale solo sul desktop in Hyprland

# Ottieni la finestra attiva
active_window=$(hyprctl activewindow -j | jq -r '.address')

# Se non c'è nessuna finestra attiva (siamo sul desktop)
if [ "$active_window" = "null" ] || [ -z "$active_window" ]; then
    # Ottieni posizione del cursore
    cursor_pos=$(hyprctl cursorpos -j)
    x=$(echo "$cursor_pos" | jq -r '.x')
    y=$(echo "$cursor_pos" | jq -r '.y')

    # Definisci le opzioni del menu
    options="Terminal\nBrowser\nFile Manager\nRefresh"

    # Mostra il menu con wofi
    choice=$(echo -e "$options" | wofi --dmenu --location 1 --xoffset "$x" --yoffset "$y" --width 200 --height 200 --hide-scroll --prompt "Menu Desktop")

    case "$choice" in
        "Refresh") hyprctl dispatch reload ;;
        "File Manager") thunar & ;;
        "Terminal") footclient & ;;
        "Browser") firefox & ;;
    esac
fi
