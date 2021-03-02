# Default aliases
alias ducks='du -cks * | sort -rn | head -11'
alias systail='less +F --follow-name /var/log/system.log'
alias fucking='sudo'
alias kindly='sudo'

if [ -x "$(command -v rsync)" ]; then
    alias rsynccopy="rsync --partial --progress --append --rsh=ssh -r -h "
    alias rsyncmove="rsync --partial --progress --append --rsh=ssh -r -h --remove-sent-files"
fi

if [ -x "$(command -v youtube-dl)" ]; then
    alias yt-dl="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
fi
