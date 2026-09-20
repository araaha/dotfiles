#!/usr/bin/env bash
set -euo pipefail

# Install a minimal Artix dinit system from the live ISO and boot its kernel
# directly through UEFI. This script erases the selected disk.

readonly USERNAME=araaha
readonly TIMEZONE=Canada/Eastern
readonly LOCALE=en_CA.UTF-8
readonly REPOSITORY=https://github.com/araaha/dotfiles
readonly TARGET=/mnt
readonly PACMAN_PARALLEL_DOWNLOADS=100
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
ESP=""
ROOT=""
HOME_PARTITION=""
MICROCODE_PACKAGE=""
MICROCODE_IMAGE=""
MOUNTED=false

die() {
    echo "error: $*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null || die "Required command missing: $1"
}

usage() {
    echo "Usage: sudo $0 /dev/DEVICE HOSTNAME"
    echo "Example: sudo $0 /dev/nvme0n1 atlas"
}

check_invocation() {
    (( EUID == 0 )) || die "Run this script as root from an Artix live ISO."
    [[ -n "$DISK" && -n "$HOSTNAME" ]] || { usage; exit 2; }
    [[ "$HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || die "Invalid hostname: $HOSTNAME"
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
    echo "Installing live-environment prerequisites..."
    pacman -Sy --needed --noconfirm "${PREREQUISITE_PACKAGES[@]}"
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

prompt_partition_sizes() {
    local input

    [[ -t 0 ]] || die "An interactive terminal is required to choose partition sizes."
    read -r -p "Boot partition size [$BOOT_SIZE]: " input
    BOOT_SIZE=$(normalize_partition_size "${input:-$BOOT_SIZE}")
    read -r -p "Root partition size [$ROOT_SIZE]: " input
    ROOT_SIZE=$(normalize_partition_size "${input:-$ROOT_SIZE}")
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
    read -r -p "Type 'ERASE $DISK' to continue: " confirmation
    [[ "$confirmation" == "ERASE $DISK" ]] || die "Confirmation did not match; nothing changed."
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
    basestrap "$TARGET" \
        base base-devel dinit elogind-dinit \
        linux linux-firmware "$MICROCODE_PACKAGE" \
        efibootmgr git iwd-dinit sudo zsh
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

    install -Dm0644 \
        "$TARGET/home/$USERNAME/dotfiles/etc/iwd/main.conf" \
        "$TARGET/etc/iwd/main.conf"

    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > "$TARGET/etc/sudoers.d/bootstrap"
    chmod 0440 "$TARGET/etc/sudoers.d/bootstrap"
    artix-chroot "$TARGET" runuser -u "$USERNAME" -- \
        bash -c 'git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm'
    rm -f "$TARGET/etc/sudoers.d/bootstrap"
}

enable_boot_services() {
    artix-chroot "$TARGET" dinitctl --offline enable iwd
}

create_efi_entry() {
    local root_uuid kernel_parameters

    root_uuid=$(blkid -s UUID -o value "$ROOT")
    [[ -n "$root_uuid" ]] || die "Could not read the root filesystem UUID."
    kernel_parameters="root=UUID=$root_uuid rw quiet splash amdgpu.dcdebugmask=0x10 amdgpu.gpu_recovery=1 atkbd.softrepeat=1 vt.cur_default=0x200011 vt.global_cursor_default=0 cpufreq.default_governor=powersave initrd=\\$MICROCODE_IMAGE initrd=\\initramfs-linux.img"

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
    check_invocation
    install_prerequisites
    check_prerequisites
    prompt_partition_sizes
    confirm_disk_erasure
    partition_disk
    mount_filesystems
    install_base_system
    configure_system
    install_dotfiles_and_yay
    enable_boot_services
    create_efi_entry

    echo
    echo "Artix is installed with a direct EFISTUB boot entry."
    echo "After rebooting, connect to the network and run:"
    echo "  /home/$USERNAME/dotfiles/setup.sh"
}

main "$@"
