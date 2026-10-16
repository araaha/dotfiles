#!/bin/bash
MAC=$(bluetoothctl devices | cut -d ' ' -f 2)
adapter="/org/bluez/hci0"
device="$adapter/dev_${MAC//:/_}"
next_attempt=0

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/bluetooth-autoconnect-$UID.lock"
flock -n 9 || exit 0

while true; do
    state=$(busctl --system get-property org.bluez "$device" org.bluez.Device1 Connected 2>/dev/null)

    if [[ "$state" == 'b true' ]]; then
        next_attempt=""
    elif [[ "$state" == 'b false' ]]; then
        # A new disconnection starts the grace period.
        if [[ -z "$next_attempt" ]]; then
            next_attempt=$((SECONDS + 10))
        fi

        if (( SECONDS >= next_attempt )); then
            busctl --system --timeout=10 call org.bluez "$device" org.bluez.Device1 Connect >/dev/null 2>&1
            next_attempt=$((SECONDS + 2))
        fi
    fi

    sleep 1
done
