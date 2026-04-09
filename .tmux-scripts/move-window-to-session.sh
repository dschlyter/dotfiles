#!/bin/bash
# ~/.tmux-scripts/prevent-false-activity.sh

# Move current window to target session, switching first to avoid detach on last window
TARGET="$1"
SRC=$(tmux display-message -p '#S:#I')
tmux switch-client -t "$TARGET"
tmux move-window -a -s "$SRC"
