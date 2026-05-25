---
name: wname
description: Name your session
---

Rename the tmux window you are running in to categorize the session and distinguish it from other windows.

IMPORTANT: Use `$TMUX_PANE` to target the window Claude Code is actually running in, not the currently focused window. The `-t "$TMUX_PANE"` flag ensures you target the correct window.

First check the context of what the current session and other windows are named:

    tmux display-message -t "$TMUX_PANE" -p '#{session_name} #{window_name}' && tmux list-windows -F '#{window_index}: #{window_name}'

Then figure out a name for yourself that is precise, concise, fits with existing names but also stands out against them. The name should not semantically overlap the session name - the session name provides the context and overall scope for the session, the window name explains which sub problem within the session you are solving.

Use kebab-case for names. A good guideline is two words like `test-impl` or `data-validation` (but more precise if possible).

Rename with:

    tmux rename-window -t "$TMUX_PANE" '<name>'