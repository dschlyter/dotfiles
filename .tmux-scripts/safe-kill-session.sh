#!/bin/bash

# Kill current session only if it has exactly one window and one pane
SESSION=$(tmux display-message -p '#S')
WINDOWS=$(tmux list-windows -t "$SESSION" | wc -l | tr -d ' ')
PANES=$(tmux list-panes -t "$SESSION" | wc -l | tr -d ' ')

if [ "$WINDOWS" -ne 1 ] || [ "$PANES" -ne 1 ]; then
    tmux display-message "Session has $WINDOWS windows and $PANES panes, not killing"
    exit 0
fi

tmux switch-client -p
tmux kill-session -t "$SESSION"
