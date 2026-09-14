#!/bin/bash

bright="$(light -G)"

inc=0
dec=0

for arg in "$@"; do
    case "$arg" in
        -i|--inc) inc=1 ;;
        -d|--dec) dec=1 ;;
    esac
done

if (( inc )); then
    if (( $(echo "$bright < 13" | bc -l) )); then
        light -A 1
    else
        light -A 2
    fi

elif (( dec )); then
    if (( $(echo "$bright < 17" | bc -l) )); then
        light -U 1
    else
        light -U 2
    fi
fi
