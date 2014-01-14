# Env Variables

export PATH="$HOME/opt/sbt/bin:$GOPATH/bin:$HOME/bin:/opt/sudo:$PATH"
export GOPATH="$HOME/code/go"
export EDITOR="vim"
export VISUAL="vim"

# Aliases

## Conveniences
alias b='popd'
alias zshrc='vim ~/.zshrc; rz'
alias rz='source ~/.zshrc'
alias xo='xdg-open'
alias se='sudoedit'
alias ack='ack-grep'

## Global aliases
alias -g G='| grep -i'
alias -g L='| less'

## Flags on by default
alias locate='locate -i'
alias ls='ls -h --color=auto'
alias mv='mv -i'
alias cp='cp -i'
alias make='make -j 2'
alias nautilus='nautilus --no-desktop'

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

# Software beep
export BEEP=/usr/share/sounds/KDE-Im-Message-In.ogg
alias beep='paplay $BEEP'

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

# Prompt

autoload -U colors && colors
set_prompt() {
    local CURR_DIR="%{$fg[green]%}%40<..<%~%<<%{$reset_color%}"
    local PROMPT_CHAR="%{$fg_bold[red]%}%(!.#.>)%{$reset_color%}"
    PROMPT="$CURR_DIR$GIT_INFO$PROMPT_CHAR "
}

update_git_info() {
    git rev-parse --is-inside-work-tree &> /dev/null
    if [ $? -eq 0 ]; then
        local GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        if [ $GIT_BRANCH = "HEAD" ]; then
            GIT_BRANCH=$(git rev-parse --short HEAD)
        else
            local GIT_REMOTE=$(git config branch.$GIT_BRANCH.remote)
            local GIT_REMOTE_BRANCH="$GIT_REMOTE/$GIT_BRANCH"
            [[ $GIT_REMOTE == "" ]] && GIT_REMOTE_BRANCH="origin/master"
            local GIT_AHEAD="^$(git rev-list $GIT_REMOTE_BRANCH..HEAD 2> /dev/null | wc -l)"
            [[ $GIT_AHEAD == "^0" ]] && GIT_AHEAD=""
        fi

        command git diff --quiet --ignore-submodules HEAD &>/dev/null
        [[ $? -eq 1 ]] && local GIT_DIRTY='*'

        GIT_INFO="%{$fg_bold[blue]%}@$GIT_BRANCH$GIT_AHEAD$GIT_DIRTY%{$reset_color%}"
    else
        GIT_INFO=""
    fi
    set_prompt
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd update_git_info

# Show hostname in right prompt iff in SSH session
if [ "$SSH_CONNECTION" != "" ]; then
    RPROMPT="   %{$fg[blue]%}[%n@%m]%{$reset_color%}"
fi

# Fast cd with autojump

AUTOJUMP_SCRIPT=/usr/share/autojump/autojump.zsh
if [ -f $AUTOJUMP_SCRIPT ]; then
    source $AUTOJUMP_SCRIPT
    alias js='autojump --stat'
fi

# Vim mode while not messing up existing nice shortcuts

bindkey -v
bindkey -M viins 'jj' vi-cmd-mode

bindkey "^R" history-incremental-pattern-search-backward
bindkey "^F" history-incremental-pattern-search-forward
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

# Overriding configs goes in .zshrc_local

LOCAL_ZSHRC=~/.zshrc_local
if [ -f $LOCAL_ZSHRC ]; then
    source $LOCAL_ZSHRC
fi

