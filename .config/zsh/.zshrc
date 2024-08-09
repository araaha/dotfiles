export ZSH="$HOME/.config/zsh"
export PLUG="$ZSH/plugins"
export MOD="$ZSH/modules"

if [ -z $DISPLAY ]; then
    source "$ZSH/modules/tty.zsh"
fi

source "$PLUG/zsh-defer/zsh-defer.plugin.zsh"

#zvm must be above zsh-vi-mode
source "$MOD/zvm.zsh"
source "$PLUG/zsh-vi-mode/zsh-vi-mode.zsh"

zvm_after_init_commands+=("[[ -t 0 && $- = *i* ]] && stty -ixon")

source "$MOD/prompt.zsh"
source "$MOD/options.zsh"
source "$MOD/history.zsh"

zsh-defer source "$MOD/exports.zsh"
zsh-defer source "$MOD/aliases.zsh"
zsh-defer source "$MOD/bindkeys.zsh"

zsh-defer source "$MOD/zoxide.zsh"
zsh-defer source "$MOD/compinit.zsh"
zsh-defer source "$MOD/zstyle.zsh"

zsh-defer source "$PLUG/fzf.zsh"
zsh-defer source "$PLUG/functions.zsh"
zsh-defer source "$PLUG/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh-defer source "$PLUG/fast-syntax-highlighting/fast-syntax-highlighting.zsh"
