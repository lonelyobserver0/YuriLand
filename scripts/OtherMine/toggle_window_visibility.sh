#!/bin/bash

HIDDEN_WS="special:hidden"
STATE_FILE="/tmp/hypr-hidden-windows.json"

# Inizializza file stato se non esiste
[ -f "$STATE_FILE" ] || echo '{}' > "$STATE_FILE"

# Ottieni elenco delle finestre correnti
clients=$(hyprctl clients -j)

# Costruisci lista menu con stato
menu=$(echo "$clients" | jq -r --arg hidden "$HIDDEN_WS" '
    .[] |
    "\(.address) [\(.class)] \(.title // "Untitled") " +
    (if .workspace.name == $hidden then "🟡 [hidden]" else "🟢 [visible]" end)
')

# Mostra menu
choice=$(echo "$menu" | wofi --dmenu -p "Nascondi/Riprendi finestra:" --width 600)

# Esci se annullato
[ -z "$choice" ] && exit 1

# Estrai indirizzo finestra scelta
addr=$(echo "$choice" | awk '{print $1}')

# Workspace corrente della finestra
current_ws=$(echo "$clients" | jq -r ".[] | select(.address == \"$addr\") | .workspace.name")

# Stato salvato
saved_ws=$(jq -r --arg addr "$addr" '.[$addr] // empty' "$STATE_FILE")

if [[ "$current_ws" == "$HIDDEN_WS" ]]; then
    # Ripristina finestra
    target_ws="${saved_ws:-$(hyprctl activeworkspace -j | jq -r '.name')}"
    hyprctl dispatch movetoworkspace "$target_ws,address:$addr"

    # Rimuovi record dal file stato
    jq --arg addr "$addr" 'del(.[$addr])' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
else
    # Salva workspace originale
    jq --arg addr "$addr" --arg ws "$current_ws" '. + {($addr): $ws}' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    # Nascondi finestra
    hyprctl dispatch movetoworkspacesilent "$HIDDEN_WS,address:$addr"
fi
