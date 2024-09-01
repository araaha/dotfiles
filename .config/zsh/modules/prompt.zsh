autoload -U add-zle-hook-widget

black="%F{#242424}"
red="%F{#FB4934}"
blue="%K{#7DAEA3}"
green="%K{#9DC365}"
magenta="%K{#D3869B}"
yellow="%K{#D8A657}"

# update PROMPT between different vi modes
function line_pre_redraw {
    local previous_vi_keymap="${VI_KEYMAP}"

    case "${KEYMAP}" in
        vicmd)
            case "${REGION_ACTIVE}" in
                1)
                    VI_KEYMAP="VISUAL"
                    ;;
                2)
                    VI_KEYMAP="V-LINE"
                    ;;
                *)
                    VI_KEYMAP="NORMAL"
                    ;;
            esac
            ;;
        viins|main)
            if [[ "${ZLE_STATE}" == *overwrite* ]]; then
                VI_KEYMAP="REPLACE"
            else
                VI_KEYMAP="INSERT"
            fi
            ;;
    esac

    if [[ "${VI_KEYMAP}" != "${previous_vi_keymap}" ]]; then
        zle reset-prompt
    fi
}
add-zle-hook-widget zle-line-pre-redraw line_pre_redraw

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

function generate_prompt {
    local TMP_RET=$?
    local prompt_segment
    local prompt_ending

    prompt_ending="%F{blue}█ %f"
    prompt_segment="%{$black%}%{$green%} I %k%f"

    case "${VI_KEYMAP}" in
        NORMAL) prompt_segment="%{$black%}%{$blue%} N %k%f" ;;
        INSERT) prompt_segment="%{$black%}%{$green%} I %k%f" ;;
        VISUAL) prompt_segment="%{$black%}%{$yellow%} V %k%f" ;;
        V-LINE) prompt_segment="%{$black%}%{$yellow%} VL %k%f" ;;
        REPLACE) prompt_segment="%{$black%}%{$magenta%} R %k%f" ;;
    esac

    # Include the return code if it's non-zero
    if [[ ${TMP_RET} != 0 ]]; then
        prompt_ending="%{$black%}%{$red%}█%k%f "
    fi

    echo -n "%{$red%}%~%f\n${prompt_segment}${prompt_ending}"
}

# Set PS1 using the generate_prompt function
PROMPT='$(generate_prompt)$(lf-prompt)'
