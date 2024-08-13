source "$ZDOTDIR/modules/pre-defer.zsh"

defer=("$MOD/prompt.zsh" "$MOD/exports.zsh" "$MOD/aliases.zsh" "$MOD/bindkeys.zsh" "$MOD/compinit.zsh" "$MOD/zstyle.zsh" "$MOD/zoxide.zsh" "$MOD/fzf.zsh" "$MOD/functions.zsh" "$PLUG/vi-motions/motions.zsh" "$PLUG/zsh-autosuggestions/zsh-autosuggestions.zsh" "$PLUG/fast-syntax-highlighting/fast-syntax-highlighting.zsh")

for file in $defer; do
    zsh-defer source $file
done
