#!/bin/bash

MAC=$(bluetoothctl devices | cut -d ' ' -f 2)
headset="${MAC//:/_}"

upower_path="/org/freedesktop/UPower/devices/headset_dev_$headset"
upower_interface="org.freedesktop.UPower.Device"

bluez_path="/org/bluez/hci0/dev_$headset"
bluez_interface="org.bluez.Device1"

notified_low=0

check_battery() {
    percent="$(
        gdbus get-property --system --dest org.freedesktop.UPower \
            --object-path "$upower_path" --interface "$upower_interface" Percentage 2>/dev/null
    )" || return

    connected="$(
        gdbus get-property --system --dest org.bluez \
            --object-path "$bluez_path" --interface "$bluez_interface" Connected 2>/dev/null
    )" || return

    percent="${percent%.*}"

    if (( percent <= 20 )) && [[ "$connected" == "true" ]]; then
        if (( ! notified_low )); then
            dunstify -u CRITICAL -t 1000 \
                "Headset at ${percent}%"
            notified_low=1
        fi
    else
        notified_low=0
    fi
}

check_battery

while IFS= read -r line; do
    case "$line" in
        *org.freedesktop.DBus.Properties.PropertiesChanged*)
            check_battery
            ;;
    esac
done < <(gdbus monitor \
    --system \
    --dest org.freedesktop.UPower \
    --object-path "$upower_path")
