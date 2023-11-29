#!/bin/bash
shopt -s extglob

sudo rm -rf -I ~/!(scripts|.config|Downloads|Books|Screenshots|dotfiles|dotfiles-private|.local)

fc-cache -fv

yay -Qdtq | yay -Rns -

bat cache --build

#/etc/
echo "Defaults !tty_tickets" | sudo tee -a /etc/sudoers
echo "Defaults timestamp_timeout=30" | sudo tee -a /etc/sudoers
echo "Defaults passwd_tries=10" | sudo tee -a /etc/sudoers
echo "Defaults passwd_timeout=0" | sudo tee -a /etc/sudoers

crontab ~/dotfiles/misc/crontab/crontabs
sudo crontab ~/dotfiles/misc/crontab/sudo-crontabs 

chsh araaha --shell=/bin/zsh

#grub
sudo sed -i 's/GRUB_CMDLINE_LINUX="[^"]*"/GRUB_CMDLINE_LINUX="rootfstype=ext4 quiet splash atkbd.softrepeat=1 vt.cur_default=0x200011 vt.color=3 vt.global_cursor_default=0 cpufreq.scaling_min_freq=2500000 cpufreq.default_governor=powersave amd_pstate=guided"/' /etc/default/grub

sudo cp -v ~/.local/share/Wallpapers/Pacman.png /boot/grub/

sudo sed -i 's/GRUB_BACKGROUND="[^"]*"/GRUB_BACKGROUND="/boot/grub/Pacman.png"/' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

sudo mkinitcpio -P

