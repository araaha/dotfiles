bindkey -r "^S"
bindkey -r "^Q"
bindkey "^W" backward-kill-word
bindkey "^H" backward-kill-word
bindkey "^K" kill-whole-line
bindkey "^[q" accept-and-menu-complete
bindkey "^[x" accept-and-hold
bindkey "^A" end-of-line
bindkey -s "^[z" " | fzf\n"

bindkey -M viins "^?" backward-delete-char
bindkey -M vicmd "D" kill-whole-line
bindkey -M vicmd "M" kill-line
bindkey -M vicmd "H" beginning-of-line
bindkey -M vicmd "L" end-of-line

exit_zsh() { exit }
zle -N exit_zsh
bindkey -M vicmd "^D" exit_zsh
bindkey -M viins "^D" exit_zsh

bindkey -M vicmd "K" run-help

autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd "^[e" edit-command-line

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "\e[5;3~" history-search-backward
bindkey "\e[6;3~" history-search-forward

zmodload zsh/complist
bindkey -M menuselect "/" history-incremental-search-forward
bindkey -M menuselect "^?" backward-delete-char
bindkey -M menuselect "^[[Z" reverse-menu-complete
bindkey -M menuselect "^[[5~" backward-word
bindkey -M menuselect "^[[6~" forward-word
bindkey -M menuselect "^P" up-line-or-history
bindkey -M menuselect "^N" down-line-or-history
bindkey "^N" menu-complete

bindkey -M visual '^C' deactivate-region
bindkey -M viins '^C' vi-cmd-mode
bindkey -M viopp '^C' vi-cmd-mode
bindkey -M isearch '^C' vi-cmd-mode
bindkey -M visual 'R' vi-change-whole-line
