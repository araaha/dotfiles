#!/bin/sh
session_address=$(grep -E -z "DBUS_SESSION_BUS_ADDRESS" /proc/$(pgrep -u "$LOGNAME" openbox)/environ | tr -d '\0')
eval "export $session_address"

battery_level="$(cat /sys/class/power_supply/BATT/capacity)"
if [ "$battery_level" -le 10 ]
then
    DISPLAY=:0 notify-send -t 1000 "Battery level is ${battery_level}%!"
fi
