#!/bin/sh
while true; do
    VOLUME=$(pamixer --get-volume)
    IS_MUTED=$(pamixer --get-volume-human)
    if [ "$IS_MUTED" = "muted" ]; then
        echo "󰝟 $VOLUME%"
    else
        echo "󰕾 $VOLUME%"
    fi
    sleep 0.01
done


