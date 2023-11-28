#!/bin/sh
session_address=$(grep -E -z "DBUS_SESSION_BUS_ADDRESS" /proc/$(pgrep -u "$LOGNAME" openbox)/environ | tr -d '\0')
eval "export $session_address"


#Code:
DISPLAY=:0 /usr/bin/python3 "$HOME/scripts/dunst-classes.py"
