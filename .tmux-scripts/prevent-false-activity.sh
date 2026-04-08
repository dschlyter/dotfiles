#!/bin/bash
# Temporarily disable monitor-activity globally around session switches
# to prevent false activity flags from TUI redraws (SIGWINCH)

EPOCH_FILE=/tmp/tmux-activity-epoch

# Write a new epoch — any older background re-enable will see this and abort
epoch=$RANDOM
echo "$epoch" > "$EPOCH_FILE"

# Turn off globally
tmux set-option -g monitor-activity off

# Background: wait for redraw to settle, then re-enable (if no newer switch happened)
{
    sleep 1
    if [ "$(cat "$EPOCH_FILE" 2>/dev/null)" = "$epoch" ]; then
        tmux set-option -g monitor-activity on
    fi
} &
