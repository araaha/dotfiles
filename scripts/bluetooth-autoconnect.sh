#!/bin/bash

MAC="$(bluetoothctl devices | sed -n 's/^Device //p' | head -n 1 | cut -d ' ' -f1)"

device_path="/org/bluez/hci0/dev_${MAC//:/_}"

powered() {
    busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered \
        | grep -q "true"
}

connected() {
    busctl get-property org.bluez "$device_path" org.bluez.Device1 Connected \
        | grep -q "true"
}

while true; do
    if powered && ! connected; then
        bluetoothctl connect "$MAC" >/dev/null 2>&1
    fi
    sleep 2
done

