export PAGER='less'
export EDITOR=$(command -v vim)

case $OSTYPE in
    darwin*)
        BASH_OS_SETTINGS="${HOME}/.bash_extras/os_macos.bash"
        ;;
    linux*)
        BASH_OS_SETTINGS="${HOME}/.bash_extras/os_linux.bash"
        ;;
    msys*|mingw*|cygwin*)
        BASH_OS_SETTINGS="${HOME}/.bash_extras/os_windows.bash"
        ;;
    'AIX')     [[ "$TERM" == "" ]] && export TERM='aixterm' ;;
    * )        [[ "$TERM" == "" ]] && export TERM='vt100' ;;
esac

[[ -s $BASH_OS_SETTINGS ]] && source $BASH_OS_SETTINGS

BASH_OS_TOKENS="${HOME}/.bash_extras/os_tokens.sh"
[[ -s $BASH_OS_TOKENS ]] && source $BASH_OS_TOKENS

export COLUMNS=160
export LESS="--RAW-CONTROL-CHARS"
export LESSHISTFILE=-

export LESS_TERMCAP_mb=$(tput bold; tput setaf 1) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 1) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 4; tput setab 3) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 2) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)