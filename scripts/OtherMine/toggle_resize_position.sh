#!/bin/bash

# Verifica che siano stati passati almeno due argomenti
if [ $# -lt 2 ]; then
    echo "Utilizzo: $0 <larghezza> <altezza> [posizione]"
    exit 1
fi

WIN_WIDTH=$1
WIN_HEIGHT=$2
POSITION=$3  # facoltativo

# Attendi fino a quando Hyprland trova una finestra attiva
for i in {1..20}; do
    WIN=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address' 2>/dev/null)
    if [[ "$WIN" != "null" && -n "$WIN" ]]; then
        break
    fi
    sleep 0.05
done

if [[ -z "$WIN" || "$WIN" == "null" ]]; then
    echo "Nessuna finestra attiva trovata"
    exit 1
fi

# Ottieni monitor della finestra attiva
MONITOR=$(hyprctl activewindow -j | jq -r '.monitor')
MONINFO=$(hyprctl monitors -j | jq ".[] | select(.name == \"$MONITOR\")")

# Estrai dimensioni e posizione del monitor
MON_WIDTH=$(echo "$MONINFO" | jq -r '.width')
MON_HEIGHT=$(echo "$MONINFO" | jq -r '.height')
MON_X=$(echo "$MONINFO" | jq -r '.x')
MON_Y=$(echo "$MONINFO" | jq -r '.y')

# Calcola posizione in base all'argomento
case "$POSITION" in
    center)
        POS_X=$((MON_X + (MON_WIDTH - WIN_WIDTH) / 2))
        POS_Y=$((MON_Y + (MON_HEIGHT - WIN_HEIGHT) / 2))
        ;;
    topleft)
        POS_X=$MON_X
        POS_Y=$MON_Y
        ;;
    topright)
        POS_X=$((MON_X + MON_WIDTH - WIN_WIDTH))
        POS_Y=$MON_Y
        ;;
    bottomleft)
        POS_X=$MON_X
        POS_Y=$((MON_Y + MON_HEIGHT - WIN_HEIGHT))
        ;;
    bottomright)
        POS_X=$((MON_X + MON_WIDTH - WIN_WIDTH))
        POS_Y=$((MON_Y + MON_HEIGHT - WIN_HEIGHT))
        ;;
    *)
        POS_X=
        POS_Y=
        ;;
esac

# Toggle floating
hyprctl dispatch togglefloating "$WIN"
sleep 0.1

# Ridimensiona
hyprctl dispatch resizewindowpixel exact "$WIN_WIDTH" "$WIN_HEIGHT"

# Muovi se la posizione è valida
if [[ -n "$POS_X" && -n "$POS_Y" ]]; then
    hyprctl dispatch movewindowpixel exact "$POS_X" "$POS_Y"
fi
