#!/bin/bash
# Toggle jump to first session / window 1.
# If already at target, jump back to where we came from (session:window).

state=/tmp/tmux-jump-first.$USER
first=$(tmux list-sessions -F "#S" | sort | head -1)
target="$first:1"
current=$(tmux display-message -p "#S:#I")

if [ "$current" = "$target" ] && [ -s "$state" ]; then
    prev=$(cat "$state")
    rm -f "$state"
    tmux switch-client -t "$prev"
else
    echo "$current" > "$state"
    tmux switch-client -t "$target"
fi
