#!/usr/bin/env zsh
# Compile without executing shell configuration. Only rebuild changed sources.
emulate -L zsh
setopt extendedglob

zsh_dir=${ZDOTDIR:-${0:A:h:h}/.config/zsh}
[[ -d $zsh_dir ]] || { print -u2 -- "Missing Zsh config: $zsh_dir"; exit 1; }

sources=(
    "$zsh_dir"/.zshrc
    "$zsh_dir"/.zlogin
    "$zsh_dir"/modules/*.zsh(N)
    "$zsh_dir"/plugins/**/*.zsh(N)
    "$zsh_dir"/plugins/fast-syntax-highlighting/fast-highlight
    "$zsh_dir"/plugins/fast-syntax-highlighting/fast-string-highlight
    "$zsh_dir"/plugins/fast-syntax-highlighting/functions/*(DN.)
    "$zsh_dir"/.zcompdump
)

integer rebuilt=0 failed=0
for source in "${sources[@]}"; do
    [[ -f $source && $source != *.zwc ]] || continue
    if [[ ! -s $source.zwc || $source -nt $source.zwc ]]; then
        zcompile -U -- "$source" && (( ++rebuilt )) || {
            print -u2 -- "Could not compile: $source"
            failed=1
        }
    fi
done
if (( rebuilt > 0 )); then
    [[ -t 1 ]] && print -- "Rebuilt $rebuilt Zsh cache files."
fi
exit $failed
