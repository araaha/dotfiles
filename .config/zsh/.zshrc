export ZSH="$HOME/.config/zsh"

if [ -z $DISPLAY ]; then
    source "$ZSH/configs/tty.zsh"
fi

source "$ZSH/plugins/zsh-defer/zsh-defer.plugin.zsh"

#zvm must be above zsh-vi-mode
source "$ZSH/configs/zvm.zsh" 
source "$ZSH/plugins/zsh-vi-mode/zsh-vi-mode.zsh"

zvm_after_init_commands+=('source $ZSH/configs/bindkeys.zsh')
zvm_after_init_commands+=('source $ZSH/plugins/fzf.zsh') 
zvm_after_init_commands+=('[[ -t 0 && $- = *i* ]] && stty -ixon')

source "$ZSH/configs/prompt.zsh"
source "$ZSH/configs/options.zsh"
source "$ZSH/configs/history.zsh"

zsh-defer source "$ZSH/configs/exports.zsh"
zsh-defer source "$ZSH/configs/aliases.zsh"

zsh-defer source "$ZSH/configs/zoxide.zsh"
zsh-defer source "$ZSH/configs/compinit.zsh"
zsh-defer source "$ZSH/configs/zstyle.zsh"

zsh-defer source "$ZSH/plugins/functions"
zsh-defer source "$ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh-defer source "$ZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.zsh"
