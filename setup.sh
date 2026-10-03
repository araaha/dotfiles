#!/usr/bin/env bash
set -euo pipefail

DOTS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTS
# shellcheck source=install/install-ui.sh
source "$DOTS/install/install-ui.sh"
readonly NETWORK_CONFIG=/etc/dotfiles-network
TEMP_DIR=""

readonly -a REQUIRED_COMMANDS=(yay git dinitctl)
readonly -a DINIT_SERVICES=(cronie bluetoothd chronyd chrony)

die() {
    ui_message error "$*" >&2
    exit 1
}

step() { ui_message step "$*"; }
success() { ui_message success "$*"; }

print_readonly_variables() {
    step "Read-only configuration"
    printf '  DOTS=%s\n' "$DOTS"
    printf '  NETWORK_CONFIG=%s\n' "$NETWORK_CONFIG"
    printf '  REQUIRED_COMMANDS=%s\n' "${REQUIRED_COMMANDS[*]}"
    printf '  DINIT_SERVICES=%s\n' "${DINIT_SERVICES[*]}"
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
    yay --needed -S - < "$DOTS/install/arch-apps.txt"
}

install_aur_packages() {
    yay --needed -S - < "$DOTS/install/aur-apps.txt"
}

install_labwc() (
    # Build outside the checkout; retain the package for reinstalling or rollback.
    local build_dir
    sudo pacman -S --needed base-devel
    mkdir -p -- "${XDG_CACHE_HOME:-$HOME/.cache}"
    build_dir=$(mktemp -d "${XDG_CACHE_HOME:-$HOME/.cache}/labwc-patched.XXXXXX")
    cp -- "$DOTS/install/labwc-patched/"* "$build_dir/"
    cd -- "$build_dir"
    makepkg --syncdeps --install --cleanbuild
)

configure_package_repositories() {
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
    local network_mode network_package network_service service

    [[ -r "$NETWORK_CONFIG" ]] || die "Missing network selection: $NETWORK_CONFIG"
    read -r network_mode < "$NETWORK_CONFIG"
    case "$network_mode" in
        wifi)
            network_package=iwd-dinit
            network_service=iwd
            ;;
        ethernet)
            network_package=dhcpcd-dinit
            network_service=dhcpcd
            ;;
        *) die "Invalid network selection in $NETWORK_CONFIG: $network_mode" ;;
    esac
    pacman -Q "$network_package" >/dev/null || die "Missing network package: $network_package"

    for service in "${DINIT_SERVICES[@]}"; do
        enable_service "$service"
    done
    enable_service "$network_service"
}

enable_service() {
    local service=$1 output status
    if output=$(sudo env LC_ALL=C dinitctl enable "$service" 2>&1); then
        printf '%s\n' "$output"
    else
        status=$?
        printf '%s\n' "$output" >&2
        [[ "$output" == 'dinitctl: service already enabled.' ]] || return "$status"
        # An enabled service may be stopped; ensure it is running too.
        sudo dinitctl start "$service"
    fi
}

refresh_caches() {
    ui_run_quiet "Refreshing font cache" fc-cache -f
    ui_run_quiet "Building bat cache" bat cache --build
}

remove_installation_leftovers() {
    rm -f -- "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.bash_logout"
    rm -rf -- "$HOME/.npm"
}

main() {
    (( $# == 0 )) || die "Usage: $0"
    trap cleanup EXIT
    print_readonly_variables
    step "Checking prerequisites"
    check_prerequisites
    step "Configuring Artix and Arch package repositories"
    configure_package_repositories
    step "Installing repository packages"
    install_packages
    step "Building and installing patched Labwc"
    install_labwc
    step "Installing dotfiles"
    install_dotfiles
    step "Installing themes and icons"
    install_themes
    step "Installing system files"
    install_system_files
    step "Configuring the user account"
    configure_user
    step "Configuring sudo"
    configure_sudo
    step "Enabling dinit services"
    configure_services
    step "Installing AUR packages"
    install_aur_packages
    step "Refreshing caches"
    refresh_caches
    step "Removing default Bash files and npm leftovers"
    remove_installation_leftovers
    ui_summary "Setup complete. Reboot." \
        "Dotfiles: $DOTS" "Enabled services: ${DINIT_SERVICES[*]} and the selected network service"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
