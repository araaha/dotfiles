#!/bin/bash
while true; do
    printf "%.0f\n" "$(light -G)"
    sleep 0.01
done
