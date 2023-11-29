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
