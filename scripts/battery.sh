#!/bin/bash

path="/org/freedesktop/UPower/devices/battery_BAT0"
interface="org.freedesktop.UPower.Device"

notified_low=0
notified_high_at=-1

check_battery() {
    local level_result state_result level state

    level_result=$(gdbus call --system --dest org.freedesktop.UPower \
        --object-path "$path" --method org.freedesktop.DBus.Properties.Get \
        "$interface" Percentage) || return
    state_result=$(gdbus call --system --dest org.freedesktop.UPower \
        --object-path "$path" --method org.freedesktop.DBus.Properties.Get \
        "$interface" State) || return

    # gdbus wraps property values in a variant tuple, e.g. (<61.0>,).
    [[ "$level_result" =~ \(([0-9]+)(\.[0-9]+)?\) ]] || return
    level=${BASH_REMATCH[1]}
    [[ "$state_result" =~ \([^0-9]*([0-9]+) ]] || return
    state=${BASH_REMATCH[1]}

    # Low battery
    if (( level <= 20 && state != 1 )); then
        if (( ! notified_low )); then
            dunstify -u CRITICAL -t 1000 \
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
            dunstify -u CRITICAL -t 1000 \
                "Battery level is ${level}%! Unplug"
            notified_high_at=$level
        fi
    else
        notified_high_at=-1
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
    --object-path "$path")
