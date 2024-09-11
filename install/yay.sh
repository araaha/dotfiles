#!/bin/bash

#set up yay
yay -Y --gendb
yay -Sy
yay -Y --devel --save
#Install apps
yay --removemake --needed --sudoloop -S - < ~/dotfiles/install/arch-apps.txt
