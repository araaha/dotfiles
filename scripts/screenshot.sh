#!/bin/bash
output='/home/araaha/Screenshots/%Y-%m-%d-%T-screenshot.png'

options=$(printf "Select\nWindow" | rofi -dmenu -i -p "Select screenshot mode")

case "$options" in
    "Select")
        scrot "$output" --select --line mode=edge --exec "notify-send -t 300 'Screenshot taken'";;
    "Window")
        scrot "$output" --focused --border --exec "notify-send -t 300 'Screenshot taken'";;
    *) 
        exit;;
esac
