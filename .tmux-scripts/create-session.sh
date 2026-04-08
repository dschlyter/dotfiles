#!/bin/bash
~/.tmux-scripts/prevent-false-activity.sh

# Create a new session with the lowest number (1-9) that sorts after all existing sessions
LAST=$(tmux list-sessions -F '#S' | sort | tail -1)

for i in $(seq 1 9); do
    if [ -z "$LAST" ] || [[ "$i" > "$LAST" ]]; then
        tmux new-session -d -s "$i" && tmux switch-client -t "$i"
        exit 0
    fi
done

# Fallback: let tmux pick a name
tmux new-session -d && tmux switch-client -t "$(tmux list-sessions -F '#S' | sort | tail -1)"
