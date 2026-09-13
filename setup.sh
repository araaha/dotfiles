#!/usr/bin/env bash
set -euo pipefail

DOTS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
staging=""

cleanup() {
    if [[ -n "$staging" ]]; then
        rm -rf -- "$staging"
    fi
}

check_prerequisites() {
    local command manifest
    if (( EUID == 0 )); then
        echo "Run as your ordinary user, not root." >&2
        exit 1
    fi
    for command in yay sudo git unzip; do
        command -v "$command" >/dev/null || { echo "Required command missing: $command" >&2; exit 1; }
    done

    # Check the supported platform before changing anything.
    # shellcheck source=/dev/null
    source /etc/os-release
    case "$ID" in arch|artix) ;; *) echo "Only Arch and Artix are supported." >&2; exit 1 ;; esac

    if [[ "$ID" == artix ]]; then
        command -v dinitctl >/dev/null || { echo "Artix setup requires dinit." >&2; exit 1; }
    fi

    for manifest in arch-apps.txt aur-apps.txt; do
        test -s "$DOTS/install/$manifest" || { echo "Missing manifest: $manifest" >&2; exit 1; }
    done
}

install_packages() {
    local manifest
    yay -Syu
    for manifest in arch-apps.txt aur-apps.txt; do
        yay --needed -S - < "$DOTS/install/$manifest"
    done
}

link_item() {
    local source=$1 target=$2
    if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
        return
    fi
    rm -rf -- "$target"
    ln -s -- "$source" "$target"
}

link_dotfiles() {
    local directory source
    # Replace directory symlinks before installing children, so writes stay outside the repo.
    for directory in "$HOME/.config" "$HOME/.local" "$HOME/.local/share"; do
        if [[ -L "$directory" || ( -e "$directory" && ! -d "$directory" ) ]]; then
            rm -rf -- "$directory"
        fi
        mkdir -p "$directory"
    done
    mkdir -p "$HOME/Downloads" "$HOME/Books" "$HOME/Screenshots"
    link_item "$DOTS/scripts" "$HOME/scripts"
    shopt -s dotglob nullglob
    for source in "$DOTS/.config/"*; do
        link_item "$source" "$HOME/.config/${source##*/}"
    done
    for source in "$DOTS/.local/share/"*; do
        case "${source##*/}" in themes|icons) continue ;; esac
        link_item "$source" "$HOME/.local/share/${source##*/}"
    done
    link_item "$DOTS/.local/bin" "$HOME/.local/bin"
}

install_themes_and_icons() {
    local archive category destination source target
    # Stage downloaded assets before replacing any existing theme/icon directories.
    staging=$(mktemp -d)
    for archive in "$DOTS/.local/share/themes/"*.zip; do
        unzip -q -o "$archive" -d "$staging/themes"
    done
    git clone --depth 1 https://github.com/SylEleuth/gruvbox-plus-icon-pack "$staging/icons"
    for category in themes icons; do
        destination="$HOME/.local/share/$category"
        if [[ -L "$destination" || ( -e "$destination" && ! -d "$destination" ) ]]; then
            rm -rf -- "$destination"
        fi
        mkdir -p "$destination"
    done
    for source in "$staging/themes/"* "$staging/icons/Gruvbox-Plus-Dark"; do
        [[ -e "$source" ]] || { echo "Missing staged asset: $source" >&2; exit 1; }
        category=themes
        [[ "$source" == "$staging/icons/"* ]] && category=icons
        target="$HOME/.local/share/$category/${source##*/}"
        rm -rf -- "$target"
        cp -a -- "$source" "$target"
    done
}

install_system_files() {
    local directory
    for directory in etc usr; do
        sudo cp -r --remove-destination -- "$DOTS/$directory/." "/$directory/"
    done
}

configure_user() {
    local username shell
    username=$(id -un)
    shell=$(command -v zsh)
    grep -Fxq "$shell" /etc/shells || { echo "zsh is not listed in /etc/shells" >&2; exit 1; }
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

configure_grub() {
    if [[ ! -f /etc/default/grub || ! -f /boot/grub/grub.cfg ]]; then
        echo "GRUB installation not found; skipping GRUB configuration."
        return
    fi
    sudo sed -i '/^[[:space:]]*GRUB_CMDLINE_LINUX=/d' /etc/default/grub
    echo 'GRUB_CMDLINE_LINUX="amdgpu.dcdebugmask=0x10 amdgpu.gpu_recovery=1 quiet splash atkbd.softrepeat=1 vt.cur_default=0x200011 vt.global_cursor_default=0 cpufreq.default_governor=powersave"' | sudo tee -a /etc/default/grub > /dev/null
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

install_crontab() {
    # Replace the current user crontab with these jobs.
    crontab - <<'JOBS'
*/10 * * * * "$HOME/scripts/notify-event.sh"
*/5 * * * * "$HOME/scripts/bluetooth-battery.sh"
*/5 * * * * "$HOME/scripts/battery.sh"
JOBS
}

configure_services() {
    local service
    if [[ "$ID" == arch ]]; then
        sudo systemctl enable --now cronie cups bluetooth iwd
    else
        for service in cronie cupsd bluetoothd iwd; do
            sudo dinitctl enable "$service"
        done
    fi
}

refresh_caches() {
    fc-cache -f
    bat cache --build
}

main() {
    trap cleanup EXIT
    check_prerequisites
    install_packages
    link_dotfiles
    install_themes_and_icons
    install_system_files
    configure_user
    configure_sudo
    configure_grub
    install_crontab
    configure_services
    refresh_caches
    echo "Setup complete. Log out and back in for your shell and groups to take effect."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
