#!/usr/bin/env sh
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"
debug="$6"

set -e

if [ "$debug" = 1 ]; then
    set -x
fi

export GUM_STYLE="--no-show-help --prompt.padding='1 3 0 3' --prompt.foreground='#fbf1c7' --prompt.align='center' --prompt.width=80 --selected.align='center' --selected.width=40 --selected.background='#9cd365' --selected.foreground='#242424' --selected.margin='0 0' --selected.bold --unselected.align='center' --unselected.width=40 --unselected.foreground='#fbf1c7' --unselected.background='' --unselected.margin='0 0' --unselected.bold"

export FZF_DEFAULT_OPTS="--prompt '' --no-scrollbar --border=bold --no-separator  --tiebreak=length,end,chunk --padding 0% --margin 0% --multi --reverse --preview-window noborder --height=50% --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#9cd365,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --bind home:first --bind end:last --bind ctrl-r:toggle-raw  --bind ctrl-d:half-page-down --bind ctrl-u:half-page-up --bind 'ctrl-y:offset-up' --bind 'ctrl-e:offset-down' --bind 'ctrl-a:select-all'"

export FZF_DEFAULT_COMMAND="rg --no-config --glob='!.git' --glob='!*cargo/' --glob='!*bun/' --glob='!.cache/' --glob='!*logs/' --glob='!*state/' --glob='!*themes/' --glob='!*icons/' --glob='!*uv/' --glob='!*pki/' --glob='!*.gnupg/' --glob='!*pkg/' --files --smart-case --follow --hidden --color=auto --no-messages"

cmd="yazi"
termcmd="$HOME/.local/bin/st -T 'Filepicker' -g 80x24+600+360 -e"

if [ "$save" = "1" ]; then
    # save a file
    cmd="sh -c"
    termcmd="$HOME/.local/bin/st -T 'Filepicker' -g 80x6+600+720 -e"
    set -- "gum confirm $GUM_STYLE 'Save to ${path/$HOME/\~}' && printf '%s' \"$path\" > \"$out\""
elif [ "$directory" = "1" ]; then
    # upload files from a directory
    set -- --chooser-file="$out" --cwd-file="$out"".1" "$path"
elif [ "$multiple" = "1" ]; then
    # upload multiple files
    set -- --chooser-file="$out" "$path"
else
    # upload only 1 file
    set -- --chooser-file="$out" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
    # escape double quotes
    escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
    # escape special
    command="$command \"$escaped\""
done

sh -c "$command"

if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$out"".1" ]; then
        cat "$out"".1" > "$out"
        rm "$out"".1"
    else
        rm "$out"".1"
    fi
fi
