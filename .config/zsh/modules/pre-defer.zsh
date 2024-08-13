export PLUG="$ZDOTDIR/plugins"
export MOD="$ZDOTDIR/modules"

black="%F{#242424}"
green="%K{#9DC365}"
red="%F{#FB4934}"
PROMPT="%{$red%}%~%f
%{$black%}%{$green%} I %k%f%F{green}|> %f"

if [ -z $DISPLAY ]; then
    source "$ZSH/modules/tty.zsh"
fi

source "$PLUG/zsh-defer/zsh-defer.plugin.zsh"
source "$MOD/options.zsh"
source "$MOD/history.zsh"

KEYTIMEOUT=1

if [[ -t 0 && $- = *i* ]]; then
    stty intr ^C
    bindkey -M viins '^C' vi-cmd-mode
    stty intr ^Z
    stty -ixon
fi
