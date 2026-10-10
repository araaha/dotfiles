export HISTFILE="$HOME/.local/share/zsh/history"
export HISTSIZE=7000
export SAVEHIST=$HISTSIZE

# Keep valid commands even when prefixed by environment assignments.
zshaddhistory() {
    emulate -L zsh
    setopt extendedglob
    local -a words
    local word line=${1%$'\n'}
    words=("${(@z)line}")

    for word in "${words[@]}"; do
        # Do not execute assignments or expand their values while filtering.
        [[ $word == [A-Za-z_][A-Za-z0-9_]#=* ]] && continue
        builtin whence -- "${(Q)word}" >/dev/null 2>&1
        return $?
    done

    # Assignment-only lines are valid shell input too.
    return 0
}
