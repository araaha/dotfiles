#!/bin/bash

case "$1" in
    pre)
        DISPLAY=:0 xset r rate 150 50
        ;;
    post)
        DISPLAY=:0 xset r rate 150 50
        ;;
esac
