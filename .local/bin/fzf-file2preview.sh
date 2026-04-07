#!/usr/bin/env bash

FILE="$1"                               # fzf search result
IMG_PREVIEW="${2:-generic_preview}"     # preview method
CACHE_DIR="$3"                          # cache directory
TMP_IMG="${4:-/tmp/fzf-preview}"        # location to place extracted image from file
UEBERZUG_FIFO="$5"                      # file to send ueberzug commands
IMG=""                                  # location of final image
MAX_SIZE=$((100 * 1024 * 1024))         # size threshold (100 MB)

# Cross-platform file size retrieval
get_file_size () {
    if stat --version >/dev/null 2>&1; then
        stat -c%s "$1"  # GNU/Linux
    else
        stat -f%z "$1"  # macOS/BSD
    fi
}

# Generate cache key based on modification time and size
get_cache_key() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local mtime=$(stat -f "%m" "$FILE")
        local size=$(stat -f "%z" "$FILE")
    else
        local mtime=$(stat -c "%Y" "$FILE")
        local size=$(stat -c "%s" "$FILE")
    fi
    echo "${mtime}_${size}.jpg"
}

# Check if cached image exists
get_cached_image() {
    local cache_file="$CACHE_DIR/$(get_cache_key "$FILE")"

    if [ -f "$cache_file" ]; then
        touch "$cache_file"
        echo "$cache_file"
        return 0
    fi
    return 1
}

# Save image to cache
cache_image() {
    local src_img="$1"
    local cache_file="$CACHE_DIR/$(get_cache_key "$FILE")"

    if [ -f "$src_img" ]; then
        cp "$src_img" "$cache_file" 2> /dev/null
        echo "$cache_file"
    fi
}

# Error handling function
cmd_e() {
    if "$@" 2> /dev/null; then
        return 0
    else
        if ! command -v "$1" > /dev/null; then
            {
                echo "Preview method unavailable: install $1"
                echo ""
                file "$FILE"
            } | fold -sw $((FZF_PREVIEW_COLUMNS - 1))
        fi
        return 1
    fi
}

ueberzug_preview() {
	cat <<-EOF >> "$UEBERZUG_FIFO"
	{"action": "add", "identifier": "fzf", "x": $FZF_PREVIEW_LEFT, "y": $FZF_PREVIEW_TOP, "max_width": $FZF_PREVIEW_COLUMNS, "max_height": $FZF_PREVIEW_LINES, "path": "$1"}
EOF
}

# Check cache for file
if cached_img=$(get_cached_image); then
    IMG="$cached_img"

# Directory
elif [ -d "$FILE" ]; then
    ls "$FILE"

# File handling by type
else
    type=$(file --dereference -b --mime-type "$FILE")

    case "$type" in
        # Images (and DJVU)
        image/*)
            if [ "$type" != "image/vnd.djvu" ]; then
                if magick "$FILE" -auto-orient -resize x1080 "$TMP_IMG" 2> /dev/null; then
                    IMG=$(cache_image "$TMP_IMG")
                else
                    IMG="$FILE"
                fi
            else
                # DJVU
                if cmd_e ddjvu -format=tiff -size=1920x1080 -page=1 "$FILE" "$TMP_IMG"; then
                    IMG=$(cache_image "$TMP_IMG")
                fi
            fi
            ;;

        # Audio
        audio/*)
            if cmd_e ffmpeg -y -i "$FILE" -an -c:v copy "$TMP_IMG.jpg"; then
                mv "$TMP_IMG.jpg" "$TMP_IMG"
                IMG=$(cache_image "$TMP_IMG")
            else
                cmd_e exiftool "$FILE"
            fi
            ;;

        # Video
        video/*)
            if cmd_e ffmpegthumbnailer -i "$FILE" -o "$TMP_IMG" -s 1080 -m; then
                IMG=$(cache_image "$TMP_IMG")
            fi
            ;;

        # PDF
        application/pdf)
            if cmd_e pdftoppm -singlefile -jpeg "$FILE" "$TMP_IMG"; then
                mv "$TMP_IMG.jpg" "$TMP_IMG"
                IMG=$(cache_image "$TMP_IMG")
            fi
            ;;
    esac
fi

# Show image
if [ -n "$IMG" ]; then
    $IMG_PREVIEW "$IMG"
elif [ -p "$UEBERZUG_FIFO" ]; then
    echo '{"action": "remove", "identifier": "fzf"}' >> "$UEBERZUG_FIFO"
fi
