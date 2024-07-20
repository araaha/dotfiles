#Image
export FIFO="/tmp/image-preview.fifo"

preview_img () {
    local image_path="$1"
    printf '{"action": "add", "identifier": "image-preview", "path": "%s", "x": "%s", "y": "%s", "width": "%s", "height": "%s"}\n' "$image_path" "$FZF_PREVIEW_LEFT" "$FZF_PREVIEW_TOP" "$FZF_PREVIEW_COLUMNS" "$FZF_PREVIEW_LINES" > "$FIFO"
}

preview_img "$1"
