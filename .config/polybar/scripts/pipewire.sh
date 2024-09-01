#!/bin/sh
while true; do
    VOLUME=$(pamixer --get-volume)
    IS_MUTED=$(pamixer --get-volume-human)
    if [ "$IS_MUTED" = "muted" ]; then
        echo "󰝟 $VOLUME%"
    fi
    echo "󰕾 $VOLUME%"
    sleep 0.01
done


