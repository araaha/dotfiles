#!/bin/sh

if dbus-send \
    --print-reply=literal \
    --system \
    --dest=org.bluez /org/bluez/hci0/dev_40_C1_F6_2A_8C_DD \
    org.freedesktop.DBus.Properties.Get \
    string:"org.bluez.Battery1" \
    string:"Percentage" > /dev/null 2>&1; then

    str=$(dbus-send \
    --print-reply=literal \
    --system \
    --dest=org.bluez /org/bluez/hci0/dev_40_C1_F6_2A_8C_DD \
    org.freedesktop.DBus.Properties.Get \
    string:"org.bluez.Battery1" \
    string:"Percentage" | tr -d -c 0-9)

    echo "$str"
else 
    echo "0"
    exit
fi 

