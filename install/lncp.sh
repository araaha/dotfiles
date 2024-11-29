#!/bin/bash

set -e

DOTS="$HOME/dotfiles"

sudo rm -rf "$HOME/.config"
sudo rm -rf "$HOME/.zshrc"
sudo rm -rf "$HOME/.bashrc"
sudo rm -rf "$HOME/.local"

mkdir -p "$HOME/.config/"
mkdir -p "$HOME/Downloads/"
mkdir -p "$HOME/Books/"
mkdir -p "$HOME/Screenshots/"
mkdir -p "$HOME/.local/share/themes"
mkdir -p "$HOME/.local/share/icons"

ln -sr "$DOTS/scripts/" "$HOME/"
ln -srf "$DOTS/.config"/* "$HOME/.config/"
find "$DOTS/.local/share" -mindepth 1 -maxdepth 1 ! -name "themes" -exec ln -sr {} "$HOME/.local/share" \;

#themes/icons
sudo pacman -S unzip

unzip "$DOTS/.local/share/themes/Gruvbox-Material-Dark-HIDPI.zip" -d "$HOME/.local/share/themes/Gruvbox-Material-Dark-HIDPI.zip"
unzip "$DOTS/.local/share/themes/gruvbox-material-dark-blocks.zip" -d "$HOME/.local/share/themes/gruvbox-material-dark-blocks.zip"

git clone "https://github.com/SylEleuth/gruvbox-plus-icon-pack" ~/.local/share/icons

find ~/.local/share/icons/ -mindepth 1 -maxdepth 1 ! -name "Gruvbox-Plus-Dark" -exec rm -rf {} \;

#binaries
mkdir -p ~/.local/bin
find "$HOME/dotfiles/misc/binaries" -type f -executable -print0 | xargs -0 -I % cp % ~/.local/bin

#/etc/
sudo cp -rv "$DOTS/etc"/* /etc/
