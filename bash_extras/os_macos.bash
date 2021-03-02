alias ps2='ps -facx '
alias ps1='ps -faxo "user etime pid args" '
alias af='ps -af'
alias top='top -o cpu'
alias listeners='lsof -iTCP -sTCP:LISTEN'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias flushdownloads="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"
alias listdownloads="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'select LSQuarantineDataURLString from LSQuarantineEvent' | sort"

if [ -x "$(command -v brew)" ]; then
    if [ -f /usr/local/etc/bash_completion ]; then
        source /usr/local/etc/bash_completion
    fi
fi

MNML_USER_CHAR=''
