bindkey -r '^S'
bindkey '^W' backward-kill-word
bindkey '^ ' autosuggest-accept
bindkey '^K' kill-whole-line
bindkey '^[f' kill-line
bindkey '^[q' accept-and-menu-complete
bindkey '^[x' accept-and-hold

zle -N ofzf
zle -N ofzf1
bindkey -s '^O' '\C-k ofzf\n'
bindkey -M vicmd '^O' 'ofzf1'
bindkey -M vicmd 'D' kill-whole-line
bindkey -M vicmd 'M' kill-line
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line
bindkey -M vicmd '^D' exit
bindkey -M vicmd 'K' run-help

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey '\e[5;3~' history-search-backward
bindkey '\e[6;3~' history-search-forward

zmodload zsh/complist
bindkey -M menuselect '^F' history-incremental-search-forward
bindkey -M menuselect '^?' backward-delete-char
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey -M menuselect "^[[5~" backward-word
bindkey -M menuselect "^[[6~" forward-word
