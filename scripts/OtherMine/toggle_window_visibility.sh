#!/bin/bash

HIDDEN_WS="special:hidden"

# Ottieni elenco delle finestre
clients=$(hyprctl clients -j)

# Costruisci la lista per wofi con stato
menu=$(echo "$clients" | jq -r --arg hidden "$HIDDEN_WS" '
    .[] |
    "\(.address) [\(.class)] \(.title) " +
    (if .workspace.name == $hidden then "🟡 [hidden]" else "🟢 [visible]" end)
')

# Mostra menu
choice=$(echo "$menu" | wofi --dmenu -p "Nascondi/Riprendi finestra:" --width 600)

# Esci se l'utente annulla
[ -z "$choice" ] && exit 1

# Estrai indirizzo selezionato
addr=$(echo "$choice" | awk '{print $1}')

# Workspace corrente della finestra
current_ws=$(echo "$clients" | jq -r ".[] | select(.address == \"$addr\") | .workspace.name")

# Azione: nascondi o ripristina
if [[ "$current_ws" == "$HIDDEN_WS" ]]; then
    # Ripristina nel workspace attivo
    current=$(hyprctl activeworkspace -j | jq -r '.name')
    hyprctl dispatch movetoworkspace "$current,address:$addr"
else
    # Nascondi
    hyprctl dispatch movetoworkspacesilent "$HIDDEN_WS,address:$addr"
fi
