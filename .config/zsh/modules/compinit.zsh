fpath=($fpath $ZDOTDIR/plugins/zsh-completion-generator/custom-completions/)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

