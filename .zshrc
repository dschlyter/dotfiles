# Prompt

if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# Simple hash function, usage: stupid_hash str mod
stupid_hash() {
    i=0
    for chr in $(echo $1 | sed -e 's/\(.\)/\1 /g'); do 
        i=$((($i+$(printf '%d' "'$chr")) % $2))
    done
    echo $i
} 
host_color() {
    host_colorset=(green cyan blue yellow magenta white)
    num=$(($(stupid_hash $HOST ${#host_colorset[@]}) + 1)) 
    #stupid one based indexing :(
    echo ${host_colorset[$num]}
}

autoload -U colors && colors
#PROMPT="%{$fg[yellow]%}%30<..<%~%<<%{$fg_bold[red]%}%(!.#.>)%{$reset_color%} "
PROMPT="%{$fg[green]%}%30<..<%~%<<%{$fg_bold[red]%}%(!.#.>)%{$reset_color%} "
RPROMPT="   %{$fg[$(host_color)]%}[%n@%m]%{$reset_color%}"

# Variables

export GOPATH="$HOME/code/go"
export PATH="$HOME/opt/sbt/bin:$GOPATH/bin:$HOME/bin:/opt/sudo:$PATH"
export EDITOR="vim"
export VISUAL="vim"

# Fast cd with marks

export MARKPATH=$HOME/.marks
function j  { 
    if [ "$1" ]
    then cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
    else marks
    fi
}
function mark { 
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark { 
    rm -i $MARKPATH/$1 
}
function marks {
    ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}

# Aliases

## Global aliases
alias -g G='| grep'
alias -g L='| less'

## Flags on by default
alias locate='locate -i'
alias ls='ls -h --color=auto'
alias vim='vim -p'
alias mv='mv -i'
alias cp='cp -i'
alias make='make -j 2'

# Default to date -Is if no args are supplied
# iso-8601 is the one true date format
if [ -f /bin/date ]; then
    func date() {
        if [ "$*" ]; then
            /bin/date $*
        else
            /bin/date -Is
        fi
    }
fi

## Conveniences
alias b='popd'
alias zshrc='vim ~/.zshrc; rz'
alias rz='source ~/.zshrc'

# Software beep
export BEEP=/usr/share/sounds/KDE-Im-Message-In.ogg
alias beep='paplay $BEEP'

# Vim mode while not messing up existing nice shortcuts

bindkey -v
bindkey -M viins 'jj' vi-cmd-mode

bindkey "^R" history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' backward-kill-word

bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^K' up-line-or-history
bindkey '^J' down-line-or-history
bindkey -M vicmd '^K' up-line-or-history
bindkey -M vicmd '^J' down-line-or-history

# Toggle vim with Ctrl-Z
# Should be after bindkey -v
foreground-vim() {
    fg %vim
}
zle -N foreground-vim
bindkey '^Z' foreground-vim

# Move to where the arguments belong.
after-first-word() {
   zle beginning-of-line
   zle forward-word
}
zle -N after-first-word
bindkey "^X1" after-first-word


# Functions

function retry {
    while true; do
        $*
        STATUS=$?
        if [ "$STATUS" -eq "0" ]; then
            break;
        fi
        echo "Exit $STATUS - Retrying in 1 second"
        sleep 1
    done
}

# Completition

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*' completer _expand _complete _match _correct _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=** r:|=**' 'm:{a-z}={A-Z} r:|[._-]=** r:|=** l:|=*' 'm:{a-z}={A-Z} r:|[._-]=** r:|=** l:|=*' 'm:{a-z}={A-Z} r:|[._-]=** r:|=** l:|=*'
zstyle :compinstall filename '/home/david/.zshrc'
zstyle ':completion:*' special-dirs true    # autocomplete on ../
zstyle ':completion:*' menu select

autoload -Uz compinit
compinit

# Settings

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS         # ignore duplicates in history
setopt HIST_IGNORE_SPACE        # ignore space appended commands
setopt APPEND_HISTORY           # append history at close?

## mostly from ofb.net zshtricks

setopt nobeep                   # i hate beeps
setopt autocd                   # change to dirs without cd
setopt autopushd                # automatically append dirs to the push/pop list
setopt pushdsilent
setopt pushdignoredups          # and don't duplicate them
#setopt nocheckjobs             # don't warn me about bg processes when exiting
#setopt nohup                   # and don't kill them, either
setopt listpacked               # compact completion lists
setopt listtypes                # show types in completion
setopt extendedglob             # weird & wacky pattern matching - yay zsh!
setopt nocaseglob
setopt numericglobsort
setopt completeinword           # not just at the end
setopt alwaystoend              # when complete from middle, move cursor
setopt correct                  # spelling correction
setopt nopromptcr               # don't add \r which overwrites cmd output with no \n
setopt histverify               # when using ! cmds, confirm first
setopt interactivecomments      # escape commands so i can use them later
setopt recexact                 # recognise exact, ambiguous matches
