#!/bin/sh
ofzf() {
    tmpfzf() {
        sel="$(rg --color=never --files --hidden  --follow --no-messages -g "!**.mp3" -g "!**.pdf" -g "!**.sqlite" -g "!**.sqlite" -g "!**.png" -g "!**.jpg" -g "!**.jpeg" -g "!**.epub" |  fzf --tmux 60%,80% --bind 'ctrl-l:become(lf {})' --layout=reverse  --preview-window 'up,50%' --preview "bat --style=plain --color=always --line-range :500 {}")"
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
        sel="$(rg --color=never --files --hidden  --follow --no-messages -g "!**.mp3" -g "!**.pdf" -g "!**.sqlite" -g "!**.sqlite" -g "!**.png" -g "!**.jpg" -g "!**.jpeg" -g "!**.epub" |  fzf --tmux 60%,80% --bind 'ctrl-l:become(lf {})' --layout=reverse  --preview-window 'up,50%' --preview "bat --style=plain --color=always --line-range 1:500 {}")"
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

rfv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf < /dev/null \
      --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --height 70% \
      --preview 'bat --paging=always --color=always --highlight-line {2} {1}' \
      --preview-window '~0,+{2}+1/2,<80(up)' \
      --query "$*"
)
