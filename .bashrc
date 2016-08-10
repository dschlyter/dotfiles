# bash is inferior to zsh, but on some hosts it is the only choice

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

alias rc='BASHRC_LOADED=""; source ~/.bashrc'

# Basic options
export HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize

export COLORFGBG='default;default'

# Prompt
BGREEN='\[\033[1;32m\]'
GREEN='\[\033[0;32m\]'
BRED='\[\033[1;31m\]'
RED='\[\033[0;31m\]'
BBLUE='\[\033[1;34m\]'
BLUE='\[\033[0;34m\]'
NORMAL='\[\033[00m\]'
PS1="${BLUE}\u@\h:${GREEN}\w${RED}\$ ${NORMAL}"

# allow .bashrc to be loaded multiple times (avoid prompt overwrite) but don't load heavy stuff below
[ "$BASHRC_LOADED" ] && return || BASHRC_LOADED=1

# Completition
complete -d cd

bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

if [ -f ~/.shellrc ]; then
    . ~/.shellrc
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
