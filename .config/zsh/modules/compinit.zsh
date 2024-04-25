fpath=($fpath $ZDOTDIR/plugins/custom-completions/)
autoload -Uz compinit
if [ $(date +'%j') != $(date -r $ZSH/.zcompdump +'%j') ]; then
    compinit
else
    compinit -C
fi
