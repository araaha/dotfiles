#!/bin/bash
shopt -s extglob

echo "Make sure you run this script with bash instead of ./"
echo "Sleeping for 3 seconds"
sleep 3

./misc/installer-scripts/copy-symlink.sh && ./misc/installer-scripts/install.sh && ./misc/installer-scripts/cleanup.sh && ./misc/installer-scripts/enable-services.sh
