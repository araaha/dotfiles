#!/bin/bash

path="/org/freedesktop/UPower/devices/battery_BAT0"
interface="org.freedesktop.UPower.Device"

notified_low=0
notified_high_at=-1

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
    level="${level%.*}"
    state="${state#* }"

    # Low battery
    if (( level <= 20 && state != 1 )); then
        if (( ! notified_low )); then
            DISPLAY=:0 dunstify -u CRITICAL -t 1000 \
                "Battery level is ${level}%!"
            notified_low=1
        fi
    else
        notified_low=0
    fi

    # High battery while charging.
    # Notify again whenever the percentage increases.
    if (( level >= 80 && state == 1 )); then
        if (( level != notified_high_at )); then
            DISPLAY=:0 dunstify -u CRITICAL -t 1000 \
                "Battery level is ${level}%! Unplug"
            notified_high_at=$level
        fi
    else
        notified_high_at=-1
    fi
}

check_battery

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
