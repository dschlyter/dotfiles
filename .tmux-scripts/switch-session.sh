#!/bin/bash
# Switch session with false activity prevention
# Usage: switch-session.sh next|prev

# ~/.tmux-scripts/prevent-false-activity.sh

case "$1" in
    next) tmux switch-client -n ;;
    prev) tmux switch-client -p ;;
    *)    tmux switch-client -n ;;
esac
