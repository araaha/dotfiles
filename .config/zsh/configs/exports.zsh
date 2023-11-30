export XDG_RUNTIME_DIR='/run/user/1000'
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CURRENT_DESKTOP=openbox
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export GOPATH="$XDG_DATA_HOME/go"
export PATH="$PATH:/usr/local/bin:$HOME/.local/bin:$GOPATH:$XDG_DATA_HOME/gem/ruby/3.0.0/bin/"
export W3M_DIR="$XDG_DATA_HOME/w3m"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export WORDCHARS="_*?[]~&;!#$%^(){<>=."

export VISUAL=/usr/bin/nvim
export EDITOR=/usr/bin/nvim
export BROWSER=/usr/bin/google-chrome-stable

export BAT_THEME="gruvbox-modified"
export PAGER="bat"

# export LESS_TERMCAP_so=$(echo -e '\e[1;44m')
# export LESS_TERMCAP_se=$(echo -e '\e[0m')
# export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
# export LESS_TERMCAP_mb=$(tput bold; tput setaf 3) # green
# export LESS_TERMCAP_md=$(tput bold; tput setaf 3) # cyan
# export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 1) # white

export SYSTEMD_PAGER="/usr/bin/moar -follow"
export SYSTEMD_PAGERSECURE=true


export LESS='--tilde --save-marks --shift 2 -g --ignore-case --incsearch -j.5 -m -R -n --use-color -Dd+b$Du+r$DS-b$DE-r$DP+g'
export MOAR='-no-linenumbers -no-statusbar -style gruvbox -wrap'

export LESSHISTFILE="$HOME/dotfiles/zsh/lesshst"
export LESSHISTSIZE=1000

# export MANPAGER='less -g --ignore-case --incsearch -j.5 -m  -R -n --use-color -Dd+y$Du+r$DS-b$DE-r$DP+g'
export MANPAGER='moar -no-linenumbers -no-statusbar -style gruvbox'

source $HOME/.config/lf/colors
source $HOME/.config/lf/diricons
export LF_DATA_HOME="$HOME/dotfiles-private/.local/share"
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.py=05;36:*.go=05;36:*.zsh=05;33:*.lua=05;33:*.ttf=05;35:*.gpg=05;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.bak=38;5;246:*.cache=38;5;246:*.dist=38;5;246:*.lock=38;5;246:*.log=38;5;246:*.old=38;5;246:*.orig=38;5;246:*.temp=38;5;246:*.tmp=38;5;246:*.7z=01;31:*.Z=01;31:*.ace=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cpio=01;31:*.deb=01;31:*.dz=01;31:*.ear=01;31:*.gz=01;31:*.jar=01;31:*.lz=01;31:*.lzh=01;31:*.lzma=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.war=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.anx=01;35:*.asf=01;35:*.avi=01;35:*.axv=01;35:*.bmp=01;35:*.cgm=01;35:*.dl=01;35:*.emf=01;35:*.flc=01;35:*.fli=01;35:*.flv=01;35:*.gif=01;35:*.gl=01;35:*.jpeg=01;35:*.jpg=01;35:*.m2v=01;35:*.m4v=01;35:*.mkv=01;35:*.mng=01;35:*.mov=01;35:*.mp4=01;35:*.mp4v=01;35:*.mpeg=01;35:*.mpg=01;35:*.nuv=01;35:*.ogm=01;35:*.ogv=01;35:*.ogx=01;35:*.pbm=01;35:*.pcx=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.qt=01;35:*.rm=01;35:*.rmvb=01;35:*.svg=01;35:*.svgz=01;35:*.tga=01;35:*.tif=01;35:*.tiff=01;35:*.vob=01;35:*.webm=01;35:*.wmv=01;35:*.xbm=01;35:*.xcf=01;35:*.xpm=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=01;33:*.au=01;33:*.flac=01;33:*.mid=01;33:*.midi=01;33:*.mka=01;33:*.mp3=01;33:*.mpc=01;33:*.ogg=01;33:*.ra=01;33:*.wav=01;33:*.axa=01;33:*.oga=01;33:*.spx=01;33:*.xspf=01;33:*.doc=38;5;109:*.docx=38;5;109:*.html=38;5;109:*.js=38;5;109:*.json=38;5;109:*.md=38;5;109:*.neon=38;5;109:*.odp=38;5;109:*.ods=38;5;109:*.odt=38;5;109:*.pdf=38;5;109:*.php=38;5;109:*.phtml=38;5;109:*.ppt=38;5;109:*.pptx=38;5;109:*.tex=38;5;109:*.txt=38;5;109:*.xls=38;5;109:*.xlsx=38;5;109:*.xml=38;5;10'
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
