# Aliases

## Conveniences
alias b='popd'
alias zshrc='vim ~/.zshrc; rc'
alias rc='source ~/.zshrc'

## Global aliases
alias -g G='| grep -i'
alias -g L='| less'
alias -g MAP='| xargs --no-run-if-empty -n 1'
alias -g MAPI='| xargs --no-run-if-empty -n 1 -i'
alias -g C1='| cl 1'

# Functions

function eachdir {
    for dir in *(/); do
        pushd .
        cd $dir
        eval "$@"
        popd
    done
}

# Aliases and functions shared with bash config

SHELLRC=~/.shellrc
[ -f $SHELLRC ] && source $SHELLRC

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
        local GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
        if [ $GIT_BRANCH = "HEAD" ]; then
            GIT_BRANCH=$(git rev-parse --short HEAD 2> /dev/null)
        else
            local GIT_REMOTE=$(git config branch.$GIT_BRANCH.remote)
            local GIT_REMOTE_BRANCH="$GIT_REMOTE/$GIT_BRANCH"
            test -z "$GIT_REMOTE" && GIT_REMOTE_BRANCH="origin/master"
            local GIT_AHEAD="^$(git rev-list $GIT_REMOTE_BRANCH..HEAD 2> /dev/null | wc -l)"
            [[ $GIT_AHEAD == "^0" ]] && GIT_AHEAD=""
        fi

        GIT_DIRTY=""
        test -n "$(git status --porcelain)" && GIT_DIRTY='*' # required git 1.7+

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

# Readline keybindings with ability to enter vim-mode

bindkey -e
bindkey 'jj' vi-cmd-mode # enter vim-mode with jj
bindkey '^[' vi-cmd-mode # enter vim-mode with Esc

bindkey '^K' up-line-or-history
bindkey '^J' down-line-or-history
bindkey -M vicmd '^A' beginning-of-line
bindkey -M vicmd '^E' end-of-line
bindkey -M vicmd '^K' up-line-or-history
bindkey -M vicmd '^J' down-line-or-history

# Toggle vim with Ctrl-Z
# Should be after bindkey -v
foreground-vim() {
    fg %vim
}
zle -N foreground-vim
bindkey '^Z' foreground-vim

# Completition

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*' completer _expand _complete _match _correct _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 4 numeric
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=** r:|=**' 'm:{a-z}={A-Z} r:|[._-]=** r:|=** l:|=*' 'm:{a-z}={A-Z} r:|[._-]=** r:|=** l:|=*' 'm:{a-z}={A-Z} r:|[._-]=** r:|=** l:|=*'
zstyle :compinstall filename '/home/david/.zshrc'
zstyle ':completion:*' special-dirs true    # autocomplete on ../
zstyle ':completion:*' menu select

setopt completeinword           # not just at the end
setopt alwaystoend              # when complete from middle, move cursor
setopt correct                  # spelling correction

# Use colors for autocompletion lists
LS_COLORS="di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32";
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

autoload -Uz compinit
if [[ "$(uname -s)" == "Darwin" ]]; then
    # skip single-user security checks to allow for multi user homebrew
    compinit -u
else
    compinit
fi

# fasd should be setup after compinit
fasd_setup

# setup fzf
# ctrl-r history search
# ctrl-t insert file in subfolder
# ctrl-f file from history (custom plugin)
# alt-c cd to subdir
# tmux switch pane
source_if_exists ~/.fzf.zsh
source_if_exists ~/.dotfiles/.fzf_extensions.zsh

# Settings

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY       # append history incrementally as commands are entered

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
setopt nopromptcr               # don't add \r which overwrites cmd output with no \n
setopt histverify               # when using ! cmds, confirm first
setopt interactivecomments      # escape commands so i can use them later
setopt recexact                 # recognise exact, ambiguous matches
setopt histignorespace          # commands starting with space are not remembered
setopt histignorealldups        # removes duplicate commands, even if non-sequential, useful for percol search

export REPORTTIME=10 # print stats for commands running longer than 10 secs

source_if_exists ~/.dotfiles/submodules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[path]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white,bold'

# Overriding configs goes in .zshrc_local
source_if_exists ~/.zshrc_local
source_if_exists ~/.zshrc_cygwin
source_if_exists ~/.zshrc_mac
