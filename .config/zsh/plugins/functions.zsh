#!/bin/sh
rga_fzf() {
    RG_PREFIX="rga --files-with-matches"
        file="$(
                FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
                fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
                --phony -q "$1" \
                --bind "change:reload:$RG_PREFIX {q}" \
                --preview-window="70%:wrap" \
                --ansi
               )" &&
        echo "opening $file" &&
        xdg-open "$file"
}

ofzf() {
    tmpfzf() {
        sel="$(rg --color=never --files --hidden  --follow --no-messages -g "!**.mp3" -g "!**.pdf" -g "!**.sqlite" -g "!**.sqlite" -g "!**.png" -g "!**.jpg" -g "!**.jpeg" -g "!**.epub" | fzf-tmux -p 60%,80% --bind 'ctrl-l:become(lf {})' --layout=reverse  --preview-window 'up,50%' --preview "bat --style=plain --color=always --line-range :500 {}")"
            if [ -n "$sel" ]; then
                files=$(echo $sel | tr '\n' ' ')
                    nvim $(echo "$files")
                    echo -n "$files\n"
                    print -s "nv $files"
            else
                return
                    fi
    }
    tmpfzf
        sed -i "/ofzf/d" ~/.local/share/zsh/history
}

ofzf1() {
    tmpfzf() {
        sel="$(rg --color=never --files --hidden  --follow --no-messages -g "!**.mp3" -g "!**.pdf" -g "!**.sqlite" -g "!**.sqlite" -g "!**.png" -g "!**.jpg" -g "!**.jpeg" -g "!**.epub" | fzf-tmux -p 60%,80%  --bind 'ctrl-l:become(lf {})' --layout=reverse  --preview-window 'up,50%' --preview "bat --style=plain --color=always --line-range 1:500 {}")"
            if [ -n "$sel" ]; then
                files=$(echo "$sel" | tr '\n' ' ')
                    nvim $(echo "$files")
                    print -s "nv $files"
            else
                return
                    fi
    }
    tmpfzf
        sed -i "/ofzf/d" ~/.local/share/zsh/history
}

