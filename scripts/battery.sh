#!/bin/bash

battery_name="$(upower -e | rg 'battery' | cut -d '_' -f 2)"

battery_level="$(cat /sys/class/power_supply/"$battery_name"/capacity)"

charging_status="$(upower -i /org/freedesktop/UPower/devices/battery_"$battery_name" | grep 'state' | awk '{print $2}')"

if [ "$battery_level" -le 10 ] && [ "$charging_status" != "charging" ]
then
    DISPLAY=:0 dunstify -u CRITICAL -t 1000 "Battery level is ${battery_level}%!"
fi

if [ "$battery_level" -ge 80 ] && [ "$charging_status" = "charging" ]
then
    DISPLAY=:0 dunstify -u CRITICAL -t 1000 "Battery level is ${battery_level}%! Unplug"
fi
