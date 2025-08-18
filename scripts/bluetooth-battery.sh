#!/bin/bash

MAC=$(bluetoothctl devices | rg 'Device' | head -n 1 | cut -d ' ' -f 2)
headset=${MAC//:/_}
connected=$(bluetoothctl info "$MAC" | rg 'Connected' | cut -d " " -f 2)

bluetooth_percent=$(upower -i /org/freedesktop/UPower/devices/headset_dev_"$headset" | rg percentage | awk '{print $2}')
echo "$bluetooth_percent"

bluetooth_battery_num="${bluetooth_percent%?}"
#
if [ "$bluetooth_battery_num" -eq 10 ] && [ "$connected" = "yes" ]; then
    DISPLAY=:0 dunstify -u CRITICAL -t 1000 "Headset at 10%"
fi

