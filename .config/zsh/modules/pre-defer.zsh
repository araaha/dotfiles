export PLUG="$ZDOTDIR/plugins"
export MOD="$ZDOTDIR/modules"

black="%F{#242424}"
green="%K{#9DC365}"
red="%F{#FB4934}"
blue="%K{#7DAEA3}"
PROMPT="%{$red%}%~%f
%{$black%}%{$green%} I %k%f%{$blue%}█ %k"

if [ -z $DISPLAY ]; then
    source "$MOD/tty.zsh"
fi

source "$PLUG/zsh-defer/zsh-defer.plugin.zsh"
source "$MOD/options.zsh"
source "$MOD/history.zsh"

KEYTIMEOUT=1
bindkey -v

preexec() {
    [[ -t 0 && $- = *i* ]] && stty intr ^C
}

bindkey -M viins '^C' vi-cmd-mode

precmd() {
    [[ -t 0 && $- = *i* ]] && stty intr ^Z
}
