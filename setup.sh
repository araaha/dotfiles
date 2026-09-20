#!/usr/bin/env bash
set -euo pipefail

DOTS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=""

readonly -a REQUIRED_COMMANDS=(yay git dinitctl)
readonly -a DINIT_SERVICES=(cronie bluetoothd iwd chronyd chrony)

die() {
    echo "error: $*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null || die "Required command missing: $1"
}

cleanup() {
    [[ -z "$TEMP_DIR" ]] || rm -rf -- "$TEMP_DIR"
}

check_prerequisites() {
    local command manifest
    (( EUID != 0 )) || die "Run as your ordinary user, not root."

    for command in "${REQUIRED_COMMANDS[@]}"; do
        require_command "$command"
    done

    # shellcheck source=/dev/null
    source /etc/os-release
    [[ "${ID:-}" == artix ]] || die "Only Artix is supported."

    for manifest in arch-apps.txt aur-apps.txt; do
        [[ -s "$DOTS/install/$manifest" ]] || die "Missing manifest: $manifest"
    done
}

install_packages() {
    yay -Syu
    yay --needed -S - < <(cat "$DOTS/install/arch-apps.txt" "$DOTS/install/aur-apps.txt")
}


    sudo pacman -Syu --needed --noconfirm artix-archlinux-support
    sudo install -d -m 0755 /etc/pacman.d
    sudo install -m 0644 "$DOTS/etc/pacman.conf" /etc/pacman.conf
    sudo install -m 0644 "$DOTS/etc/pacman.d/mirrorlist" /etc/pacman.d/mirrorlist
    sudo install -m 0644 "$DOTS/etc/pacman.d/mirrorlist-arch" /etc/pacman.d/mirrorlist-arch
}

replace_with_link() {
    local source=$1 target=$2
    if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
        return
    fi
    rm -rf -- "$target"
    ln -s -- "$source" "$target"
}

install_dotfiles() {
    local directory source
    # Replace directory symlinks before installing children, so writes stay outside the repo.
    for directory in "$HOME/.config" "$HOME/.local" "$HOME/.local/share"; do
        if [[ -L "$directory" || ( -e "$directory" && ! -d "$directory" ) ]]; then
            rm -rf -- "$directory"
        fi
        mkdir -p "$directory"
    done
    mkdir -p "$HOME/Downloads" "$HOME/Books" "$HOME/Screenshots"
    replace_with_link "$DOTS/scripts" "$HOME/scripts"
    shopt -s dotglob nullglob
    for source in "$DOTS/.config/"*; do
        replace_with_link "$source" "$HOME/.config/${source##*/}"
    done
    for source in "$DOTS/.local/share/"*; do
        case "${source##*/}" in themes|icons) continue ;; esac
        replace_with_link "$source" "$HOME/.local/share/${source##*/}"
    done
    replace_with_link "$DOTS/.local/bin" "$HOME/.local/bin"
}

install_themes() {
    local archive category destination source target
    # Stage downloaded assets before replacing any existing theme/icon directories.
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/themes"
    for archive in "$DOTS/.local/share/themes/"*.tar.gz; do
        tar -xzf "$archive" -C "$TEMP_DIR/themes"
    done
    git clone --depth 1 https://github.com/SylEleuth/gruvbox-plus-icon-pack "$TEMP_DIR/icons"
    for category in themes icons; do
        destination="$HOME/.local/share/$category"
        if [[ -L "$destination" || ( -e "$destination" && ! -d "$destination" ) ]]; then
            rm -rf -- "$destination"
        fi
        mkdir -p "$destination"
    done
    for source in "$TEMP_DIR/themes/"* "$TEMP_DIR/icons/Gruvbox-Plus-Dark"; do
        [[ -e "$source" ]] || die "Missing staged asset: $source"
        category=themes
        [[ "$source" == "$TEMP_DIR/icons/"* ]] && category=icons
        target="$HOME/.local/share/$category/${source##*/}"
        rm -rf -- "$target"
        cp -a -- "$source" "$target"
    done
}

install_system_files() {
    for directory in etc usr; do
        sudo cp -r --remove-destination -- "$DOTS/$directory/." "/$directory/"
    done
}

configure_user() {
    local username shell
    username=$(id -un)
    shell=$(command -v zsh)
    grep -Fxq "$shell" /etc/shells || die "zsh is not listed in /etc/shells"
    sudo usermod -aG video,input "$username"
    sudo chsh -s "$shell" "$username"
}

configure_sudo() {
    local policy
    policy=$(mktemp)
    cat > "$policy" <<'POLICY'
Defaults !tty_tickets
Defaults timestamp_timeout=30
Defaults passwd_tries=10
Defaults passwd_timeout=0
POLICY
    sudo visudo -cf "$policy"
    sudo install -d -m 0750 /etc/sudoers.d
    sudo install -o root -g root -m 0440 "$policy" /etc/sudoers.d/dotfiles
    rm -f -- "$policy"
    sudo visudo -c
}

configure_services() {
    local service
    for service in "${DINIT_SERVICES[@]}"; do
        sudo dinitctl enable "$service"
    done
}

refresh_caches() {
    fc-cache -f
    bat cache --build
}

main() {
    trap cleanup EXIT
    check_prerequisites
    configure_package_repositories
    install_packages
    install_dotfiles
    install_themes
    install_system_files
    configure_user
    configure_sudo
    configure_services
    refresh_caches
    echo "Setup complete. Reboot."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
