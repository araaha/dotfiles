#!/bin/bash

light="$(light -G)"
light="${light%%.*}" #strip decimals
light=$((10#$light)) #avoid values like 08

inc=0
dec=0

for arg in "$@"; do
    case "$arg" in
        -i|--inc) inc=1 ;;
        -d|--dec) dec=1 ;;
    esac
done

if (( inc )); then
    if (( light < 13 )); then
        light -A 1
    else
        light -A 2
    fi

elif (( dec )); then
    if (( light < 17 )); then
        light -U 1
    else
        light -U 2
    fi
fi
