#Image
export FIFO="/tmp/image-preview.fifo"

preview_img () {
    CACHE="/tmp/fzf-preview.jpg"
    if [[ $1 == *.mp4 ]] || [[ $1 == *.mkv ]] || [[ $1 == *.mov ]]; then
        ffmpegthumbnailer -i "$1" -o "$CACHE" -s 0 -q 5 &>/dev/null
        printf '{"action": "add", "identifier": "image-preview", "path": "%s", "x": "%s", "y": "%s", "width": "%s", "height": "%s"}\n' "$CACHE" "$FZF_PREVIEW_LEFT" "$FZF_PREVIEW_TOP" "$FZF_PREVIEW_COLUMNS" "$FZF_PREVIEW_LINES" > "$FIFO"
    elif [[ $1 == *.pdf ]]; then
        pdftoppm -jpeg -f 1 -l 1 -singlefile -scale-to-y -1 "$1" "/tmp/fzf-preview"
        printf '{"action": "add", "identifier": "image-preview", "path": "%s", "x": "%s", "y": "%s", "width": "%s", "height": "%s"}\n' "$CACHE" "$FZF_PREVIEW_LEFT" "$FZF_PREVIEW_TOP" "$FZF_PREVIEW_COLUMNS" "$FZF_PREVIEW_LINES" > "$FIFO"
    else
        printf '{"action": "add", "identifier": "image-preview", "path": "%s", "x": "%s", "y": "%s", "width": "%s", "height": "%s"}\n' "$1" "$FZF_PREVIEW_LEFT" "$FZF_PREVIEW_TOP" "$FZF_PREVIEW_COLUMNS" "$FZF_PREVIEW_LINES" > "$FIFO"
    fi
}

preview_img "$1"
