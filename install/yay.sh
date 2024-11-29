#!/bin/bash

#set up yay
yay -Sy
yay -Y --gendb
yay -Y --devel --save
#Install apps
yay --disable-download-timeout --removemake --needed --sudoloop -S - < ~/dotfiles/install/arch-apps.txt
