#!/bin/bash
if [ "$1" = "--help" ]; then
    echo 'Usage:'
    echo 'set-power-profile.sh [option]'
    echo ' '
    echo 'Options:'
    echo '  saver'
    echo '  balanced'
    echo '  performance'
fi

if [ "$1" = "saver" ]; then
    astal-power-profiles power-saver
    asusctl profile -P Quiet
fi
if [ "$1" = "balanced" ]; then
    astal-power-profiles balanced
    asusctl profile -P Balanced
fi
if [ "$1" = "performance" ]; then
    astal-power-profiles performance
    asusctl profile -P Performance
fi
