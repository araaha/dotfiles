export ZSH="$HOME/.config/zsh"

if [ -z $DISPLAY ]; then
    source "$ZSH/modules/tty.zsh"
fi

source "$ZSH/plugins/zsh-defer/zsh-defer.plugin.zsh"

#zvm must be above zsh-vi-mode
source "$ZSH/modules/zvm.zsh"
source "$ZSH/plugins/zsh-vi-mode/zsh-vi-mode.zsh"

zvm_after_init_commands+=("source $ZSH/modules/bindkeys.zsh")
zvm_after_init_commands+=("source $ZSH/plugins/fzf.zsh")
zvm_after_init_commands+=("[[ -t 0 && $- = *i* ]] && stty -ixon")

source "$ZSH/modules/prompt.zsh"
source "$ZSH/modules/options.zsh"
source "$ZSH/modules/history.zsh"

zsh-defer source "$ZSH/modules/exports.zsh"
zsh-defer source "$ZSH/modules/aliases.zsh"

zsh-defer source "$ZSH/modules/zoxide.zsh"
zsh-defer source "$ZSH/modules/compinit.zsh"
zsh-defer source "$ZSH/modules/zstyle.zsh"

zsh-defer source "$ZSH/plugins/functions.zsh"
zsh-defer source "$ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh-defer source "$ZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.zsh"
