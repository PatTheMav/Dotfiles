#
# User configuration sourced by interactive shells
#

# -> P10k Instant Prompt

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -> Zsh configuration
# --> History
setopt HIST_IGNORE_ALL_DUPS

# --> Input/output
KEYTIMEOUT=1
bindkey -v

# --> Autocorrect
setopt CORRECT
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# --> Treat paths as full words when using M-b and M-f
WORDCHARS=${WORDCHARS//[\/]}

# -> Module configuration
# --> completion
#zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

# --> environment
#zstyle ':zim:termtitle' format '%n@%m: %~'

# --> zimfw-extras
zstyle ':zim:termtitle' format '%n@%m: %~'
zstyle ':zim:tabtitle' format '%15<..<%~%<< - %n@%15>..>%m%>>'

# --> Input
zstyle ':zim:input' double-dot-expand yes

# --> ssh
zstyle ':zim:ssh' ids 'id_ed25519 id_rsa'

# --> zsh-autosuggestions
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'

# --> zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=10'

# -> Initialize modules
if [[ ${ZDOTDIR:-${HOME}}/.zim/init.zsh -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  # Update static initialization script if it's outdated, before sourcing it
  source ${ZDOTDIR:-${HOME}}/.zim/zimfw.zsh init -q
fi
source ${ZDOTDIR:-${HOME}}/.zim/init.zsh

# -> Post-init module configuration
# --> zsh-history-substring-search
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# -> Zsh prompt configuration
#[[ ! -f ~/.m2.zsh ]] || source ~/.m2.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -> Custom zsh config
[[ -s ${ZDOTDIR:-${HOME}}/.zshrc.custom ]] && source ${ZDOTDIR:-${HOME}}/.zshrc.custom

