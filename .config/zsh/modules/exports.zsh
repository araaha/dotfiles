export XDG_RUNTIME_DIR='/run/user/1000'
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CURRENT_DESKTOP=openbox
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export GOPATH="$XDG_DATA_HOME/go"
export PATH="$PATH:/usr/local/bin:$HOME/.local/bin:$GOPATH/bin"
export W3M_DIR="$XDG_DATA_HOME/w3m"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export WORDCHARS="_*?[]~&;!#$%^(){<>=."

export VISUAL=/usr/bin/nvim
export EDITOR=/usr/bin/nvim

export BAT_THEME="gruvbox-modified"
export PAGER="bat"

# export LESS_TERMCAP_so=$(echo -e '\e[1;44m')
# export LESS_TERMCAP_se=$(echo -e '\e[0m')
# export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
# export LESS_TERMCAP_mb=$(tput bold; tput setaf 3) # green
# export LESS_TERMCAP_md=$(tput bold; tput setaf 3) # cyan
# export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 1) # white

export SYSTEMD_PAGER="moar"
export SYSTEMD_PAGERSECURE=true


export LESS='--tilde --save-marks --shift 2 -g --ignore-case --incsearch -j.5 -m -R -n --use-color -Dd+b$Du+r$DS-b$DE-r$DP+g'
export MOAR='-no-linenumbers -no-statusbar -style algol_nu -wrap -colors 16M'

export LESSHISTSIZE=1000

# export MANPAGER='less -g --ignore-case --incsearch -j.5 -m  -R -n --use-color -Dd+y$Du+r$DS-b$DE-r$DP+g'
export MANPAGER='moar -no-linenumbers -no-statusbar -style algol_nu -wrap'

source $HOME/.config/lf/colors
source $HOME/.config/lf/diricons

export LF_DATA_HOME="$HOME/dotfiles-private/.local/share"
export LS_COLORS='*#=00;90:*~=00;90:*.7z=05;31:*.aac=00;36:*.ace=05;31:*.alz=05;31:*.anx=01;35:*.arc=05;31:*.arj=05;31:*.asf=05;35:*.au=00;36:*.avi=05;35:*.avif=05;35:*.axa=01;33:*.axv=01;35:*.bak=00;90:bd=40;33;01:*.bmp=05;35:*.bz=05;31:*.bz2=05;31:ca=00:*.cab=05;31:*.cache=38;5;246:cd=40;33;01:*.cgm=05;35:*.conf=02;35:*.cpio=05;31:*.crdownload=00;90:*.deb=05;31:di=01;34:*.dist=38;5;246:*.dl=05;35:do=01;35:*.doc=38;5;109:*.docx=38;5;109:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.dwm=05;31:*.dz=05;31:*.ear=05;31:*.emf=05;35:*.esd=05;31:ex=01;32:*.flac=00;36:*.flc=05;35:*.fli=05;35:*.flv=05;35:*.gif=05;35:*.gl=05;35:*.go=05;36:*.gpg=05;31:*.gz=05;31:*.html=38;5;109:*.jar=05;31:*.jpeg=05;35:*.jpg=05;35:*.js=38;5;109:*.json=38;5;109:*.lha=05;31:ln=01;36:*.lock=38;5;246:*.log=38;5;246:*.lrz=05;31:*.lua=05;33:*.lz=05;31:*.lz4=05;31:*.lzh=05;31:*.lzma=05;31:*.lzo=05;31:*.m2v=05;35:*.m4a=00;36:*.m4v=05;35:*.md=38;5;109:mh=00:mi=00:*.mid=00;36:*.midi=00;36:*.mjpeg=05;35:*.mjpg=05;35:*.mka=00;36:*.mkv=05;35:*.mng=05;35:*.mov=05;35:*.mp3=05;36:*.mp4=05;35:*.mp4v=05;35:*.mpc=00;36:*.mpeg=05;35:*.mpg=05;35:*.neon=38;5;109:*.nuv=05;35:*.odp=38;5;109:*.ods=38;5;109:*.odt=38;5;109:*.oga=00;36:*.ogg=00;36:*.ogm=05;35:*.ogv=05;35:*.ogx=05;35:*.old=00;90:*.opus=00;36:or=40;31;01:*.orig=00;90:ow=34;42:*.part=00;90:*.pbm=05;35:*.pcx=05;35:*.pdf=38;5;109:*.pgm=05;35:*.php=38;5;109:*.phtml=38;5;109:pi=40;33:*.png=05;35:*.ppm=05;35:*.ppt=38;5;109:*.pptx=38;5;109:*.py=05;36:*.qt=05;35:*.ra=00;36:*.rar=05;31:*.rej=00;90:*.rm=05;35:*.rmvb=05;35:*.rpm=05;31:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:rs=0:*.rz=05;31:*.sar=05;31:sg=30;43:so=01;35:*.spx=00;36:st=37;44:su=37;41:*.svg=05;35:*.svgz=05;35:*.swm=05;31:*.swp=00;90:*.t7z=05;31:*.tar=05;31:*.taz=05;31:*.tbz=05;31:*.tbz2=05;31:*.temp=38;5;246:*.tex=38;5;109:*.tga=05;35:*.tgz=05;31:*.tif=05;35:*.tiff=05;35:*.tlz=05;31:*.tmp=00;90:*.ttf=05;35:tw=30;42:*.txt=38;5;109:*.txz=05;31:*.tz=05;31:*.tzo=05;31:*.tzst=05;31:*.ucf-dist=00;90:*.ucf-new=00;90:*.vob=05;35:*.war=05;31:*.wav=00;36:*.webm=05;35:*.webp=05;35:*.wim=05;31:*.wmv=05;35:*.xbm=05;35:*.xcf=05;35:*.xls=38;5;109:*.xlsx=38;5;109:*.xml=38;5;10*.xpm=05;35:*.xspf=00;36:*.xwd=05;35:*.xz=05;31:*.yuv=05;35:*.z=05;31:*.Z=01;31:*.zip=05;31:*.zoo=05;31:*.zsh=05;33:*.zst=05;31:'
export JQ_COLORS="0;90:0;39:0;39:1;33:0;32:1;39:1;39:1;34"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export GPG_TTY=$(tty)
export GNUPGHOME="$XDG_DATA_HOME/.gnupg"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/pass"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

export RIPGREP_CONFIG_PATH="$HOME/dotfiles/.config/ripgreprc"

export _ZO_ECHO=0
export _ZO_DATA_DIR="$HOME/.local/share/zoxide/"
export TERM=tmux-256color
