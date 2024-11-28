#!/bin/bash

set -e

shopt -s extglob

dots="$HOME/dotfiles"

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

ln -s "$dots/scripts/" "$HOME/"
ln -srf "$dots/.config"/* "$HOME/.config/"
ln -s "$dots/.local/share/"!(themes|icons)  "$HOME/.local/share/"

#themes/icons
sudo pacman -S unzip

cp -v "$dots/.local/share/themes/Gruvbox-Material-Dark-HIDPI.zip" ~/.local/share/themes
cp -v "$dots/.local/share/themes/gruvbox-material-dark-blocks.zip" ~/.local/share/themes

unzip "$HOME/.local/share/themes/Gruvbox-Material-Dark-HIDPI.zip"
unzip "$HOME/.local/share/themes/gruvbox-material-dark-blocks.zip"

git clone "https://github.com/SylEleuth/gruvbox-plus-icon-pack" ~/.local/share/icons

rm -rf ~/.local/share/icons/!(Gruvbox-Plus-Dark)

#binaries
mkdir -p ~/.local/bin
sudo cp -frv "$dots/misc/binaries/"!(nsxiv|st-0.8.5) ~/.local/bin
sudo cp -fv "$dots/misc/binaries/nsxiv/nsxiv" ~/.local/bin
sudo cp -fv "$dots/misc/binaries/st-0.8.5/st" ~/.local/bin

#/etc/
sudo cp -v "$dots/etc"/* /etc/
