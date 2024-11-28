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
export FZF_DEFAULT_OPTS="--no-scrollbar --border=none --no-separator  --tiebreak=length,end,chunk --padding 0% --margin 0% --multi --reverse --preview-window=border-none --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#9cd365,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --bind home:first --bind end:last --bind ctrl-p:up --bind ctrl-d:half-page-down --bind ctrl-u:half-page-up --bind 'ctrl-l:become(lf {})' --bind 'ctrl-y:offset-up' --bind 'ctrl-e:offset-down' --bind 'ctrl-a:select-all'"

export FD_EXCLUDE="-E '.cache' -E 'icons' -E 'themes' -E '**pkg' -E '**.git' -E 'state' -E 'google-chrome' -E 'opt' -E 'chromium' -E 'firefox' -E 'cargo'"

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

if [ "$save" = "1" ]; then
    cmd="dialog --yesno \"Save to $path ?\" 0 0 && ( printf '%s' \"$path\" > $out )"
elif [ "$directory" = "1" ]; then
    cmd="fd --absolute-path . 'Screenshots' 'Downloads' | ~/.local/bin/fzf-preview.sh $FZF_DEFAULT_OPTS --prompt 'Select directories > '"
elif [ "$multiple" = "1" ]; then
    cmd="fd --absolute-path . 'Screenshots' 'Downloads' | ~/.local/bin/fzf-preview.sh $FZF_DEFAULT_OPTS --prompt 'Select files > '"
else
    cmd="fd --absolute-path . 'Screenshots' 'Downloads'  | ~/.local/bin/fzf-preview.sh +m $FZF_DEFAULT_OPTS --prompt 'Select file > '"
fi

~/.local/bin/st -T "Filepicker" -g 80x25+720+400 -e sh -c "$cmd > $out"

if ! [ -s "$out" ]; then
    exit 1
fi

# file_path=$(cat "$out")
# full_path="$HOME/$file_path"
#
# echo "$full_path" > "$out"
