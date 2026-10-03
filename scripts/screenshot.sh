#!/bin/sh

output_dir="$HOME/Screenshots"
output="$output_dir/$(date +'%Y-%m-%d-%H%M%S-screenshot.png')"
mkdir -p "$output_dir"

choice=$(printf 'Select area\nFull screen\n' | rofi -no-show-icons -dmenu -i -p 'Screenshot mode')

case "$choice" in
  'Select area')
    geometry=$(slurp) || exit 0
    grim -g "$geometry" "$output"
    ;;
  'Full screen')
    grim "$output"
    ;;
  *)
    exit 0
    ;;
esac

notify-send -t 1000 'Screenshot taken' "$output"
