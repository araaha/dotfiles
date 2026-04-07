#!/usr/bin/env bash

TMP_FOLDER=$(mktemp -d /tmp/fzf-preview.XXXXXXXXXX)
TMP_IMG="$TMP_FOLDER/preview"
UEBERZUG_FIFO=""

# Choose image previewer
IMG_PREVIEW="ueberzug_preview"
# Initialize ueberzug (listen to a fifo)
UEBERZUG_FIFO="$TMP_FOLDER/ueberzug-fifo"
mkfifo "$UEBERZUG_FIFO"
if command -v ueberzugpp >/dev/null; then
    tail -f --pid=$$ "$UEBERZUG_FIFO" 2>/dev/null | ueberzugpp layer --no-cache --silent &
else
    tail -f --pid=$$ "$UEBERZUG_FIFO" 2>/dev/null | ueberzug layer --no-cache --silent &
fi

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fzf-preview"
mkdir -p "$CACHE_DIR"

cleanup () {
    # Clear last image
    if [ -p "$UEBERZUG_FIFO" ]; then
        echo '{"action": "remove", "identifier": "fzf"}' >> "$UEBERZUG_FIFO"
    fi
    # Clean up old cache files
    ls -1t "$CACHE_DIR" | tail -n +201 | xargs -I {} rm "${CACHE_DIR}/{}"
    # Remove temporary files
    rm -rf "$TMP_FOLDER"
}
trap cleanup HUP INT TERM QUIT EXIT

# Run fzf
fzf --preview '/home/araaha/.local/bin/fzf-file2preview.sh {} '$IMG_PREVIEW' '$CACHE_DIR' '$TMP_IMG' '$UEBERZUG_FIFO''
