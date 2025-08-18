#!/bin/bash

output="/home/araaha/Screenshots/%Y-%m-%d-%T-screenshot.png"

options=$(printf "Select\nWindow" | rofi -no-show-icons -dmenu -i -p "Select screenshot mode ")

case "$options" in
    "Select")
        scrot "$output" --select --line mode=edge -q 100 --exec "notify-send -t 300 'Screenshot taken'";;
    "Window")
        scrot "$output" --focused --border -q 100 --exec "notify-send -t 300 'Screenshot taken'";;
    *)
        exit;;
esac
