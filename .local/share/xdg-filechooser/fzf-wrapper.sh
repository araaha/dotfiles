#!/bin/bash
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# Inputs:
# 1. "1" if multiple files can be chosen, "0" otherwise.
# 2. "1" if a directory bashould be chosen, "0" otherwise.
# 3. "0" if opening files was requested, "1" if writing to a file was
#    requested. For example, when uploading files in Firefox, this will be "0".
#    When saving a web page in Firefox, this will be "1".
# 4. If writing to a file, this is recommended path provided by the caller. For
#    example, when saving a web page in Firefox, this will be the recommended
#    path Firefox provided, such as "~/Downloads/webpage_title.html".
#    Note that if the path already exists, we keep appending "_" to it until we
#    get a path that does not exist.
# 5. The output path, to which results bashould be written.
#
# Output:
# The script bashould print the selected paths to the output path (argument #5),
# one path per line.
# If nothing is printed, then the operation is assumed to have been canceled.

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

if [ "$save" = "1" ]; then
    cmd="dialog --yesno \"Save to $path ?\" 0 0 && ( printf '%s' \"$path\" > $out ) || ( printf '%s' 'Input path to write to: ' && read input && printf '%s' \"\$input\" > $out)"
elif [ "$directory" = "1" ]; then
    cmd="fd -I -a --base-directory=$HOME --exclude='*/Books/*' --exclude='*/ok/*' --exclude='*/WINTER2023/*' --exclude='*/micro/buffers/*' --exclude='*/watch_later/*' --exclude='*/icons/*' | fzf-tmux -p 100%,100% -m --bind ctrl-d:abort --bind ctrl-d:abort --layout=reverse --padding 0% --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --margin 0% --border=none --no-separator --prompt 'Select files > ' > $out"
else
    cmd="fd -I -a --base-directory=$HOME --exclude='*/Books/*' --exclude='*/Books/*' --exclude='*/ok/*' --exclude='*/WINTER2023/*' --exclude='*/micro/buffers/*' --exclude='*/watch_later/*' --exclude='*/icons/*'| fzf-tmux -p 100%,100% +m --bind ctrl-d:abort --bind ctrl-d:abort --layout=reverse --padding 0% --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --margin 0%  --border=none  --no-separator --prompt 'Select file > ' > $out"
fi


st -g 100x20+370+300 -e tmux new-session -E "$cmd"


if ! [ -s "$out" ]; then
    exit 1
fi
