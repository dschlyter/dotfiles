# Aliases

## Conveniences
alias b='popd'
alias zshrc='vim ~/.zshrc; rc'
alias rc='source ~/.zshrc'

## Global aliases
alias -g P='|'
alias -g G='| grep -i'
alias -g L='| less'
alias -g MAP='| xargs --no-run-if-empty -n 1'
alias -g MAPI='| xargs --no-run-if-empty -n 1 -i'
alias -g C1='| cl 1'

# Functions

function eachdir {
    max_ret=0

    for dir in *; do
        test -d "$dir" || continue
        pushd .
        cd $dir
        result="$(eval "$@" 2>&1)"
        ret=$?
        max_ret=$((ret > max_ret ? ret : max_ret))
        if [ "$ret" -ne 0 ]; then
            cecho -b 9 "--- $dir ---"
            echo "$result"
        elif [ -n "$result" ]; then
            cecho -b 12 "--- $dir ---"
            echo "$result"
        fi
        popd
    done

    return $max_ret
}

# cd to directory in the same level ie. /dir/hej to /dir/hej2 with autocomplete
function cs {
    cd ../$(ls ../(/) | grep "$*" | fzf -1)
}

# Aliases and functions shared with bash config

SHELLRC=~/.shellrc
[ -f $SHELLRC ] && source $SHELLRC

# Prompt

autoload -U colors && colors
set_prompt() {
    local CURR_DIR="%F{47}%40<..<%~%<<%f"
    local PROMPT_CHAR="%F{168}%B%(!.#.>)%s%b"
    local PREFIX=" "
    [[ -n "$GIT_STATUS" ]] && PREFIX=""
    local EXIT_CODE_PROMPT="%F{221}%B%(?..${PREFIX}[%?] )%b%f"
    PROMPT="$CURR_DIR$GIT_BRANCH_INFO$GIT_STATUS$EXIT_CODE_PROMPT$PROMPT_CHAR "
}

update_git_info() {
    GIT_BRANCH_INFO=""
    GIT_STATUS=""

    git rev-parse --is-inside-work-tree &> /dev/null
    if [ $? -eq 0 ]; then
        local GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
        if [ $GIT_BRANCH = "HEAD" ]; then
            GIT_BRANCH=$(git rev-parse --short HEAD 2> /dev/null)
        else
            local GIT_REMOTE=$(git config branch.$GIT_BRANCH.remote)
            local GIT_REMOTE_BRANCH="$GIT_REMOTE/$GIT_BRANCH"
            test -z "$GIT_REMOTE" && GIT_REMOTE_BRANCH="origin/master"
            local GIT_AHEAD=" ↑$(git rev-list $GIT_REMOTE_BRANCH..HEAD 2> /dev/null | wc -l)"
            local GIT_BEHIND=" ↓$(git rev-list HEAD..$GIT_REMOTE_BRANCH 2> /dev/null | wc -l)"
            [[ $GIT_AHEAD == " ↑0" ]] && GIT_AHEAD=""
            [[ $GIT_BEHIND == " ↓0" ]] && GIT_BEHIND=""
        fi

        local GIT_DIRTY=""
        test -n "$(git status --porcelain)" && GIT_DIRTY=' δ' # requires git 1.7+

        GIT_BRANCH_INFO="%F{69}%B@$GIT_BRANCH%f"
        [[ -n "$GIT_AHEAD$GIT_BEHIND$GIT_DIRTY" ]] && GIT_STATUS="%F{46}$GIT_AHEAD%F{220}$GIT_BEHIND%F{197}$GIT_DIRTY%b%f "
    else
        GIT_INFO=""
    fi
    set_prompt
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd update_git_info

# Show hostname in right prompt iff in SSH session or sudo su
if [ -n "$SSH_CONNECTION" ] || [ -n "$SUDO_USER" ] || [ "$LOGNAME" != "$USER" ]; then
    local SSH_PROMPT=" %{$fg[cyan]%}[%n@%m]%{$reset_color%}"
fi

RPROMPT="   $SSH_PROMPT"

# Git autofetch

_git_autofetch() {
    test -f .git/FETCH_HEAD || return
    test "$(ssh-add -l | wc -l)" -gt 0 || return

    local NOW="$(date "+%s")"
    local FETCH_DEADLINE="$(($NOW - 12 * 3600))"
    test "$(stat -c "+%Y" .git/FETCH_HEAD)" -gt "$FETCH_DEADLINE" && return
    test -f .gitautofetch && test "$(cat .gitautofetch)" -gt "$FETCH_DEADLINE" && return

    # log time to avoid repeated fetches on failure
    echo "$NOW" > .gitautofetch
    git fetch &
}

add-zsh-hook precmd _git_autofetch

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

# recent commands search should do exact matching by default
export FZF_CTRL_R_OPTS="-e"

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
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[path]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white,bold'

# Overriding configs goes in .zshrc_local
source_if_exists ~/.zshrc_local
source_if_exists ~/.zshrc_cygwin
source_if_exists ~/.zshrc_mac
