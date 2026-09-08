#!/bin/sh

device="/dev/$1"
action="$2"
mount_root="/media"

case "$action" in
    add)
        if findmnt -rn -S "$device" >/dev/null 2>&1; then
            exit 0
        fi

        filesystem=$(blkid -s TYPE -o value "$device")
        [ -z "$filesystem" ] && exit 0

        label=$(blkid -s LABEL -o value "$device")
        uuid=$(blkid -s UUID -o value "$device")

        # Prefer the label, then UUID, then device name.
        name=${label:-${uuid:-$1}}

        # Replace characters that are awkward in directory names.
        name=$(printf '%s' "$name" | tr ' /' '__')
        mountpoint="$mount_root/$name"

        mkdir -p "$mountpoint"

        case "$filesystem" in
            vfat|exfat|ntfs|ntfs3)
                mount -o rw,nosuid,nodev,uid=1000,gid=1000 \
                    "$device" "$mountpoint"
                ;;
            *)
                mount -o rw,nosuid,nodev \
                    "$device" "$mountpoint"
                ;;
        esac
        ;;

    remove)
        # Find where this device was mounted.
        mountpoint=$(findmnt -rn -S "$device" -o TARGET)

        if [ -n "$mountpoint" ]; then
            umount "$mountpoint"
            rmdir "$mountpoint" 2>/dev/null
        fi
        ;;
esac
