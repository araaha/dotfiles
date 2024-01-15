#!/bin/bash
set -e

shopt -s extglob

dots="$(pwd)"

./"$dots/install/bootstrap.sh"
./"$dots/install/yay.sh"
./"$dots/install/after.sh"
