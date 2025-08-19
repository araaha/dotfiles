#!/bin/bash

#set up yay
yay -Sy

#Install apps
yay --disable-download-timeout --removemake --needed --sudoloop -S - < ~/dotfiles/install/arch-apps.txt

# Remove orphaned packages using yay
if [[ $(yay -Qdtq) ]]; then
    yay -Qdtq | yay -Rns -
fi

