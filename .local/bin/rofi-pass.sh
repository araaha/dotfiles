#!/usr/bin/env bash
# Select a pass entry, then paste its password, OTP, or another field on Wayland.

umask 077
set -o pipefail
shopt -s nullglob globstar extglob

store=${PASSWORD_STORE_DIR:-$HOME/.password-store}
store=${store%/}
paste_delay=40  # Milliseconds for the application to consume each paste.

declare -A fields=()
clipboard_pid=''
clipboard_start=''
otp_uri=''
otp_method=''

menu() {
    rofi -dmenu -i -no-auto-select -no-custom -p "$1"
}

fail() {
    printf 'rofi-pass: %s\n' "$1" >&2
    return 1
}

pass_cmd() {
    PASSWORD_STORE_DIR="$store" pass "$@"
}

# Stop only our own clipboard owner; never clear a newer copied item.
process_start() {
    local stat
    local -a parts

    IFS= read -r stat 2>/dev/null < "/proc/$1/stat" || return 1
    read -r -a parts <<< "${stat##*) }"
    printf '%s' "${parts[19]}"
}

clear_clipboard() {
    local start

    if [[ -n $clipboard_pid ]]; then
        start=$(process_start "$clipboard_pid") || start=''
        if [[ -n $start && $start == "$clipboard_start" ]]; then
            kill "$clipboard_pid" 2>/dev/null || true
        fi
        wait "$clipboard_pid" 2>/dev/null || true
    fi

    clipboard_pid=''
    clipboard_start=''
}

paste_text() {
    local value=$1 current attempt

    clear_clipboard
    wl-copy --foreground --sensitive --type text/plain \
        < <(printf '%s' "$value") >/dev/null 2>&1 &
    clipboard_pid=$!
    clipboard_start=$(process_start "$clipboard_pid") || return 1

    # Wait for ownership before sending Ctrl+V. The sentinel preserves newlines.
    for ((attempt = 0; attempt < 50; attempt++)); do
        kill -0 "$clipboard_pid" 2>/dev/null || return 1
        if current=$(wl-paste --no-newline --type text/plain 2>/dev/null && printf '.'); then
            [[ $current != "$value." ]] || break
        fi
        sleep 0.01
    done

    [[ $attempt -lt 50 ]] || { fail 'Clipboard did not become ready.'; return 1; }
    wtype -M ctrl -k v -m ctrl -s "$paste_delay"
}

load_entry() {
    local content line key value reference
    local -a lines

    content=$(pass_cmd show "$selected") || return 1
    mapfile -t lines <<< "$content"

    if [[ ${lines[0]} == otpauth://* ]]; then
        otp_uri=${lines[0]}
    elif [[ ${lines[0]} == '#FILE='* ]]; then
        reference=$(pass_cmd show "${lines[0]#\#FILE=}") || return 1
        fields[pass]=${reference%%$'\n'*}
    else
        fields[pass]=${lines[0]}
    fi

    for line in "${lines[@]:1}"; do
        case $line in
            otpauth://*)
                [[ -n $otp_uri ]] || otp_uri=$line
                ;;
            *:*)
                key=${line%%:*}
                key=${key##+([[:space:]])}
                key=${key%%+([[:space:]])}
                value=${line#*:}
                value=${value##+([[:space:]])}

                case $key in
                    ''|pass|OTP) ;;
                    otp_method) otp_method=$value ;;
                    *) fields["$key"]=$value ;;
                esac
                ;;
        esac
    done

    [[ -z $otp_uri && -z $otp_method ]] || fields[OTP]=''

    if [[ -z ${fields[autotype]-} ]]; then
        if [[ -v 'fields[user]' && -v 'fields[pass]' ]]; then
            fields[autotype]='user :tab pass'
        elif [[ -v 'fields[pass]' ]]; then
            fields[autotype]=pass
        else
            fields[autotype]=OTP
        fi
    fi
}

# Decode only recognized OTP parameters; never put the secret in process args.
decode_parameter() {
    local text=$1 char
    REPLY=''

    while [[ -n $text ]]; do
        if [[ $text == %* ]]; then
            [[ ${text:1:2} =~ ^[[:xdigit:]]{2}$ && ${text:1:2} != 00 ]] || return 1
            printf -v char '%b' "\\x${text:1:2}"
            REPLY+=$char
            text=${text:3}
        else
            REPLY+=${text:0:1}
            text=${text:1}
        fi
    done
}

generate_otp() {
    if [[ -n $otp_method ]]; then
        printf '%s\n' "$otp_method" | PASSWORD_STORE_DIR="$store" bash
        return
    fi

    if [[ $otp_uri == otpauth://hotp/* ]]; then
        pass_cmd otp "$selected"  # pass-otp updates the HOTP counter.
        return
    fi

    [[ $otp_uri == otpauth://totp/*\?* ]] || { fail 'Invalid OTP URI.'; return 1; }

    local secret='' algorithm=SHA1 digits=6 period=30
    local param key REPLY
    local -a params
    IFS='&' read -r -a params <<< "${otp_uri#*\?}"

    for param in "${params[@]}"; do
        key=${param%%=*}
        case $key in
            secret|algorithm|digits|period)
                decode_parameter "${param#*=}" || return 1
                case $key in
                    secret) secret=$REPLY ;;
                    algorithm) algorithm=${REPLY^^} ;;
                    digits) digits=$REPLY ;;
                    period) period=$REPLY ;;
                esac
                ;;
        esac
    done

    if [[ ! $secret =~ ^[A-Za-z2-7]+=*$ ||
          ! $digits =~ ^([1-9]|10)$ || ! $period =~ ^[1-9][0-9]{0,8}$ ]]; then
        fail 'Invalid OTP parameters.'
        return 1
    fi

    case $algorithm in
        SHA1|SHA256|SHA512) ;;
        *) fail 'Unsupported OTP algorithm.'; return 1 ;;
    esac

    printf '%s\n' "$secret" |
        oathtool -b "--totp=$algorithm" "--digits=$digits" "--time-step-size=${period}s" -
}

paste_field() {
    local value

    case $1 in
        OTP|:otp) value=$(generate_otp) || return 1 ;;
        path) value=${selected##*/} ;;
        *)
            [[ -v 'fields[$1]' ]] || { fail "Unknown field: $1"; return 1; }
            value=${fields[$1]}
            ;;
    esac

    paste_text "$value"
}

autotype() {
    local word
    local -a sequence
    read -r -a sequence <<< "${fields[autotype]}"

    for word in "${sequence[@]}"; do
        case $word in
            :tab) wtype -k Tab ;;
            :enter) wtype -k Return ;;
            :space) wtype -k space ;;
            :delay) sleep 1 ;;
            *) paste_field "$word" ;;
        esac || return 1
    done
}

main() {
    local tool file field
    local -a entries=()

    for tool in pass rofi wtype wl-copy wl-paste; do
        command -v "$tool" >/dev/null || { fail "Missing command: $tool"; return 1; }
    done
    [[ -d $store ]] || { fail 'Password store does not exist.'; return 1; }

    for file in "$store"/**/*.gpg; do
        [[ -f $file ]] && entries+=("${file#"$store"/}")
    done
    [[ ${#entries[@]} -gt 0 ]] || return 0

    selected=$(printf '%s\n' "${entries[@]%.gpg}" | menu '  ') || return 0
    [[ -n $selected && -f $store/$selected.gpg ]] || return 0
    load_entry || return 1

    field=$(
        {
            printf '%s\n' autotype
            [[ ! -v 'fields[pass]' ]] || printf '%s\n' pass
            for field in "${!fields[@]}"; do
                [[ $field == autotype || $field == pass ]] || printf '%s\n' "$field"
            done | sort
        } | menu '  '
    ) || return 0

    if [[ $field == autotype ]]; then
        autotype
    elif [[ -n $field ]]; then
        paste_field "$field"
    fi
}

trap clear_clipboard EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main
fi
