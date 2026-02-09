#!/bin/bash
HIDDEN_WS="special:hidden"
STATE_FILE="/tmp/hypr-hidden-windows.json"

# Inizializza file stato se non esiste
[ -f "$STATE_FILE" ] || echo '{}' > "$STATE_FILE"

# Funzione per nascondere una finestra
hide_window() {
    local addr="$1"
    local clients="$2"
    local current_ws
    current_ws=$(echo "$clients" | jq -r ".[] | select(.address == \"$addr\") | .workspace.name")
    local is_floating
    is_floating=$(echo "$clients" | jq -r ".[] | select(.address == \"$addr\") | .floating")

    # Salva workspace originale e stato floating
    jq --arg addr "$addr" --arg ws "$current_ws" --arg fl "$is_floating" \
        '. + {($addr): {ws: $ws, floating: $fl}}' "$STATE_FILE" > "$STATE_FILE.tmp" \
        && mv "$STATE_FILE.tmp" "$STATE_FILE"

    # Nascondi finestra
    hyprctl dispatch movetoworkspacesilent "$HIDDEN_WS,address:$addr"
}

# Funzione per ripristinare una finestra
restore_window() {
    local addr="$1"
    local saved
    saved=$(jq -r --arg addr "$addr" '.[$addr] // empty' "$STATE_FILE")

    # Leggi workspace e stato floating salvati (compatibile con vecchio formato stringa)
    local target_ws was_floating
    if echo "$saved" | jq -e '.ws' &>/dev/null 2>&1; then
        target_ws=$(echo "$saved" | jq -r '.ws')
        was_floating=$(echo "$saved" | jq -r '.floating')
    else
        # Fallback: vecchio formato dove il valore era solo il nome del workspace
        target_ws="$saved"
        was_floating="false"
    fi

    target_ws="${target_ws:-$(hyprctl activeworkspace -j | jq -r '.name')}"

    # Ripristina finestra nel workspace originale
    hyprctl dispatch movetoworkspace "$target_ws,address:$addr"
    hyprctl dispatch focuswindow "address:$addr"

    # Fix: rimuovi pin se si è attivato
    local is_pinned
    is_pinned=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$addr\") | .pinned")
    if [ "$is_pinned" = "true" ]; then
        hyprctl dispatch pin "address:$addr"
    fi

    # Ripristina stato floating/tiled corretto
    local is_floating
    is_floating=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$addr\") | .floating")
    if [ "$was_floating" = "true" ] && [ "$is_floating" = "false" ]; then
        hyprctl dispatch setfloating "address:$addr"
    elif [ "$was_floating" = "false" ] && [ "$is_floating" = "true" ]; then
        hyprctl dispatch settiled "address:$addr"
    fi

    # Rimuovi dallo stato
    jq --arg addr "$addr" 'del(.[$addr])' "$STATE_FILE" > "$STATE_FILE.tmp" \
        && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# SE VIENE PASSATO UN INDIRIZZO (da Waybar), gestiscilo direttamente
if [ -n "$1" ]; then
    addr="$1"
    clients=$(hyprctl clients -j)
    current_ws=$(echo "$clients" | jq -r ".[] | select(.address == \"$addr\") | .workspace.name")

    if [[ "$current_ws" == "$HIDDEN_WS" ]]; then
        restore_window "$addr"
    else
        hide_window "$addr" "$clients"
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

if [[ "$current_ws" == "$HIDDEN_WS" ]]; then
    restore_window "$addr"
else
    hide_window "$addr" "$clients"
fi
