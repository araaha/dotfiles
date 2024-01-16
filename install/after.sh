#!/bin/bash

set -e
shopt -s extglob

# Remove unnecessary files
sudo rm -rf -I ~/!(scripts|.config|Downloads|Books|Screenshots|dotfiles|dotfiles-private|.local)

# Update font cache and build bat cache
fc-cache -fv
bat cache --build

# Remove orphaned packages using yay
if [[ $(yay -Qdtq) ]]; then
    yay -Qdtq | yay -Rns -
fi

# Configure sudo settings in /etc/sudoers
echo "Defaults !tty_tickets" | sudo tee -a /etc/sudoers
echo "Defaults timestamp_timeout=30" | sudo tee -a /etc/sudoers
echo "Defaults passwd_tries=10" | sudo tee -a /etc/sudoers
echo "Defaults passwd_timeout=0" | sudo tee -a /etc/sudoers

# Set up crontab
crontab ~/dotfiles/misc/crontab/crontabs
sudo crontab ~/dotfiles/misc/crontab/sudo-crontabs 

# Change default shell to zsh
chsh -s "$(which zsh)"

# Configure GRUB settings
sudo sed -i 's/GRUB_CMDLINE_LINUX="[^"]*"/GRUB_CMDLINE_LINUX="rootfstype=ext4 quiet splash atkbd.softrepeat=1 vt.cur_default=0x200011 vt.color=3 vt.global_cursor_default=0 cpufreq.scaling_min_freq=2500000 cpufreq.default_governor=powersave amd_pstate=guided"/' /etc/default/grub
sudo cp -v ~/.local/share/Wallpapers/Pacman.png /boot/grub/
sudo sed -i 's/GRUB_BACKGROUND="[^"]*"/GRUB_BACKGROUND="/boot/grub/Pacman.png"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -P

# Enable and start system services
systemctl enable --now cronie
systemctl enable --now cups.socket
systemctl enable --now udisks2.service
systemctl enable --now ly
systemctl enable --now --user greenclip
systemctl enable --now --user redshift

#set keyboard repeat
sudo ln -s ~/dotfiles/scripts/xset-keyboard-repeat.sh /usr/lib/systemd/system-sleep/

#install compiled/zipped apps
yay -S cyme-bin \
djvu2pdf \
dragon-drop \
edir \
epy-ereader-git \
gdu-bin \
pulseaudio-ctl \
rofi-greenclip \
shellcheck-bin \
sioyek \
tdrop \
ticker \
ttf-arphic-uming \
ttf-gowun-batang \
webtorrent-cli \
xdg-desktop-portal-termfilechooser-git \
ttf-ms-fonts \
ttf-weather-icons
