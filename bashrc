umask 022

case $- in
    *i*) ;;
      *) return;;
esac

if [ "${BASH}" ]; then
    export PS1="[\u@\h \W]\\$ "
else
    if [ "$(id -u)" -eq 0 ]; then
        export PS1='# '
    else
        export PS1='$ '
    fi
fi

shopt -s checkwinsize
shopt -s cdspell

bind "set completion-ignore-case on"
bind "set bell-style none"
bind "set show-all-if-ambiguous on"

export USER="$(id -un)"
#export LANG=C
export LOGNAME="${USER}"
export HOSTNAME="$(/bin/hostname)"
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=ignoredups

for bash_extra in ${HOME}/.bash_extras/0*.bash; do
  source "${bash_extra}"
done
