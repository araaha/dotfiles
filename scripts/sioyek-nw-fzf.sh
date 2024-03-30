#!/bin/bash

out="/tmp/sioyek-fzf"
cmd="fd -I -a --base-directory=$HOME -e pdf -e djvu -E 'micro' | fzf-tmux -p 100%,100% +m --bind ctrl-d:abort --layout=reverse --padding 0% --color=bg+:-1,spinner:#fb4934,hl:#928374,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:regular:underline:#9cd365,prompt:#fb4934,hl+:regular:#fb4934:underline,gutter:-1,query:regular,border:#87afaf --margin 0%  --border=bold --no-separator --prompt 'Select file > ' > $out"

st -g 60x20+610+300 -e tmux new-session -E "$cmd"


selected_file=$(cat /tmp/sioyek-fzf)

sioyek --new-window "$selected_file"


if ! [ -s $out ]; then
    exit 1
fi
