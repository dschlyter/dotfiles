#!/bin/bash
# Jump to next window with activity alert, prioritizing current session
# Within each group, pick the most recently active window

current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#{window_index}')

# First: activity in current session (excluding current window), most recent first
target=$(tmux list-windows -t "$current_session" \
    -f '#{window_activity_flag}' \
    -F '#{window_activity} #{session_name}:#{window_index}' \
    | grep -v " ${current_session}:${current_window}$" \
    | sort -rn \
    | head -1 \
    | cut -d' ' -f2)

# Then: activity in other sessions, most recent first
if [ -z "$target" ]; then
    target=$(tmux list-windows -a \
        -f '#{window_activity_flag}' \
        -F '#{window_activity} #{session_name}:#{window_index}' \
        | grep -v " ${current_session}:" \
        | sort -rn \
        | head -1 \
        | cut -d' ' -f2)
fi

if [ -n "$target" ]; then
    target_session=$(echo "$target" | cut -d: -f1)
    if [ "$target_session" != "$current_session" ]; then
        ~/.tmux-scripts/prevent-false-activity.sh
    fi
    tmux switch-client -t "$target"
else
    tmux display-message "No windows with activity"
fi
