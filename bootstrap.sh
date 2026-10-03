#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install/install-ui.sh
source "$BOOTSTRAP_DIR/install/install-ui.sh"

# Install a minimal Artix dinit system from the live ISO and boot its kernel
# directly through UEFI. This script erases the selected disk.

readonly USERNAME=araaha
readonly TIMEZONE=Canada/Eastern
readonly LOCALE=en_CA.UTF-8
readonly REPOSITORY=https://github.com/araaha/dotfiles
readonly TARGET=/mnt
readonly NETWORK_CONFIG=/etc/dotfiles-network
readonly PACMAN_PARALLEL_DOWNLOADS=100
readonly -a KERNEL_PARAMETERS=(
    rw
    quiet
    splash
    vt.cur_default=0x200011
    vt.global_cursor_default=0
    cpufreq.default_governor=powersave
)
readonly -a PREREQUISITE_PACKAGES=(
    artools-base
    dosfstools
    e2fsprogs
    efibootmgr
    git
    gptfdisk
    parted
)

DISK=${1:-}
HOSTNAME=${2:-}
BOOT_SIZE=256M
ROOT_SIZE=50G
NETWORK_MODE=wifi
FIRMWARE_PACKAGES=()
ESP=""
ROOT=""
HOME_PARTITION=""
MICROCODE_PACKAGE=""
MICROCODE_IMAGE=""
MOUNTED=false

die() {
    ui_message error "$*" >&2
    exit 1
}

step() { ui_message step "$*"; }
success() { ui_message success "$*"; }

print_readonly_variables() {
    step "Read-only configuration"
    printf '  USERNAME=%s\n' "$USERNAME"
    printf '  TIMEZONE=%s\n' "$TIMEZONE"
    printf '  LOCALE=%s\n' "$LOCALE"
    printf '  REPOSITORY=%s\n' "$REPOSITORY"
    printf '  TARGET=%s\n' "$TARGET"
    printf '  NETWORK_CONFIG=%s\n' "$NETWORK_CONFIG"
    printf '  PACMAN_PARALLEL_DOWNLOADS=%s\n' "$PACMAN_PARALLEL_DOWNLOADS"
    printf '  KERNEL_PARAMETERS=%s\n' "${KERNEL_PARAMETERS[*]}"
    printf '  PREREQUISITE_PACKAGES=%s\n' "${PREREQUISITE_PACKAGES[*]}"
}

require_command() {
    command -v "$1" >/dev/null || die "Required command missing: $1"
}

usage() {
    echo "Usage: sudo $0 /dev/DEVICE [HOSTNAME]"
    echo "Example: sudo $0 /dev/nvme0n1 atlas"
}

check_invocation() {
    (( EUID == 0 )) || die "Run this script as root from an Artix live ISO."
    [[ -n "$DISK" ]] || { usage; exit 2; }
    [[ -z "$HOSTNAME" || "$HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || die "Invalid hostname: $HOSTNAME"
    [[ -d /sys/firmware/efi/efivars ]] || die "The ISO was not booted in UEFI mode."
    [[ -r /etc/os-release ]] || die "Could not identify the live environment."

    # shellcheck source=/dev/null
    source /etc/os-release
    [[ "${ID:-}" == artix ]] || die "Run this script from an Artix live ISO."
    command -v pacman >/dev/null || die "pacman is unavailable."
    command -v grep >/dev/null || die "grep is unavailable."
    command -v sed >/dev/null || die "sed is unavailable."
}

enable_pacman_parallel_downloads() {
    local config=$1

    [[ -f "$config" ]] || die "Missing pacman configuration: $config"
    if grep -Eq '^[#[:space:]]*ParallelDownloads[[:space:]]*=' "$config"; then
        sed -Ei \
            "s/^[#[:space:]]*ParallelDownloads[[:space:]]*=.*$/ParallelDownloads = $PACMAN_PARALLEL_DOWNLOADS/" \
            "$config"
    else
        sed -i "/^\[options\]$/a ParallelDownloads = $PACMAN_PARALLEL_DOWNLOADS" "$config"
    fi
}

install_prerequisites() {
    enable_pacman_parallel_downloads /etc/pacman.conf
    pacman -Sy --needed --noconfirm "${PREREQUISITE_PACKAGES[@]}"
    # Gum is optional; a live ISO may not have it in its configured repositories.
    if [[ ${DOTFILES_PLAIN:-0} != 1 ]] && ! command -v gum >/dev/null; then
        if pacman -Si gum >/dev/null 2>&1; then
            pacman -S --needed --noconfirm gum || \
                printf 'Gum could not be installed; using text prompts.\n' >&2
        fi
    fi
}

cleanup() {
    if [[ "$MOUNTED" == true ]]; then
        rm -f "$TARGET/etc/sudoers.d/bootstrap"
        umount -R "$TARGET" 2>/dev/null || true
    fi
}

check_prerequisites() {
    local command

    [[ -b "$DISK" ]] || die "Not a block device: $DISK"
    [[ "$(lsblk -dnro TYPE "$DISK")" == disk ]] || die "Select a whole disk, not a partition."
    [[ "$(lsblk -dnro RO "$DISK")" == 0 ]] || die "The selected disk is read-only."
    if lsblk -nrpo MOUNTPOINT "$DISK" | awk 'NF { found = 1 } END { exit !found }'; then
        die "The selected disk or one of its partitions is mounted."
    fi
    mountpoint -q "$TARGET" && die "$TARGET is already mounted."

    for command in artix-chroot basestrap blkid efibootmgr fstabgen git \
        lsblk mkfs.ext4 mkfs.fat mount mountpoint partprobe sgdisk udevadm umount; do
        require_command "$command"
    done

    case "$(awk -F ': ' '/vendor_id/ { print $2; exit }' /proc/cpuinfo)" in
        AuthenticAMD)
            MICROCODE_PACKAGE=amd-ucode
            MICROCODE_IMAGE=amd-ucode.img
            ;;
        GenuineIntel)
            MICROCODE_PACKAGE=intel-ucode
            MICROCODE_IMAGE=intel-ucode.img
            ;;
        *) die "Only AMD and Intel x86_64 CPUs are supported." ;;
    esac
}

normalize_partition_size() {
    local value=${1^^}

    value=${value%IB}
    value=${value%B}
    [[ "$value" =~ ^[1-9][0-9]*[MGT]$ ]] || \
        die "Invalid size '$1'; use a value such as 256M, 50G, or 1T."
    printf '%s\n' "$value"
}

prompt_hostname() {
    if [[ -z "$HOSTNAME" ]]; then
        HOSTNAME=$(ui_input 'Hostname') || die "Hostname selection cancelled."
    fi
    [[ "$HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || die "Invalid hostname: $HOSTNAME"
}

prompt_partition_sizes() {
    local input
    input=$(ui_input 'Boot partition size' "$BOOT_SIZE") || die "Partition selection cancelled."
    BOOT_SIZE=$(normalize_partition_size "$input")
    input=$(ui_input 'Root partition size' "$ROOT_SIZE") || die "Partition selection cancelled."
    ROOT_SIZE=$(normalize_partition_size "$input")
}

prompt_network_mode() {
    NETWORK_MODE=$(ui_choose 'Network connection' wifi ethernet) || die "Network selection cancelled."
    case "$NETWORK_MODE" in
        wifi|ethernet) ;;
        *) die "Invalid network selection: $NETWORK_MODE" ;;
    esac
}

prompt_firmware_packages() {
    local packages selected package defaults="" known existing duplicate
    local -a available
    packages=$(pacman -Slq) || die "Could not list available firmware packages."
    mapfile -t available < <(printf '%s\n' "$packages" |
        LC_ALL=C sort -u | awk '/^linux-firmware(-[a-z0-9-]+)?$/')
    (( ${#available[@]} > 0 )) || die "No linux-firmware packages found in configured repositories."

    # Preserve the previous machine's defaults when those packages are available.
    for package in linux-firmware-amdgpu linux-firmware-mediatek; do
        for known in "${available[@]}"; do
            [[ "$known" == "$package" ]] && defaults+="${defaults:+,}$package"
        done
    done
    if [[ -z "$defaults" ]]; then
        for known in "${available[@]}"; do
            [[ "$known" == linux-firmware ]] && defaults=linux-firmware
        done
    fi
    printf 'Select firmware for your GPU, network, and other devices.\n' >&2
    printf 'linux-firmware is the broad meta-package; individual packages keep installation smaller.\n' >&2
    selected=$(ui_choose_many 'Firmware packages (Tab to select, Enter to accept)' \
        "$defaults" "${available[@]}") || die "Firmware selection cancelled or invalid."
    FIRMWARE_PACKAGES=()
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        known=false
        for existing in "${available[@]}"; do
            [[ "$existing" == "$package" ]] && known=true
        done
        [[ "$known" == true ]] || die "Unavailable firmware package: $package"
        duplicate=false
        for existing in "${FIRMWARE_PACKAGES[@]}"; do
            [[ "$existing" == "$package" ]] && duplicate=true
        done
        [[ "$duplicate" == true ]] || FIRMWARE_PACKAGES+=("$package")
    done <<< "$selected"
    (( ${#FIRMWARE_PACKAGES[@]} > 0 )) || die "Select at least one firmware package."
}

network_package() {
    case "$NETWORK_MODE" in
        wifi) printf '%s\n' iwd-dinit ;;
        ethernet) printf '%s\n' dhcpcd-dinit ;;
    esac
}

network_service() {
    case "$NETWORK_MODE" in
        wifi) printf '%s\n' iwd ;;
        ethernet) printf '%s\n' dhcpcd ;;
    esac
}

confirm_disk_erasure() {
    local confirmation

    echo
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL "$DISK"
    echo
    echo "This will permanently erase $DISK and create:"
    echo "  partition 1: $BOOT_SIZE FAT32 EFI System Partition mounted at /boot"
    echo "  partition 2: $ROOT_SIZE ext4 root filesystem"
    echo "  partition 3: remaining space as an ext4 /home filesystem"
    echo "  network: $NETWORK_MODE"
    echo "  firmware: ${FIRMWARE_PACKAGES[*]}"
    confirmation=$(ui_input "Type 'ERASE $DISK' to continue") || die "Disk erasure cancelled."
    [[ "$confirmation" == "ERASE $DISK" ]] || die "Confirmation did not match; disk was not modified."
}

partition_disk() {
    sgdisk --zap-all "$DISK"
    sgdisk \
        --new=1:0:+"$BOOT_SIZE" --typecode=1:ef00 --change-name=1:EFI \
        --new=2:0:+"$ROOT_SIZE" --typecode=2:8300 --change-name=2:Artix \
        --new=3:0:0 --typecode=3:8300 --change-name=3:Home \
        "$DISK"
    partprobe "$DISK"
    udevadm settle

    ESP=$(lsblk -lnpo NAME,PARTN "$DISK" | awk '$2 == 1 { print $1; exit }')
    ROOT=$(lsblk -lnpo NAME,PARTN "$DISK" | awk '$2 == 2 { print $1; exit }')
    HOME_PARTITION=$(lsblk -lnpo NAME,PARTN "$DISK" | awk '$2 == 3 { print $1; exit }')
    [[ -b "$ESP" && -b "$ROOT" && -b "$HOME_PARTITION" ]] || \
        die "Could not locate the new partitions."

    mkfs.fat -F 32 -n EFI "$ESP"
    mkfs.ext4 -F -L Artix "$ROOT"
    mkfs.ext4 -F -L Home "$HOME_PARTITION"
}

mount_filesystems() {
    mount "$ROOT" "$TARGET"
    MOUNTED=true
    mkdir -p "$TARGET/boot"
    mount "$ESP" "$TARGET/boot"
    mkdir -p "$TARGET/home"
    mount "$HOME_PARTITION" "$TARGET/home"
}

install_base_system() {
    local selected_network_package

    selected_network_package=$(network_package)
    basestrap "$TARGET" \
        base base-devel dinit elogind-dinit \
        linux "${FIRMWARE_PACKAGES[@]}" "$MICROCODE_PACKAGE" \
        efibootmgr git "$selected_network_package" sudo zsh
    enable_pacman_parallel_downloads "$TARGET/etc/pacman.conf"
    fstabgen -U "$TARGET" > "$TARGET/etc/fstab"
}

configure_system() {
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" "$TARGET/etc/localtime"
    artix-chroot "$TARGET" hwclock --systohc

    sed -i "s/^#${LOCALE} UTF-8/${LOCALE} UTF-8/" "$TARGET/etc/locale.gen"
    artix-chroot "$TARGET" locale-gen
    echo "LANG=$LOCALE" > "$TARGET/etc/locale.conf"
    echo "$HOSTNAME" > "$TARGET/etc/hostname"
    echo "$NETWORK_MODE" > "$TARGET$NETWORK_CONFIG"
    cat > "$TARGET/etc/hosts" <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

    artix-chroot "$TARGET" useradd -m -G wheel -s /bin/zsh "$USERNAME"
    echo "Set the root password:"
    artix-chroot "$TARGET" passwd
    echo "Set the password for $USERNAME:"
    artix-chroot "$TARGET" passwd "$USERNAME"

    install -d -m 0750 "$TARGET/etc/sudoers.d"
    echo '%wheel ALL=(ALL:ALL) ALL' > "$TARGET/etc/sudoers.d/wheel"
    chmod 0440 "$TARGET/etc/sudoers.d/wheel"
    artix-chroot "$TARGET" visudo -cf /etc/sudoers.d/wheel
}

install_dotfiles_and_yay() {
    artix-chroot "$TARGET" runuser -u "$USERNAME" -- \
        git clone "$REPOSITORY" "/home/$USERNAME/dotfiles"

    if [[ "$NETWORK_MODE" == wifi ]]; then
        install -Dm0644 \
            "$TARGET/home/$USERNAME/dotfiles/etc/iwd/main.conf" \
            "$TARGET/etc/iwd/main.conf"
    fi

    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > "$TARGET/etc/sudoers.d/bootstrap"
    chmod 0440 "$TARGET/etc/sudoers.d/bootstrap"
    artix-chroot "$TARGET" runuser -u "$USERNAME" -- \
        bash -c 'git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm'
    rm -f "$TARGET/etc/sudoers.d/bootstrap"
}

enable_boot_services() {
    local output status
    if output=$(artix-chroot "$TARGET" env LC_ALL=C dinitctl --offline enable "$(network_service)" 2>&1); then
        printf '%s\n' "$output"
    else
        status=$?
        printf '%s\n' "$output" >&2
        [[ "$output" == 'dinitctl: service already enabled.' ]] || return "$status"
    fi
}

install_resolver() {
    # Run after all chroot calls, which may temporarily replace resolv.conf.
    cp --remove-destination -- \
        "$TARGET/home/$USERNAME/dotfiles/etc/resolv.conf" \
        "$TARGET/etc/resolv.conf"
    chmod 0644 "$TARGET/etc/resolv.conf"
}

create_efi_entry() {
    local root_uuid kernel_parameters

    root_uuid=$(blkid -s UUID -o value "$ROOT")
    [[ -n "$root_uuid" ]] || die "Could not read the root filesystem UUID."
    kernel_parameters="root=UUID=$root_uuid ${KERNEL_PARAMETERS[*]} initrd=\\$MICROCODE_IMAGE initrd=\\initramfs-linux.img"

    efibootmgr \
        --create \
        --disk "$DISK" \
        --part 1 \
        --label "Artix Linux" \
        --loader '\vmlinuz-linux' \
        --unicode "$kernel_parameters"
    efibootmgr --verbose
}

main() {
    trap cleanup EXIT
    print_readonly_variables
    step "Checking invocation and live environment"
    check_invocation
    step "Installing live-environment prerequisites"
    install_prerequisites
    step "Checking installation prerequisites"
    check_prerequisites
    step "Selecting the hostname"
    prompt_hostname
    step "Selecting partition sizes"
    prompt_partition_sizes
    step "Selecting the network connection"
    prompt_network_mode
    step "Selecting firmware packages"
    prompt_firmware_packages
    step "Confirming target disk erasure"
    confirm_disk_erasure
    step "Partitioning and formatting $DISK"
    partition_disk
    step "Mounting target filesystems"
    mount_filesystems
    step "Installing the Artix base system"
    install_base_system
    step "Configuring the installed system"
    configure_system
    step "Installing dotfiles and yay"
    install_dotfiles_and_yay
    step "Enabling first-boot dinit services"
    enable_boot_services
    step "Creating the EFISTUB firmware entry"
    create_efi_entry
    step "Installing DNS configuration for first boot"
    install_resolver

    echo
    ui_summary "Artix is installed with a direct EFISTUB boot entry." \
        "Hostname: $HOSTNAME" "Network: $NETWORK_MODE" \
        "Firmware: ${FIRMWARE_PACKAGES[*]}"
    echo "After rebooting, connect to the network and run:"
    echo "  /home/$USERNAME/dotfiles/setup.sh"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
