#!/bin/sh
session_address=$(grep -E -z "DBUS_SESSION_BUS_ADDRESS" /proc/$(pgrep -u "$LOGNAME" openbox)/environ | tr -d '\0')
eval "export $session_address"

bluetooth_percent=$(upower -i /org/freedesktop/UPower/devices/headset_dev_40_C1_F6_2A_8C_DD | rg percentage | awk '{print $2}')

bluetooth_battery_num="${bluetooth_percent%?}"

if [ "$bluetooth_battery_num" -eq 10 ]; then
    DISPLAY=:0 notify-send -t 1000 "Headset at 10%"
fi

