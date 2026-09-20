#!/bin/bash

MAC="$(bluetoothctl devices | sed -n 's/^Device //p' | head -n 1 | cut -d ' ' -f1)"
device_path="/org/bluez/hci0/dev_${MAC//:/_}"

GRACE_PERIOD=10
grace_until=0
was_connected=0

powered() {
    busctl get-property \
        org.bluez \
        /org/bluez/hci0 \
        org.bluez.Adapter1 \
        Powered 2>/dev/null |
        grep -q "true"
}

connected() {
    busctl get-property \
        org.bluez \
        "$device_path" \
        org.bluez.Device1 \
        Connected 2>/dev/null |
        grep -q "true"
}

# Record the initial state.
connected && was_connected=1

while true; do
    if connected; then
        was_connected=1
        grace_until=0

    elif powered; then
        # Start the grace period only when the device has just disconnected.
        if (( was_connected )); then
            grace_until=$((SECONDS + GRACE_PERIOD))
            was_connected=0
        fi

        if (( SECONDS >= grace_until )); then
            bluetoothctl connect "$MAC" >/dev/null 2>&1
        fi
    fi

    sleep 1
done
