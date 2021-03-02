# Default aliases
alias df='df -h'
alias du='du -h'
alias ducks='du -cks * | sort -rn | head -11'
alias systail='less +F --follow-name /var/log/system.log'

if [ -x "$(command -v rsync)" ]; then
    alias rsynccopy="rsync --partial --progress --append --rsh=ssh -r -h "
    alias rsyncmove="rsync --partial --progress --append --rsh=ssh -r -h --remove-sent-files"
fi
