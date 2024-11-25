#!/bin/bash

session_address=$(grep -E -z "DBUS_SESSION_BUS_ADDRESS" /proc/$(pgrep -u "$LOGNAME" openbox)/environ | tr -d '\0')
eval "export $session_address"

battery_name="$(upower -e | rg 'battery' | cut -d '_' -f 2)"

battery_level="$(cat /sys/class/power_supply/"$battery_name"/capacity)"

charging_status="$(upower -i /org/freedesktop/UPower/devices/battery_"$battery_name" | grep 'state' | awk '{print $2}')"

if [ "$battery_level" -le 10 ] && [ "$charging_status" != "charging" ]
then
    DISPLAY=:0 dunstify -u CRITICAL -t 1000 "Battery level is ${battery_level}%!"
fi
