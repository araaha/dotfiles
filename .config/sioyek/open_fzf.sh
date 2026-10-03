#!/bin/sh
set -eu
tmpfile=$(mktemp)
trap 'rm -f -- "$tmpfile"' EXIT HUP INT TERM
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ripgreprc"
export FZF_DEFAULT_OPTS="--no-scrollbar --border=none --no-separator  --tiebreak=length,end,chunk --padding 0% --margin 0% --multi --reverse --preview-window noborder --height=100% --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#9cd365,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --bind home:first --bind end:last --bind ctrl-r:toggle-raw  --bind ctrl-d:half-page-down --bind ctrl-u:half-page-up --bind 'ctrl-y:offset-up' --bind 'ctrl-e:offset-down' --bind 'ctrl-a:select-all'"

alacritty --class Filepicker --title Filepicker \
    -o 'window.dimensions.columns=100' -o 'window.dimensions.lines=20' \
    -e sh -c '
        rg --files --hidden --follow --no-messages --no-ignore --color=never \
            --glob "*.pdf" --glob "*.epub" --glob "*.djvu" "$1" |
            fzf --no-multi > "$2"
    ' filepicker "$HOME" "$tmpfile"

if [ -s "$tmpfile" ]; then
    IFS= read -r selected < "$tmpfile"
    sioyek --reuse-window "$selected"
    printf '%s\n' "$selected"
fi
