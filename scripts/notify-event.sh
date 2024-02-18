#!/bin/bash

session_address=$(grep -E -z "DBUS_SESSION_BUS_ADDRESS" /proc/$(pgrep -u "$LOGNAME" openbox)/environ | tr -d '\0')
eval "export $session_address"

EVENT=$(calcurse -n)

TIME_START=10
TIME_END=60

if [[ "$EVENT" ]]; then
    TIME=$(calcurse -n | sed 1d | rg --color=never "\d+:(\d+)" -or "\$1")
else
    exit
fi

if (( TIME_START <= TIME && TIME <= TIME_END )); then
    DISPLAY=:0 notify-send -t 3500 "$EVENT"
fi
