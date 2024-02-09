zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

zstyle ':completion:*' completer _complete _match
zstyle ':completion:*' menu yes select
zstyle ':completion:*' ignored-patterns '_*'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
