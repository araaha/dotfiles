sudo kbdrate -r 50 -d 150
sudo loadkeys $HOME/dotfiles/etc/supplemental.kmap
tput cnorm
setfont ter-728b

export FZF_DEFAULT_OPTS="--no-scrollbar --border=sharp --no-separator  --tiebreak=length,end,chunk --padding 0% --margin 0% --multi --reverse --preview-window=border-none --height=50% --color=bg+:-1,spinner:#fb4934,hl:#928374:bold,fg:#8abeb7,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:regular:reverse:#83a598,prompt:#9cd365,hl+:reverse:reverse:#83a598,gutter:-1,query:regular,border:#87afaf --bind home:first --bind end:last --bind ctrl-p:up --bind ctrl-d:half-page-down --bind ctrl-u:half-page-up --bind 'ctrl-l:become(lf {})' --bind 'ctrl-y:offset-up' --bind 'ctrl-e:offset-down' --bind 'ctrl-a:select-all'"
export FZF_TMUX=0

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
