#!/bin/sh

case "$1" in
    pre)
        ;;
    post)
        xset r rate 150 50
        ;;
esac
