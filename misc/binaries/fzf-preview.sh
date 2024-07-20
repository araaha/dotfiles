#!/usr/bin/env bash

export FIFO="/tmp/image-preview.fifo"

cleanup() {
    exec 3>&-
    rm "$FIFO"
}

mkfifo "$FIFO"
ueberzug layer -s <"$FIFO" &
exec 3>"$FIFO"
trap cleanup EXIT

fzf --preview "$HOME/.local/bin/preview_img.sh {}"
