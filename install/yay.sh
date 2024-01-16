#!/bin/bash

set -e

#Install apps
yay --removemake --needed --sudoloop --noconfirm -S - < ~/dotfiles/install/arch-apps.txt
