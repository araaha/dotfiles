#!/bin/sh
while true; do
    VOLUME=$(pamixer --get-volume)
    ROUNDED_VOLUME=$((VOLUME /2 *2))
    IS_MUTED=$(pamixer --get-volume-human)
    if [ "$IS_MUTED" = "muted" ]; then
        echo "󰝟 $ROUNDED_VOLUME%"
    else
        echo "󰕾 $ROUNDED_VOLUME%"
    fi
    sleep 0.01
done


