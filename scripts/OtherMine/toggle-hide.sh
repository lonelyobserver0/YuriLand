#!/bin/bash
HIDDEN_WS="special:hidden"
STATE_FILE="/tmp/hypr-hidden-windows.json"

# DEBUG: scrivi in un file cosa riceve lo script
echo "Argomento ricevuto: '$1'" >> /tmp/waybar-debug.log
echo "Numero argomenti: $#" >> /tmp/waybar-debug.log
echo "---" >> /tmp/waybar-debug.log

# Inizializza file stato se non esiste
[ -f "$STATE_FILE" ] || echo '{}' > "$STATE_FILE"

# SE VIENE PASSATO UN INDIRIZZO (da Waybar), gestiscilo direttamente
if [ -n "$1" ]; then
    addr="$1"
    clients=$(hyprctl clients -j)
    current_ws=$(echo "$clients" | jq -r ".[] | select(.address == \"$addr\") | .workspace.name")
    saved_ws=$(jq -r --arg addr "$addr" '.[$addr] // empty' "$STATE_FILE")
    
    if [[ "$current_ws" == "$HIDDEN_WS" ]]; then
        # Ripristina finestra
        target_ws="${saved_ws:-$(hyprctl activeworkspace -j | jq -r '.name')}"
        hyprctl dispatch movetoworkspace "$target_ws,address:$addr"
        hyprctl dispatch focuswindow "address:$addr"
        jq --arg addr "$addr" 'del(.[$addr])' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    else
        # Salva workspace originale
        jq --arg addr "$addr" --arg ws "$current_ws" '. + {($addr): $ws}' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        # Nascondi finestra
        hyprctl dispatch movetoworkspacesilent "$HIDDEN_WS,address:$addr"
    fi
    exit 0
fi

# MODALITÀ INTERATTIVA (se chiamato senza argomenti)
clients=$(hyprctl clients -j)

menu=$(echo "$clients" | jq -r --arg hidden "$HIDDEN_WS" '
    .[] |
    "\(.address) [\(.class)] \(.title // "Untitled") " +
    (if .workspace.name == $hidden then "🟡 [hidden]" else "🟢 [visible]" end)
')

choice=$(echo "$menu" | wofi --dmenu -p "Nascondi/Riprendi finestra:" --width 600)
[ -z "$choice" ] && exit 1

addr=$(echo "$choice" | awk '{print $1}')
current_ws=$(echo "$clients" | jq -r ".[] | select(.address == \"$addr\") | .workspace.name")
saved_ws=$(jq -r --arg addr "$addr" '.[$addr] // empty' "$STATE_FILE")

if [[ "$current_ws" == "$HIDDEN_WS" ]]; then
    target_ws="${saved_ws:-$(hyprctl activeworkspace -j | jq -r '.name')}"
    hyprctl dispatch movetoworkspace "$target_ws,address:$addr"
    jq --arg addr "$addr" 'del(.[$addr])' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
else
    jq --arg addr "$addr" --arg ws "$current_ws" '. + {($addr): $ws}' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    hyprctl dispatch movetoworkspacesilent "$HIDDEN_WS,address:$addr"
fi
