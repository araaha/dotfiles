#!/usr/bin/env bash
# Carillon passes: account, message ID, mailbox.
if (( $# < 2 || $# > 3 )); then
    printf 'Usage: mail.sh ACCOUNT MESSAGE_ID [MAILBOX]\n' >&2
    exit 2
fi

message=$(himalaya -a "$1" -b imap message read --mailbox "${3:-INBOX}" -- "$2") || exit 1

# Skip headers, MIME metadata and HTML tags; take the first 4–6 character code.
# Codes contain only uppercase letters and digits.
code=$(printf '%s\n' "$message" |
    awk 'body && !/^[[:space:]]*Content-/ && !/^\[[0-9]+\]/ {gsub(/<[^>]*>/, " "); print} /^[[:space:]]*$/ {body=1}' |
    rg -o '\b[A-Z0-9]{4,6}\b' |
    head -n 1)

[[ -n $code ]] || exit 0
printf '%s' "$code" | wl-copy --type text/plain >/dev/null 2>&1
