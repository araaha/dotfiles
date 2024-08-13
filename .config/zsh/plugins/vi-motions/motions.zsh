#!/usr/bin/env zsh
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
fpath+=( "${0:h}/functions" )

autoload -Uz select-quoted select-bracketed surround
autoload -Uz - -viopp-wrapper -viopp-wrapper-push-string

(){
    local m seq

    # More text objects from zsh/functions/Zle
    zle -N select-quoted
    zle -N select-bracketed
    for m in vicmd viopp; do
        for seq in {a,i}{\',\",\`}; do
            bindkey -M "$m" "$seq" select-quoted
        done
        for seq in {a,i}${(s..)^:-'()[]{}<>bB'}; do
            bindkey -M "$m" "$seq" select-bracketed
        done
    done

    # Load Vi-surround from zsh/functions/Zle
    zle -N delete-surround surround
    zle -N add-surround surround
    zle -N change-surround surround

    zle -N zvmm-vi-change   -viopp-wrapper
    zle -N zvmm-vi-delete   -viopp-wrapper
    zle -N zvmm-vi-yank     -viopp-wrapper
    zle -N zvmm-push-string -viopp-wrapper-push-string

    bindkey -M vicmd c zvmm-vi-change d zvmm-vi-delete y zvmm-vi-yank
    bindkey -M visual c vi-change d vi-delete y vi-yank
    bindkey -M visual S add-surround
}
