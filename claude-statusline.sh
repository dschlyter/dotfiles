#!/bin/bash
# Claude Code statusline script. Add to ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/.claude/claude-statusline.sh" }
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
api_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
branch=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir // "."')" rev-parse --abbrev-ref HEAD 2>/dev/null)

RST=$'\e[0m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
RED=$'\e[31m'
GRAY=$'\e[90m'

# Build context progress bar
BAR_WIDTH=10
if [ -n "$used_pct" ]; then
    used_int=${used_pct%.*}
    filled=$(( used_int * BAR_WIDTH / 100 ))
    empty=$(( BAR_WIDTH - filled ))
    bar=$(printf '%0.s=' $(seq 1 $filled 2>/dev/null))
    spaces=$(printf '%0.s ' $(seq 1 $empty 2>/dev/null))
    if [ "$used_int" -ge 80 ]; then
        color=$RED
    elif [ "$used_int" -ge 50 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi
    ctx="${color}[${bar}${spaces}]${RST} ${used_pct}%"
else
    ctx="[          ] -"
fi

cost_str=""
if [ -n "$cost" ]; then
    cost_rounded=$(printf '%.2f' "$cost")
    cost_str=" ${GRAY}\$${cost_rounded}${RST}"
fi

time_str=""
if [ -n "$duration_ms" ]; then
    dur_s=$(( duration_ms / 1000 ))
    dur_m=$(( dur_s / 60 ))
    dur_s_rem=$(( dur_s % 60 ))
    api_s=$(( api_ms / 1000 ))
    api_m=$(( api_s / 60 ))
    api_s_rem=$(( api_s % 60 ))
    time_str=" ${GRAY}${dur_m}m${dur_s_rem}s (api ${api_m}m${api_s_rem}s)${RST}"
fi

lines_str=""
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
    lines_str=" ${GREEN}+${lines_added:-0}${RST}/${RED}-${lines_removed:-0}${RST}"
fi

parts="${MAGENTA}${model}${RST} ${ctx}${cost_str}${lines_str}${time_str}"
if [ -n "$branch" ]; then
    parts="${BLUE}${branch}${RST} | ${parts}"
fi
echo "$parts"
