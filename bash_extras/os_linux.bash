alias ps2='ps -facux '
alias ps1='ps -faxo "%U %t $p $a" '
alias af='ps -af'

if [ -h /etc/init.d/nscd ]; then
    alias flushdns='sudo /etc/init.d/nscd restart'
elif [ -h /etc/init.d/dns-clean ]; then
    alias flushdns='sudo /etc/init.d/dns-clean start'
fi

MNML_USER_CHAR=''
