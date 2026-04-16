#!/bin/bash
while true; do
    LIGHT=$(light -G)
    ROUNDED_VOLUME=$(printf "%.0f" "$LIGHT")
    printf "%d\n" $((ROUNDED_VOLUME / 2 * 2))
    sleep 1
done
