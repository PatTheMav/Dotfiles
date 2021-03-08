if [ -z "${PAGER}" ]; then
    if command -v less &>/dev/null; then
        export PAGER='less'
    else
        export PAGER='more'
    fi
fi

export EDITOR="$(command -v vim)"

alias ll='ls -lh'         # long format and human-readable sizes
alias l='ll -A'           # long format, all files
alias lm="l | ${PAGER}"   # long format, all files, use pager
alias lr='ll -R'          # long format, recursive
alias lk='ll -Sr'         # long format, largest file size last
alias lt='ll -tr'         # long format, newest modification time last
alias lc='lt -c'          # long format, newest status change (ctime) last

if [ -z "${NO_COLOR}" ]; then
    case "${TERM}" in
        xterm-color|*-256color) color_term=1;;
    esac

    if [ -z "${color_term}" ]; then
        if [ -z "${GREP_COLOR}" ]; then export GREP_COLOR='37;45'; fi
        if [ -z "${GREP_COLORS}" ]; then export GREP_COLORS="mt=${GREP_COLOR}"; fi

        alias grep='grep --color=auto'

        if [ "${PAGER}" = "less" ]; then
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
        fi

        if command -v gcc &>/dev/null; then
            export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
        fi
        unset color_term
    fi
else
    export NO_COLOR=1
fi

if command -v dircolors &>/dev/null && ls --version &>/dev/null; then
    alias lx='ll -X'

    if [ -z "${NO_COLOR}" ]; then
        if [[ -s ${HOME}/.dir_colors ]]; then
            eval "$(dircolors --sh ${HOME}/.dir_colors)"
        elif [ -z "${LS_COLORS}" ]; then
            export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43'
        fi

        alias ls='ls --group-directories-first --color=auto'
    fi

    alias chmod='chmod --preserve-root -v'
    alias chown='chown --preserve-root -v'
else
    if [ -z "${NO_COLOR}" ]; then
        if [ -z "${CLICOLOR}" ]; then export CLICOLOR=1; fi
        if [ -z "${LSCOLORS}" ]; then LSCOLORS='ExfxcxdxbxGxDxabagacad'; fi
    fi
fi

case ${OSTYPE} in
    darwin*)
        BASH_OS_SETTINGS="${HOME}/.bash_extras/os_macos.bash"
        ;;
    linux*)
        BASH_OS_SETTINGS="${HOME}/.bash_extras/os_linux.bash"
        ;;
    msys*|mingw*|cygwin*)
        BASH_OS_SETTINGS="${HOME}/.bash_extras/os_windows.bash"
        ;;
    'AIX')     [[ "${TERM}" == "" ]] && export TERM='aixterm' ;;
    * )        [[ "${TERM}" == "" ]] && export TERM='vt100' ;;
esac

[[ -s ${BASH_OS_SETTINGS} ]] && source ${BASH_OS_SETTINGS}

BASH_OS_TOKENS="${HOME}/.bash_extras/os_tokens.sh"
[[ -s ${BASH_OS_TOKENS} ]] && source ${BASH_OS_TOKENS}

export COLUMNS=160
export LESS="--RAW-CONTROL-CHARS"
export LESSHISTFILE=-
