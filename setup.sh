#!/bin/bash
shopt -s extglob

echo "run shopt -s extglob first, followed by changing your dir to ~/dotfiles"
sleep 3

./install/bootstrap.sh
./install/yay.sh
./install/yay.sh
./install/after.sh
