#!/bin/bash
MAC=$(bluetoothctl devices | cut -d ' ' -f 2)
adapter="/org/bluez/hci0"
device="$adapter/dev_${MAC//:/_}"
next_attempt=0

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/bluetooth-autoconnect-$UID.lock"
flock -n 9 || exit 0

while true; do
    state=$(gdbus get-property --system --dest org.bluez --object-path "$device" --interface org.bluez.Device1 Connected 2>/dev/null)

    if [[ "$state" == 'true' ]]; then
        next_attempt=""
    elif [[ "$state" == 'false' ]]; then
        # A new disconnection starts the grace period.
        if [[ -z "$next_attempt" ]]; then
            next_attempt=$((SECONDS + 10))
        fi

        if (( SECONDS >= next_attempt )); then
            timeout 10 gdbus call --system --dest org.bluez --object-path "$device" --interface org.bluez.Device1 --method org.bluez.Device1.Connect >/dev/null 2>&1
            next_attempt=$((SECONDS + 2))
        fi
    fi

    sleep 1
done
