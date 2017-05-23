#!/bin/bash

# selects the next/prev pane, or forwards keystroke to inner nested tmux if the current one has no panes
# usecase: usually you either have panes inside the top-level, or the nested tmux. this allows control of both with the same hotkey

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

arg="${1:-next}"

if [ "$(tmux list-panes | wc -l)" -gt 1 ]; then
    if [ "$arg" = "next" ]; then
        tmux select-pane -t ":.+"
    elif [ "$arg" = "prev" ]; then
        tmux select-pane -t ":.-"
    fi
else
    if [ "$arg" = "next" ]; then
        tmux send-keys M-j
    elif [ "$arg" = "prev" ]; then
        tmux send-keys M-k
    fi
fi
