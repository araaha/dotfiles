#!/bin/bash

session_address=$(grep -E -z "DBUS_SESSION_BUS_ADDRESS" /proc/$(pgrep -u "$LOGNAME" openbox)/environ | tr -d '\0')
eval "export $session_address"

headset=$(upower -e | rg 'headset' | cut -d '_' -f 3- )

MAC=$(echo "$headset" | tr _ :)
connected=$(bluetoothctl info "$MAC" | rg 'Connected' | cut -d " " -f 2)

bluetooth_percent=$(upower -i /org/freedesktop/UPower/devices/headset_dev_"$headset" | rg percentage | awk '{print $2}')

bluetooth_battery_num="${bluetooth_percent%?}"

if [ "$bluetooth_battery_num" -eq 10 ] && [ "$connected" = "yes" ]; then
    DISPLAY=:0 dunstify -u CRITICAL -t 1000 "Headset at 10%"
fi

