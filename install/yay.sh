#!/bin/bash

#set up yay
yay -Y --gendb
yay -Sy
yay -Y --devel --save
#Install apps
yay --disable-download-timeout --removemake --needed --sudoloop -S - < ~/dotfiles/install/arch-apps.txt
