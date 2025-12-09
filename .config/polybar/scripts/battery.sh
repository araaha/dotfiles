#!/usr/bin bash

BATTERY=$(ls /sys/class/power_supply/ | grep -E '^BAT' | head -n 1)

BAT_PATH="/sys/class/power_supply/$BATTERY"

ICON_CHARGING=""
ICON_FULL=""
ICON_HIGH=""
ICON_MEDIUM=""
ICON_LOW=""
ICON_EMPTY=""

while true; do
    STATUS=$(cat "$BAT_PATH/status")
    PERCENT=$(cat "$BAT_PATH/capacity")

    if [[ "$STATUS" == "Charging" ]]; then
        ICON="$ICON_CHARGING"
    else
        if (( PERCENT >= 90 )); then
            ICON="$ICON_FULL"
        elif (( PERCENT >= 70 )); then
            ICON="$ICON_HIGH"
        elif (( PERCENT >= 40 )); then
            ICON="$ICON_MEDIUM"
        elif (( PERCENT >= 15 )); then
            ICON="$ICON_LOW"
        else
            ICON="$ICON_EMPTY"
        fi
    fi

    echo "  %{T2}$ICON %{T2}$PERCENT% "

    sleep 0.5
done
