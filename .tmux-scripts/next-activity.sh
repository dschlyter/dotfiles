#!/bin/bash
# Jump to next window with activity alert, prioritizing current session
current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#{window_index}')

# First: activity in current session (excluding current window)
target=$(tmux list-windows -t "$current_session" \
    -f '#{window_activity_flag}' \
    -F '#{session_name}:#{window_index}' \
    | grep -v "^${current_session}:${current_window}$" \
    | head -1)

# Then: activity in other sessions
if [ -z "$target" ]; then
    target=$(tmux list-windows -a \
        -f '#{window_activity_flag}' \
        -F '#{session_name}:#{window_index}' \
        | grep -v "^${current_session}:" \
        | head -1)
fi

if [ -n "$target" ]; then
    tmux switch-client -t "$target"
else
    tmux display-message "No windows with activity"
fi
