#!/bin/bash

export LS_COLORS=GxFxCxDxBxegedabagaced
alias ps2='ps -facx '
alias ps1='ps -faxo "user etime pid args" '
alias af='ps -af'
alias ls='ls -hG'
alias l='ls -lF'
alias ll='ls -laF'
alias df='df -h'
alias top='top -o cpu'
alias listeners='lsof -iTCP -sTCP:LISTEN'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias flushdownloads="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"
alias listdownloads="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'select LSQuarantineDataURLString from LSQuarantineEvent' | sort"

if [ -x "$(command -v brew)" ]; then
    if [ -f /usr/local/etc/bash_completion ]; then
        source /usr/local/etc/bash_completion
    fi

    if [ -d /usr/local/opt/coreutils/libexec/gnubin/ ]; then
        eval $(dircolors -b)

        alias ls='gls --group-directories-first --color=auto'
        alias l='ls -lFAh'         # all files, human-readable sizes
        alias lm="l | ${PAGER}"   # all files, human-readable sizes, use pager
        alias ll='ls -lFh'         # human-readable sizes
        alias lr='ll -R'          # human-readable sizes, recursive
        alias lx='ll -XB'         # human-readable sizes, sort by extension (GNU only)
        alias lk='ll -Sr'         # human-readable sizes, largest last
        alias lt='ll -tr'         # human-readable sizes, most recent last
        alias lc='lt -c'          # human-readable sizes, most recent last, change time
    fi
fi
