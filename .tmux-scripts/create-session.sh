#!/bin/bash

NAME="$1"

# Find the highest numbered session index, ignoring non-numeric sessions (e.g. chirp)
LAST=$(tmux list-sessions -F '#S' | grep -E '^[0-9]+(-|$)' | sed 's/-.*//' | sort -n | tail -1)
LAST=${LAST:-0}

NEXT=$((LAST + 1))

if [ -n "$NAME" ]; then
    SESSION="$NEXT-$NAME"
else
    SESSION="$NEXT"
fi

tmux new-session -d -s "$SESSION" && tmux switch-client -t "$SESSION"
