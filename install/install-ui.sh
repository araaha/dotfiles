#!/usr/bin/env bash
# Shared installer presentation. DOTFILES_PLAIN=1 forces text prompts.
ui_gum() {
    [[ ${DOTFILES_PLAIN:-0} != 1 && -t 0 && -t 2 ]] && command -v gum >/dev/null
}

# Match yazi-wrapper: cream text, green selection, dark selected text.
ui_gum_run() {
    local text="#fbf1c7" green="#9cd365" dark="#242424"
    GUM_INPUT_PROMPT_FOREGROUND="$text" \
    GUM_INPUT_HEADER_FOREGROUND="$text" \
    GUM_INPUT_CURSOR_FOREGROUND="$green" \
    GUM_CHOOSE_HEADER_FOREGROUND="$text" \
    GUM_CHOOSE_ITEM_FOREGROUND="$text" \
    GUM_CHOOSE_CURSOR_FOREGROUND="$green" \
    GUM_CHOOSE_SELECTED_BACKGROUND="$green" \
    GUM_CHOOSE_SELECTED_FOREGROUND="$dark" \
    GUM_SPIN_SPINNER_FOREGROUND="$green" \
    GUM_SPIN_TITLE_FOREGROUND="$text" \
        gum "$@"
}

ui_message() {
    local kind=$1 color
    shift
    case "$kind" in
        error) color="#fb4934" ;;
        success) color="#9cd365" ;;
        *) color="#fbf1c7" ;;
    esac
    if ui_gum && [[ -t 1 && -z ${NO_COLOR:-} ]]; then
        ui_gum_run style --foreground "$color" --bold -- "==> $*"
    else
        printf '==> %s\n' "$*"
    fi
}

ui_input() {
    local label=$1 default=${2:-} input
    if ui_gum; then
        ui_gum_run input --prompt "$label: " --value "$default"
    else
        [[ -t 0 ]] || { printf 'An interactive terminal is required.\n' >&2; return 1; }
        read -r -p "$label${default:+ [$default]}: " input || return
        printf '%s\n' "${input:-$default}"
    fi
}

ui_choose() {
    local label=$1 input option index=0
    shift
    if ui_gum; then
        ui_gum_run choose --header "$label" -- "$@"
        return
    fi
    printf '%s\n' "$label" >&2
    for option in "$@"; do
        printf '  %d) %s\n' "$((++index))" "$option" >&2
    done
    input=$(ui_input 'Choice' 1) || return
    index=0
    for option in "$@"; do
        ((++index))
        if [[ $input == "$index" || $input == "$option" ]]; then
            printf '%s\n' "$option"
            return
        fi
    done
    printf 'Invalid choice: %s\n' "$input" >&2
    return 1
}

ui_choose_many() {
    local label=$1 defaults=$2 input token option index=0 found
    local -a tokens
    shift 2
    if ui_gum; then
        ui_gum_run choose --no-limit --header "$label" --selected "$defaults" -- "$@"
        return
    fi
    printf '%s\n' "$label" >&2
    for option in "$@"; do
        printf '  %d) %s\n' "$((++index))" "$option" >&2
    done
    input=$(ui_input 'Names or numbers, separated by spaces or commas' "$defaults") || return
    input=${input//,/ }
    read -r -a tokens <<< "$input"
    for token in "${tokens[@]}"; do
        index=0
        found=false
        for option in "$@"; do
            ((++index))
            if [[ $token == "$index" || $token == "$option" ]]; then
                printf '%s\n' "$option"
                found=true
                break
            fi
        done
        if [[ $found == false ]]; then
            printf 'Invalid choice: %s\n' "$token" >&2
            return 1
        fi
    done
}

ui_run_quiet() {
    local label=$1
    shift
    if ui_gum; then
        ui_gum_run spin --show-output --title "$label" -- "$@"
    else
        "$@"
    fi
}

ui_summary() {
    local title=$1
    shift
    ui_message success "$title"
    printf '  %s\n' "$@"
}
