#!/bin/bash

out="/tmp/sioyek-fzf"
cmd="fd -e pdf -e djvu | fzf $FZF_DEFAULT_OPTS"

export FZF_DEFAULT_OPTS="--no-scrollbar --border=none --no-separator  --tiebreak=length,end,chunk --padding 0% --margin 0% --multi --reverse --preview-window=border-none --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#9cd365,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --bind home:first --bind end:last --bind ctrl-p:up --bind ctrl-d:half-page-down --bind ctrl-u:half-page-up --bind 'ctrl-l:become(lf {})' --bind 'ctrl-y:offset-up' --bind 'ctrl-e:offset-down' --bind 'ctrl-a:select-all'"

~/.local/bin/st -T "Filepicker" -g 80x25+720+400 -e sh -c "$cmd > $out"

selected_file=$(/usr/bin/cat /tmp/sioyek-fzf)

if ! [ -s $out ]; then
    exit 1
fi

sioyek --reuse-window "$selected_file"
