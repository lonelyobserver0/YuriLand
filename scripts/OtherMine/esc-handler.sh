#!/bin/bash

# Percorso del file di log
LOGFILE="/tmp/yuriwidget_check.log"

# Sovrascrive il log a ogni esecuzione
: > "$LOGFILE"

# Funzione per loggare messaggi
log() {
    echo "[INFO] $1" | tee -a "$LOGFILE"
}

error() {
    echo "[ERROR] $1" | tee -a "$LOGFILE" >&2
}

log "Script avviato"

# Ottieni la finestra attiva
active_window=$(hyprctl activewindow -j | jq -r '.address')

if [[ -z "$active_window" ]]; then
    error "Nessuna finestra attiva trovata"
    exit 1
fi

log "Finestra attiva trovata: $active_window"

# Ottieni i dettagli della finestra attiva
window_json=$(hyprctl clients -j | jq -c --arg addr "$active_window" '.[] | select(.address == $addr)')

if [[ -z "$window_json" ]]; then
    error "Finestra attiva non trovata nella lista dei client"
    exit 1
fi

log "Dettagli finestra: $window_json"

# Estrai il PID
pid=$(echo "$window_json" | jq -r '.pid')
if [[ -z "$pid" || "$pid" == "null" ]]; then
    error "PID non trovato per la finestra attiva"
    exit 1
fi

log "PID trovato: $pid"

# Estrai il title della finestra
title=$(echo "$window_json" | jq -r '.title')
if [[ -z "$title" || "$title" == "null" ]]; then
    error "PID non trovato per la finestra attiva"
    exit 1
fi

log "title trovato: $title"

# Ottieni il percorso eseguibile del processo
exe_path=$(readlink "/proc/$pid/exe" 2>/dev/null)

if [[ -z "$exe_path" ]]; then
    error "Impossibile determinare l'eseguibile per il PID $pid"
    exit 1
fi

log "Percorso eseguibile: $exe_path"

# Controlla se è yuriwidget
if [[ "$(basename "$exe_path")" != "yuriwidget" ]]; then
    log "La finestra attiva non è yuriwidget. Simulo la pressione del tasto ESC."
    ydotool key Escape
    exit 0
fi

log "Finestra yuriwidget trovata!"
yuriwidget_client hide $title

exit 0
