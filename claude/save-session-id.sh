#!/bin/bash
# SessionStart hook: saves session_id keyed by tmux pane for cross-pane session forking
# Usage: claude --resume $(cat /tmp/claude-sessions/%42) --fork-session
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TMUX_PANE=$(tmux display-message -p '#{pane_id}' 2>/dev/null || echo "unknown")

if [ -n "$SESSION_ID" ] && [ "$TMUX_PANE" != "unknown" ]; then
    mkdir -p /tmp/claude-sessions
    echo "$SESSION_ID" > "/tmp/claude-sessions/${TMUX_PANE}"
fi
