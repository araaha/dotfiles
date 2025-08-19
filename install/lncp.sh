#!/bin/bash

set -e

DOTS="$HOME/dotfiles"

rm -rf "$HOME/.config"
rm -rf "$HOME/.zshrc"
rm -rf "$HOME/.bashrc"
rm -rf "$HOME/.local"

mkdir -p "$HOME/.config/"
mkdir -p "$HOME/Downloads/"
mkdir -p "$HOME/Books/"
mkdir -p "$HOME/Screenshots/"
mkdir -p "$HOME/.local/share/themes"
mkdir -p "$HOME/.local/share/icons"

ln -srv "$DOTS/scripts/" "$HOME/"
ln -srfv "$DOTS/.config"/* "$HOME/.config/"
find "$DOTS/.local/share" -mindepth 1 -maxdepth 1 ! -name "themes" -exec ln -srv {} "$HOME/.local/share" \;

#themes/icons
yay -S unzip

unzip "$DOTS/.local/share/themes/Gruvbox-Material-Dark-HIDPI.zip" -d "$HOME/.local/share/themes/"
unzip "$DOTS/.local/share/themes/gruvbox-material-dark-blocks.zip" -d "$HOME/.local/share/themes/"

git clone "https://github.com/SylEleuth/gruvbox-plus-icon-pack" ~/.local/share/icons

find ~/.local/share/icons/ -mindepth 1 -maxdepth 1 ! -name "Gruvbox-Plus-Dark" -exec rm -rf {} \;

#binaries
mkdir -p ~/.local/bin
find "$HOME/dotfiles/.local/bin" -type f -executable -print0 | xargs -0 -I % ln -srv % ~/.local/bin

#/etc/
sudo cp -rv "$DOTS/etc"/* /etc/
