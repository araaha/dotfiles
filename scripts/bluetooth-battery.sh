#!/bin/bash

set -u

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/bluetooth-battery-$UID.lock"
flock -n 9 || exit 0

readonly upower_interface="org.freedesktop.UPower.Device"
readonly bluez_interface="org.bluez.Device1"
readonly poll_interval=30
readonly percent_pattern='^\(<([0-9]+)(\.[0-9]+)?>[,]\)$'
notified_low=0

# Pick the first known Bluetooth device, as in the original script.
MAC=$(bluetoothctl devices | awk 'NR == 1 { print $2; exit }')
if [[ ! "$MAC" =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
    exit 1
fi

headset="${MAC//:/_}"
upower_path="/org/freedesktop/UPower/devices/headset_dev_$headset"
bluez_path="/org/bluez/hci0/dev_$headset"

while true; do
    percent_result=$(gdbus call --system --dest org.freedesktop.UPower \
        --object-path "$upower_path" --method org.freedesktop.DBus.Properties.Get \
        "$upower_interface" Percentage 2>/dev/null) || {
        sleep "$poll_interval"
        continue
    }

    connected_result=$(gdbus call --system --dest org.bluez \
        --object-path "$bluez_path" --method org.freedesktop.DBus.Properties.Get \
        "$bluez_interface" Connected 2>/dev/null) || {
        sleep "$poll_interval"
        continue
    }

    if [[ "$percent_result" =~ $percent_pattern ]]; then
        percent=${BASH_REMATCH[1]}
        fraction=${BASH_REMATCH[2]:1:1}
        fraction=${fraction:-0}
        percent_tenths=$((10 * percent + fraction))
        if [[ "$connected_result" == *true* ]] && (( percent_tenths <= 200 )); then
            if (( ! notified_low )); then
                dunstify -u CRITICAL -t 1000 "Headset at ${percent}%" || true
                notified_low=1
            fi
        else
            notified_low=0
        fi
    fi

    sleep "$poll_interval"
done
