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
ln -srf "$dots/.config/*" "$HOME/.config/"
ln -s "$dots/.local/share/"!(themes|icons)  "$HOME/.local/share/"

cp -v "$HOME/dotfiles/.local/share/.gnupg/gpg-agent.conf" "$HOME/.local/share/.gnupg"


#themes/icons
sudo pacman -S unzip

cp -v "$dots/.local/share/themes/Gruvbox-Material-Dark-HIDPI.zip" ~/.local/share/themes
cp -v "$dots/.local/share/themes/gruvbox-material-dark-blocks.zip" ~/.local/share/themes

unzip "$dots/.local/share/themes/Gruvbox-Material-Dark-HIDPI.zip"
unzip "$dots/.local/share/themes/gruvbox-material-dark-blocks.zip"

git clone "https://github.com/SylEleuth/gruvbox-plus-icon-pack" ~/.local/share/icons

rm -rf ~/.local/share/icons/!(Gruvbox-Plus-Dark)

#binaries
sudo cp -rv "$dots/misc/binaries/"!(nsxiv|st-0.8.5) /usr/bin/
sudo cp -v "$dots/misc/binaries/nsxiv/nsxiv" /usr/bin/
sudo cp -v "$dots/misc/binaries/st-0.8.5/st" /usr/bin/

#/etc/
sudo cp -v "$dots/etc/*" /etc/
