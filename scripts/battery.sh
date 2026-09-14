#!/bin/bash

path="/org/freedesktop/UPower/devices/battery_BAT0"
interface="org.freedesktop.UPower.Device"

notified_low=0
notified_high=0

check_battery() {
    level="$(
        busctl --system get-property \
            org.freedesktop.UPower \
            "$path" \
            "$interface" \
            Percentage
    )"

    state="$(
        busctl --system get-property \
            org.freedesktop.UPower \
            "$path" \
            "$interface" \
            State
    )"

    level="${level#* }"
    state="${state#* }"

    # Remove decimal part if Percentage is e.g. 74.000000
    level="${level%.*}"

    if (( level <= 10 && state != 1 )); then
        if (( ! notified_low )); then
            dunstify -u CRITICAL -t 1000 \
                "Battery level is ${level}%!"
            notified_low=1
        fi
    else
        notified_low=0
    fi

    if (( level >= 80 && state == 1 )); then
        if (( ! notified_high )); then
            dunstify -u CRITICAL -t 1000 \
                "Battery level is ${level}%! Unplug"
            notified_high=1
        fi
    else
        notified_high=0
    fi
}

# Check immediately on startup.
check_battery

# Then react whenever UPower reports any battery property change.
gdbus monitor \
    --system \
    --dest org.freedesktop.UPower \
    --object-path "$path" |
while IFS= read -r line; do
    case "$line" in
        *org.freedesktop.DBus.Properties.PropertiesChanged*)
            check_battery
            ;;
    esac
done

