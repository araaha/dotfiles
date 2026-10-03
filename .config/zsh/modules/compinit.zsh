fpath=($fpath $ZDOTDIR/plugins/zsh-completion-generator/custom-completions/)
autoload -Uz compinit
# A full check also notices added/removed completions after migration.
# Keep the dump at the same path compiled by .zlogin.
compinit -d "$ZDOTDIR/.zcompdump"
