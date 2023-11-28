function zvm_config() {
  ZVM_CURSOR_STYLE_ENABLED=false
  ZVM_ESCAPE_KEYTIMEOUT=0.03
  ZVM_KEYTIMEOUT=0.4
  ZVM_VI_SURROUND_BINDKEY=classic
  ZVM_LAZY_KEYBINDINGS=true
  ZVM_VI_HIGHLIGHT_BACKGROUND=#3f3f3f
  ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_VI_INSERT_ESCAPE_BINDKEY=^C
  ZVM_VI_VISUAL_ESCAPE_BINDKEY=^C
}

preexec() {
    [[ -t 0 && $- = *i* ]] && stty intr ^C
}

bindkey -M viins '^C' vi-cmd-mode

precmd() {
    [[ -t 0 && $- = *i* ]] && stty intr ^Z
}
