#!/bin/bash
# ~/scripts/desktop-menu.sh

option=$(printf "Apri Terminale\nApri Browser\nChiudi Sessione" | wofi --dmenu --lines 10 --prompt "Menu Desktop:")

case $option in
    "Apri Terminale")
        alacritty &
        ;;
    "Apri Browser")
        firefox &
        ;;
    "Chiudi Sessione")
        hyprctl dispatch exit
        ;;
esac
