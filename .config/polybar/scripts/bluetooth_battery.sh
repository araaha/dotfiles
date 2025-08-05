#!/bin/bash

#Get MAC address
MAC=$(bluetoothctl devices | rg 'Device' | head -n 1 | cut -d ' ' -f 2 | sed 's/:/_/g')
# Execute the dbus-send command and capture stderr
DBUS_OUTPUT=$(dbus-send \
        --print-reply=literal \
        --system \
        --dest=org.bluez /org/bluez/hci0/dev_"$MAC" \
        org.freedesktop.DBus.Properties.Get \
        string:"org.bluez.Battery1" \
        string:"Percentage")
DBUS_EXIT_STATUS=$?

if [ "$1" = "test" ]; then
    if [ -n "$DBUS_OUTPUT" ]; then
        exit 0
    fi
    echo ""
    exit 1
fi

if [ $DBUS_EXIT_STATUS -eq 0 ]; then
    percent=$(echo "$DBUS_OUTPUT" | tr -d -c 0-9)
    echo "$percent%"
else
    exit 1
fi
