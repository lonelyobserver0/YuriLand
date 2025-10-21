#!/usr/bin/env bash

# recupera prima riga di pgrep -af yabar e il suo primo campo (PID)
line=$(pgrep -af yabar | head -n1)
[ -z "$line" ] && { printf 'Nessun processo trovato\n' >&2; exit 1; }

pid=${line%% *}

# prova a terminare gentilmente, poi forzare se ancora presente
kill "$pid" || { printf 'Errore nel kill (PID: %s)\n' "$pid" >&2; exit 2; }

# aspetta 2s e verifica
sleep 2
if kill -0 "$pid" 2>/dev/null; then
  printf 'Processo %s ancora vivo, invio SIGKILL\n' "$pid"
  kill -9 "$pid" || { printf 'Impossibile uccidere %s\n' "$pid" >&2; exit 3; }
else
  printf 'Processo %s terminato\n' "$pid"
fi
