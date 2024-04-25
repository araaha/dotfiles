function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
     PROMPT="%F{#fb4934}%~%f% 
%F{#242424}%K{#7DAEA3} N %k%f%F{green}|>%f%f $(lf-prompt)"
     zle reset-prompt
    ;;
    $ZVM_MODE_INSERT)
     PROMPT="%F{#fb4934}%~%f%F{green} 
%F{#242424}%K{#9dc365} I %k%f%F{green}|>%f%f $(lf-prompt)"
     zle reset-prompt
    ;;
    $ZVM_MODE_VISUAL)
     PROMPT="%F{#fb4934}%~%f%F{green} 
%F{#242424}%K{#D8A657} V %k%f%F{green}|>%f%f $(lf-prompt)"
     zle reset-prompt
    ;;
    $ZVM_MODE_VISUAL_LINE)
     PROMPT="%F{#fb4934}%~%f%F{green} 
%F{#242424}%K{#D8A657} VL %k%f%F{green}|>%f%f $(lf-prompt)"
     zle reset-prompt
    ;;
    $ZVM_MODE_REPLACE)
     PROMPT="%F{#fb4934}%~%f%F{green} 
%F{#242424}%K{#D3869B} R %k%f%F{green}|>%f%f $(lf-prompt)"
     zle reset-prompt
    ;;
  esac
}


function lf-prompt {
    if [[ "$LF_LEVEL" == "1" ]]
    then 
        echo -n "LF "
    elif [ "$LF_LEVEL" -ge 1 ] 
    then
        echo -n "LF $LF_LEVEL "
    else 
        echo -n ""
    fi 
}


PROMPT="%F{#fb4934}%~%f%F{green} 
%F{#242424}%K{#9dc365} I %k%f%F{green}|>%f%f $(lf-prompt)"
