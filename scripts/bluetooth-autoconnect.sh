#!/bin/bash

MAC="$(bluetoothctl devices | rg 'Device' | head -n 1 | cut -d ' ' -f 2)"

powered() {
    echo "show" | bluetoothctl | grep "Powered" | cut -d " " -f 2
}

connected() {
    echo "info ${MAC}" | bluetoothctl | grep "Connected" | cut -d " " -f 2
}

while true; do
    if [ "$(powered)" = "yes" ] && [ "$(connected)" = "no" ]; then
        echo "connect ${MAC}" | bluetoothctl
    fi
    sleep 4
done
