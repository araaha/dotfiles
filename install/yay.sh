#!/bin/bash

set -e

RED='\033[1;33m'
NC='\033[0m' # No Color

#Install apps
yay --removemake --needed --sudoloop --noconfirm -S - < ~/dotfiles/misc/installer-scripts/arch-apps.txt

echo -e "${RED}Next is the compiled/zipped stuff${NC}"

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
xdg-desktop-portal-termfilechooser-git