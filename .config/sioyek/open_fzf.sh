tmpfile=$(mktemp)

FZF_DEFAULT_COMMAND="RIPGREP_CONFIG_PATH=/home/araaha/.config/ripgreprc rg --files --hidden --follow --no-messages --no-ignore --color=never"

FZF_DEFAULT_OPTS="--no-scrollbar --border=none --no-separator  --tiebreak=length,end,chunk --padding 0% --margin 0% --multi --reverse --preview-window noborder --height=100% --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#9cd365,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --bind home:first --bind end:last --bind ctrl-r:toggle-raw  --bind ctrl-d:half-page-down --bind ctrl-u:half-page-up --bind 'ctrl-y:offset-up' --bind 'ctrl-e:offset-down' --bind 'ctrl-a:select-all'"

st -T "Filepicker" -g 100x20+370+500 -e sh -c "eval $FZF_DEFAULT_COMMAND /home/araaha --glob '*.pdf' --glob '*.epub' --glob '*.djvu' | fzf $FZF_DEFAULT_OPTS > '$tmpfile'"

if [ -s "$tmpfile" ]; then
    sioyek --reuse-window "$(cat "$tmpfile")"
fi

cat "$tmpfile"
rm -f "$tmpfile"


