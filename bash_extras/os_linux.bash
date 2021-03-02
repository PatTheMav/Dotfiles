#!/bin/bash

alias ps2='ps -facux '
alias ps1='ps -faxo "%U %t $p $a" '
alias af='ps -af'
alias df='df -h'

if [ -h /etc/init.d/nscd ]; then
    alias flushdns='sudo /etc/init.d/nscd restart'
elif [ -h /etc/init.d/dns-clean ]; then
    alias flushdns='sudo /etc/init.d/dns-clean start'
fi
if [ -z "$TERM" ]; then
    if [[ -e /usr/share/terminfo/*/xterm-256color ]]; then
        TERM='xterm-256color'
        export CLICOLOR="YES"
    else
        TERM='xterm-color'
    fi
    export TERM
fi

alias ls='ls --group-directories-first --color=auto'
alias l='ls -lFAh'         # all files, human-readable sizes
alias lm="l | ${PAGER}"   # all files, human-readable sizes, use pager
alias ll='ls -lFh'         # human-readable sizes
alias lr='ll -R'          # human-readable sizes, recursive
alias lx='ll -XB'         # human-readable sizes, sort by extension (GNU only)
alias lk='ll -Sr'         # human-readable sizes, largest last
alias lt='ll -tr'         # human-readable sizes, most recent last
alias lc='lt -c'          # human-readable sizes, most recent last, change time
