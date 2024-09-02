#!/bin/bash

MAC="40:C1:F6:2A:8C:DD"

powered() {
    echo "show" | bluetoothctl | grep "Powered" | cut -d " " -f 2
}

connected() {
    echo "info ${MAC}" | bluetoothctl | grep "Connected" | cut -d " " -f 2
}

while true; do
    if [ "$(powered)" = "yes" ] && [ "$(connected)" = "no" ]; then
        echo "connect ${MAC}" | bluetoothctl
        sleep 4
    fi
done
