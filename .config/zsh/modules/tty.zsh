export MOD="$ZDOTDIR/modules"

if [[ -z $DISPLAY ]] && ! pgrep -x Xorg >/dev/null; then
    exec startx
fi

echo -en "\e]P0242424" #black
echo -en "\e]P1cc241d" #darkred
echo -en "\e]P29cd365" #darkgreen
echo -en "\e]P3d79921" #brown
echo -en "\e]P4458485" #darkblue
echo -en "\e]P5b16286" #darkmagenta
echo -en "\e]P6689d6a" #darkcyan
echo -en "\e]P7a89984" #lightgrey
echo -en "\e]P8928374" #darkgrey
echo -en "\e]P9fb4934" #red
echo -en "\e]PA9cd365" #green
echo -en "\e]PBfabd2f" #yellow
echo -en "\e]PC83a598" #blue
echo -en "\e]PDd3869b" #magenta
echo -en "\e]PE8ec07c" #cyan
echo -en "\e]PFebdbb2" #white
clear
