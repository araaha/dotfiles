export HISTFILE="$HOME/.local/share/zsh/history"
export HISTSIZE=5000
export SAVEHIST=$HISTSIZE

zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }
