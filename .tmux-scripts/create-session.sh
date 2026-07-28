#!/bin/bash

NAME="$1"

LAST=$(tmux list-sessions -F '#S' | sort | tail -1)

for i in $(seq 1 9); do
    if [ -z "$LAST" ] || [[ "$i" > "$LAST" ]]; then
        if [ -n "$NAME" ]; then
            SESSION="$i-$NAME"
        else
            SESSION="$i"
        fi
        tmux new-session -d -s "$SESSION" && tmux switch-client -t "$SESSION"
        exit 0
    fi
done

# Fallback: let tmux pick a name
tmux new-session -d && tmux switch-client -t "$(tmux list-sessions -F '#S' | sort | tail -1)"
