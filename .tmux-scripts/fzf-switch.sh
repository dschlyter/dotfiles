#!/bin/bash
# Fast fzf switcher for tmux windows across all sessions
current=$(tmux display-message -p '#{session_name}:#{window_index}')

tmux list-windows -aF '#{session_name}:#{window_index} #{window_name} #{pane_current_command} #{pane_current_path}' \
    | grep -v "^${current} " \
    | fzf --reverse --no-sort \
    | cut -d' ' -f1 \
    | xargs -r tmux switch-client -t
