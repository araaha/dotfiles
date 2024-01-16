#!/bin/sh

case "$1" in
    pre)
        ;;
    post)
        DISPLAY=:0 xset r rate 150 50
        ;;
esac
