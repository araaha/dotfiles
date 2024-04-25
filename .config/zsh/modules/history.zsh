export HISTFILE="$HOME/.local/share/zsh/history"
export HISTSIZE=4000
export SAVEHIST=4000
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

