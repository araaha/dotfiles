eval "$(fzf --zsh)"

export FZF_ALT_C_COMMAND="fd --hidden --type directory ."
export FZF_ALT_C_OPTS="--info=hidden"
export FZF_CTRL_R_OPTS="--reverse --info=hidden"
export FZF_CTRL_T_OPTS="--preview-window 'up,50%' --preview 'bat --wrap=auto --style=plain --color=always --line-range=1:25 {} '"
export FZF_DEFAULT_COMMAND="RIPGREP_CONFIG_PATH=$HOME/.config/ripgreprc rg --files --hidden --follow --no-messages --no-ignore --color=never"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--prompt '' --no-scrollbar --border=bold --no-separator  --tiebreak=length,end,chunk --padding 0% --margin 0% --multi --reverse --preview-window noborder --height=50% --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#9cd365,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --bind home:first --bind end:last --bind ctrl-p:up --bind ctrl-d:half-page-down --bind ctrl-u:half-page-up --bind 'ctrl-l:become(lf {})' --bind 'ctrl-y:offset-up' --bind 'ctrl-e:offset-down' --bind 'ctrl-a:select-all'"

export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 60%,80%"

_fzf_compgen_path() {
    fd -E '.cache' -E 'icons' -E 'themes' -E '**pkg' -E '.git' -E 'state' -E 'google-chrome' -E 'opt' -E 'chromium' -E 'firefox' -E 'cargo' --hidden --follow . "$1"
}

# # Use fd to generate the list for directory completion
# _fzf_compgen_dir() {
#     fd --type d --exclude ".git" . "$1"
# }
#

ofzf() {
    sel="$(eval $FZF_DEFAULT_COMMAND | fzf --tmux 60%,80% --preview-window 'up,50%' --preview 'bat --style=plain --color=always --line-range :500 {}')"
    if [ -n "$sel" ]; then
        nvim $(echo "$sel")
        echo "$sel"
        print -s "nv $sel"
    fi
    sed -i "/ofzf/d" "$HISTFILE"
}

bindkey -s "^O" "\C-k ofzf\n"

ofzf-widget() {
    sel="$(eval $FZF_DEFAULT_COMMAND | fzf --tmux 60%,80% --preview-window 'up,50%' --preview 'bat --style=plain --color=always --line-range :500 {}')"
    if [ -n "$sel" ]; then
        nvim $(echo "$sel")
        print -s "nv $sel"
    fi
    sed -i "/ofzf/d" "$HISTFILE"
}

zle -N ofzf-widget
bindkey -a "^O" ofzf-widget
