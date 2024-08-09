alias \#='sudo'
alias \$=''
alias alu="apt list --upgradable"
alias bctl="bluetoothctl"
alias cat="bat -pp"
alias catt="/usr/bin/cat"
alias copy="xclip -r -sel clip"
alias cp='cp -v'
alias cpugetavail='cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_governors'
alias cpushowcurrent='cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
alias cpuusehigh='echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
alias cpuuselow='echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
alias cyme="sudo cyme --hide-buses -b icon -b name -b speed -t"
alias farge="farge --image-viewer nsxiv"
alias ga="git add"
alias gc="git commit"
alias gdu="gdu -c"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gp="git push"
alias grep="grep --color=always"
alias gs="git status"
alias lf="TERM=xterm-256color l-ueberzug"
alias lg="lazygit"
alias ls="ls --color=always"
alias lsusb="sudo cyme --hide-buses -b icon -b name -b speed -t"
alias mega-cmd="env HOME=/home/araaha/.local/share/ mega-cmd"
alias ncdu="gdu -c"
alias nerdfetch="nitch"
alias nsxiv="nsxiv -g 800x600+560+240 -b -a -sf"
alias nv="nvim"
alias packages="bat --paging=never --color=never --decorations=never /var/log/pacman.log | rg -a installed"
alias sa="sudo apt"
alias sai="sudo apt install"
alias sau="sudo apt update -y; sudo apt clean"
alias saup="sudo apt upgrade -y"
alias sxiv="nsxiv -g 800x600+560+240 -b -a -sf"
alias ticker='ticker --sort=user --config="$HOME/.config/.ticker.yaml"'
alias tree="tree --noreport -C"
alias vi="nvim -u ~/.config/nvim/vi.lua"
alias zathura="zathura --fork"
