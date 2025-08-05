#!/bin/bash

set -e

# Remove unnecessary files
find "$HOME" -maxdepth 1 -mindepth 1 ! \( -name "scripts" -o -name ".config" -o -name "Downloads" -o -name "Books" \
    -o -name "Screenshots" -o -name "dotfiles" -o -name "dotfiles-private" -o -name ".local" \) -exec rm -rf {} \;

# Update font cache and build bat cache
fc-cache -fv
bat cache --build

# Configure sudo settings in /etc/sudoers
echo "Defaults !tty_tickets" | sudo tee -a /etc/sudoers
echo "Defaults timestamp_timeout=30" | sudo tee -a /etc/sudoers
echo "Defaults passwd_tries=10" | sudo tee -a /etc/sudoers
echo "Defaults passwd_timeout=0" | sudo tee -a /etc/sudoers

# Set up crontab
crontab ~/dotfiles/install/crontabs/crontab
sudo crontab ~/dotfiles/install/crontabs/sudo-crontab

# Change default shell to zsh
chsh -s "$(which zsh)"

# Configure GRUB settings
sudo sed -i 's/GRUB_CMDLINE_LINUX="[^"]*"/GRUB_CMDLINE_LINUX="rootfstype=ext4 quiet splash atkbd.softrepeat=1 vt.cur_default=0x200011 vt.color=3 vt.global_cursor_default=0 cpufreq.default_governor=powersave"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -P

# Enable and start system services
systemctl enable --now cronie
systemctl enable --now cups
systemctl enable --now ly
systemctl enable --now bluetooth
systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved

#install compiled/zipped apps
yay -S cyme-bin \
djvu2pdf \
chawan \
dragon-drop \
edir \
light \
gdu-bin \
pulseaudio-ctl \
rofi-greenclip \
shellcheck-bin \
sioyek \
tdrop \
ticker \
ttf-arphic-uming \
webtorrent-cli \
xdg-desktop-portal-termfilechooser-hunkyburrito-git \
ungoogled-chromium-xdg-bin \
ttf-ms-fonts \
ttf-weather-icons \
uair \
rofi-git \
rofi-calc-git \
rofi-pass \
localsend-bin \
codelldb-bin \
megacmd \
warpd
