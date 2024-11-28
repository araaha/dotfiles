#!/bin/bash

shopt -s extglob

echo "run shopt -s extglob first"
sleep 3

bash -c /home/araaha/dotfiles/install/lncp.sh
bash -c /home/araaha/dotfiles/install/yay.sh
bash -c /home/araaha/dotfiles/install/after.sh
