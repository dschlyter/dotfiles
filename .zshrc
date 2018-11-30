# kind of ridiculous that zsh startup needs profiling

# 0 disabled, 1 enabled, 2 verbose
profiling_level=0
test $profiling_level -gt 0 && profiling_start_time="$(gdate +%s%3N)"

profiling_log() {
    if [[ $profiling_level -gt 0 ]]; then
        echo $(($(gdate +%s%3N) - profiling_start_time)) "$@"
    fi
}

profiling_log "start"

# even more profiling, but a bit verbose
test $profiling_level -gt 1 && zmodload zsh/zprof

# profiling notes
# 2018-01-11 macbook, 350 ms
# 2018-01-11 macbook, after zplug installation, 250 ms, amazing
# causes of slowness
# completition, try delete .zcompdump (maybe automate this when startup is slow if this reoccurs)

# Plugins
# (it seems that this works best at the top of the config)

zgen_conf=~/.zgen/zgen.zsh
test -f "$zgen_conf" && source "$zgen_conf"

if which zgen > /dev/null; then
    # plugin conf - needs to be loaded everytime
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[path]='fg=magenta,bold'
    ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white,bold'

    plugin_def="$HOME/.zgen_plugins"
    if ! zgen saved || [[ "$plugin_def" -nt "$HOME/.zgen/init.zsh" ]]; then
        # fix compaudit warnings
        export ZGEN_COMPINIT_FLAGS="-u"
        echo "zplug conf change detected, reinitializing"
        source "$plugin_def"
    fi
fi

profiling_log "plugins loaded"

# Aliases

## Conveniences
alias b='popd'
alias h='harpo'
alias zshrc='vim ~/.zshrc; rc'
alias rc='source ~/.zshrc'
alias zl="vim $HOME/.zshrc_local; rc"

## Global aliases
# note: alias R breaks fasd
alias -g G='| grep -i'
alias -g L='| less'
alias -g H='| head'
alias -g REV='| reverse'
alias -g MAP='| xargs --no-run-if-empty -n 1'
alias -g MAPI='| xargs --no-run-if-empty -n 1 -i'
alias -g C1='| cl 1'
alias -g GS='$(git select)'
alias -g DL='"$HOME/downloads/$(ls -1 -tr $HOME/downloads | tail -n 1)"'

# Functions

# quickly save the previous command
function save {
    if [[ -n "$1" ]]; then
        local last_command="$(fc -l -nIL -1 -1 2> /dev/null)"
        _quicksave_command "$1" "$last_command"
    else
        echo "Name required as first arg"
        echo "Current commands:"
        ls $HOME/commands
    fi
}

function unsave {
    rm "$HOME/commands/$1"
}

# quickly save a set of the previous commands
function save-hist {
    if [[ -n "$1" ]]; then
        _quicksave_command "$1" "$(history -10 | sed -E 's/[ 0-9*]+//' | fzf -m)"
    else
        echo "Name required as first arg"
    fi
}

function _quicksave_command {
    mkdir -p "$HOME/commands"
    filename="$HOME/commands/$1"
    if [[ ! -f "$filename" ]]; then
        shift
        echo "#!/bin/zsh

        set -e

        " | sed -E 's/^ +//' > "$filename"
        echo "$@" >> "$filename"
        chmod +x "$filename"
    else
        echo "Command already exists, delete with unsave $1"
        return 1
    fi
}

# quickly redefine local functions in editor
# for real scripts it is probably better with vim =command
function redef {
    test -n "$1" || return 1
    where "$1" > /tmp/redef
    test $? -eq 0 || return 1

    cat /tmp/redef > /tmp/redef-orig
    $EDITOR /tmp/redef
    if ! diff -q /tmp/redef /tmp/redef-edit; then
        eval "$(cat /tmp/redef)"
    else
        echo "No changes"
    fi
}


# poor mans watch, but with access to shell functions
function shell-watch {
    while true; do
        output="$(date)\n$(eval "$@")"
        clear
        echo "$output"
        sleep 2
    done
}

function eachdir {
    local depth=1
    local quiet=""

    while getopts ":d:q" opt; do
        case $opt in
            d)
                depth="$OPTARG"
                ;;
            q)
                quiet="yes"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    max_ret=0

    for dir in $(find -L . -maxdepth $depth -type d -not -path '*/\.*'); do
        test "$dir" "==" "." && continue
        test -d "$dir" || continue
        (cd $dir
        result="$(eval "$@" 2>&1)"
        ret=$?
        max_ret=$((ret > max_ret ? ret : max_ret))

        if [ "$ret" -ne 0 ]; then
            if [ -z "$quiet" ]; then
                cecho -b 9 "--- $dir ---"
            fi
            echo "$result"
        elif [ -n "$result" ]; then
            if [ -z "$quiet" ]; then
                cecho -b 12 "--- $dir ---"
            fi
            echo "$result"
        fi)
    done

    return $max_ret
}

# cd to directory in the same level ie. /dir/hej to /dir/hej2 with autocomplete
function cs {
    cd ../$(ls ../(/) | grep "$*" | fzf -1)
}

profiling_log "aliases loaded"

# Aliases and functions shared with bash config

SHELLRC=~/.shellrc
[ -f $SHELLRC ] && source $SHELLRC

profiling_log "shellrc loaded"

# Prompt

autoload -U colors && colors
_set_prompt() {
    test -n "$VIRTUAL_ENV" && local VENV="(venv) "
    local CURR_DIR="%F{47}%40<..<%~%<<%f"
    local PROMPT_CHAR="%F{168}%B%(!.#.>)%s%b"
    local EXIT_CODE_PROMPT="%F{221}%B%(?.. [%?] )%b%f"
    PROMPT="$VENV$CURR_DIR$GIT_PROMPT$EXIT_CODE_PROMPT$PROMPT_CHAR "
}

_update_git_info() {
    GIT_PROMPT=""

    git rev-parse --is-inside-work-tree &> /dev/null
    if [ $? -eq 0 ]; then
        local GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
        local GIT_STATUS=""
        local STATUS_SPACE=""

        if [ $GIT_BRANCH = "HEAD" ]; then
            GIT_BRANCH=$(git rev-parse --short HEAD 2> /dev/null)
        else
            local GIT_REMOTE=$(git config branch.$GIT_BRANCH.remote)
            local GIT_REMOTE_BRANCH="$GIT_REMOTE/$GIT_BRANCH"
            test -z "$GIT_REMOTE" && GIT_REMOTE_BRANCH="origin/master"

            local GIT_AHEAD="$(git rev-list $GIT_REMOTE_BRANCH..HEAD 2> /dev/null | wc -l)"
            if [ "$GIT_AHEAD" -gt 0 ]; then
                GIT_STATUS="%F{46}↑$GIT_AHEAD"
                STATUS_SPACE=" "
            fi
            local GIT_BEHIND="$(git rev-list HEAD..$GIT_REMOTE_BRANCH 2> /dev/null | wc -l)"
            if [ "$GIT_BEHIND" -gt 0 ]; then
                GIT_STATUS="$GIT_STATUS$STATUS_SPACE%F{220}↓$GIT_BEHIND"
                STATUS_SPACE=" "
            fi
        fi

        if [ -n "$(git status --porcelain)" ]; then
            GIT_STATUS="$GIT_STATUS${STATUS_SPACE}%F{197}δ" # requires git 1.7+
        fi

        GIT_PROMPT="%F{69}%B@$GIT_BRANCH%f%b"
        if [[ -n "$GIT_STATUS" ]]; then
            GIT_PROMPT="$GIT_PROMPT%B%F{69}($GIT_STATUS%F{69})%f%b"
        fi
    fi
    _set_prompt
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_git_info

# Show hostname in right prompt iff in SSH session or sudo su
if [ -n "$SSH_CONNECTION" ] || [ -n "$SUDO_USER" ] || [ "$LOGNAME" != "$USER" ]; then
    local SSH_PROMPT=" %{$fg[cyan]%}[%n@%m]%{$reset_color%}"
fi

RPROMPT="   $SSH_PROMPT"

profiling_log "prompt loaded"

# Git autofetch

_git_autofetch() {
    [ -d .git/refs/remotes ] || return

    local NOW="$(date "+%s")"

    if [ "$NOW" -lt "${_IGNORE_AUTOFETCH_UNTIL:-0}" ]; then
        return
    fi

    local FETCH_INTERVAL="$((12 * 3600))"
    local FETCH_DEADLINE="$(($NOW - $FETCH_INTERVAL))"
    [ -f .git/FETCH_HEAD ] && [ "$(stat -c "+%Y" .git/FETCH_HEAD)" -gt "$FETCH_DEADLINE" ] && return
    [ -f .gitautofetch ] && [ "$(cat .gitautofetch)" -gt "$FETCH_DEADLINE" ] && return

    if [ -z "$(ssh-add -l | grep -v 'no identities')" ]; then
        # missing ssh-keys is a global error, add a shell-flag for all directories
        _IGNORE_AUTOFETCH_UNTIL="$(($NOW + 3600))"
        return
    fi

    # log time to avoid repeated fetches on failure, abort if we are not allowed to touch the file
    (echo "$NOW" > .gitautofetch) 2> /dev/null || return

    git fetch &
}

# disabled
# add-zsh-hook precmd _git_autofetch

if which direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

_match_alias() {
    local last_command="$1"
    while read alias_line; do
        if [[ "$last_command" == "${alias_line/*=}"* ]]; then
            echo "$alias_line"
        fi
    done
}

_alias_remind() {
    local last_command="$(fc -l -nIL -1 -1 2> /dev/null)"
    local found_aliases="$(alias | sed "s/'//g" | _match_alias "$last_command")"

    if [ -n "$found_aliases" ]; then
        echo "There is an alias for that:"
        echo "$found_aliases"
    fi
}

add-zsh-hook precmd _alias_remind

profiling_log "functions loaded"

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

# edit command in editor with v key
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Toggle vim with Ctrl-Z
# Should be after bindkey -v
foreground-vim() {
    fg %vim
}
zle -N foreground-vim
bindkey '^Z' foreground-vim

# jump one word forward in a quick and easy way
bindkey '^V' forward-word

profiling_log "settings loaded"

# Completition

function fix-comp() {
    rm $HOME/.zcompdump
    rc
}

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
profiling_log "completition settings loaded"

# custom completion
for d in ~/.zsh/completion ~/.zsh_completion; do
    if [[ -d "$d" ]]; then
        fpath=($d $fpath)
        autoload -U "$d"/*(:t)
    fi
done
profiling_log "custom completition loaded"

autoload -Uz compinit

comp_flags=()
if [[ "$(uname -s)" == "Darwin" ]]; then
    # skip single-user security checks to allow for multi user homebrew
    comp_flags+="-u"
fi
if [[ -z ${ZSH_SKIP_COMP_RELOAD} ]]; then
    comp_flags+="-C"
else
    # skip loading comp again, since this is very slow for some reason
    ZSH_SKIP_COMP_RELOAD=1
fi
compinit $comp_flags
profiling_log "completition loaded"

# fasd should be setup after compinit
fasd_setup
profiling_log "fasd loaded"

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
profiling_log "fzf and extensions loaded"

# Settings

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY       # append history incrementally as commands are entered
setopt sharehistory             # update history from other shells shile running

## mostly from ofb.net zshtricks

setopt nobeep                   # i hate beeps
setopt autocd                   # change to dirs without cd
setopt autopushd                # automatically append dirs to the push/pop list
setopt pushdsilent
setopt pushdignoredups          # and do not duplicate them
#setopt nocheckjobs             # don't warn me about bg processes when exiting
#setopt nohup                   # and don't kill them, either
setopt listpacked               # compact completion lists
setopt listtypes                # show types in completion
setopt extendedglob             # weird & wacky pattern matching - yay zsh!
setopt nocaseglob
setopt numericglobsort
setopt nopromptcr               # do not add \r which overwrites cmd output with no \n
setopt histverify               # when using ! cmds, confirm first
setopt interactivecomments      # escape commands so i can use them later
setopt recexact                 # recognise exact, ambiguous matches
setopt histignorespace          # commands starting with space are not remembered
setopt histignorealldups        # removes duplicate commands, even if non-sequential, useful for percol search

export REPORTTIME=10 # print stats for commands running longer than 10 secs
profiling_log "settings loaded"

# Overriding configs goes in .zshrc_local
source_if_exists ~/.zshrc_local
profiling_log "local conf loaded"
source_if_exists ~/.zshrc_cygwin
source_if_exists ~/.zshrc_mac
profiling_log "platform conf loaded"

profiling_log "done!"

test $profiling_level -gt 1 && zprof || true
