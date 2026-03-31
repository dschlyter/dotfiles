#!/bin/bash
# Claude Code statusline script. Add to ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/.claude/claude-statusline.sh" }
input=$(cat)

current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "."')
dir_name=$(basename "$current_dir")
branch=$(git -C "$current_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
api_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

RST=$'\e[0m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
GREEN=$'\e[32m'
DIM_GREEN=$'\e[2;32m'
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
if [ -n "$rate_5h" ] && [ -n "$rate_7d" ]; then
    rate_5h_int=$(printf '%.0f' "$rate_5h")
    rate_7d_int=$(printf '%.0f' "$rate_7d")
    cost_str=" ${GRAY}${rate_5h_int}% ${rate_7d_int}%${RST}"
elif [ -n "$cost" ]; then
    cost_rounded=$(printf '%.2f' "$cost")
    cost_str=" ${GRAY}\$${cost_rounded}${RST}"
fi

time_str=""
if [ -n "$duration_ms" ]; then
    dur_s=$(( duration_ms / 1000 ))
    dur_h=$(( dur_s / 3600 ))
    dur_m=$(( (dur_s % 3600) / 60 ))
    dur_s_rem=$(( dur_s % 60 ))
    if [ "$dur_h" -ge 24 ]; then
        dur_d=$(( dur_h / 24 ))
        dur_h=$(( dur_h % 24 ))
        dur_fmt=$(printf "%dd %02d:%02d:%02d" "$dur_d" "$dur_h" "$dur_m" "$dur_s_rem")
    else
        dur_fmt=$(printf "%d:%02d:%02d" "$dur_h" "$dur_m" "$dur_s_rem")
    fi
    api_s=$(( api_ms / 1000 ))
    api_h=$(( api_s / 3600 ))
    api_m=$(( (api_s % 3600) / 60 ))
    api_s_rem=$(( api_s % 60 ))
    if [ "$api_h" -ge 24 ]; then
        api_d=$(( api_h / 24 ))
        api_h=$(( api_h % 24 ))
        api_fmt=$(printf "%dd %02d:%02d:%02d" "$api_d" "$api_h" "$api_m" "$api_s_rem")
    else
        api_fmt=$(printf "%d:%02d:%02d" "$api_h" "$api_m" "$api_s_rem")
    fi
    time_str=" ${GRAY}${dur_fmt} (api ${api_fmt})${RST}"
fi

lines_str=""
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
    lines_str=" ${GREEN}+${lines_added:-0}${RST}/${RED}-${lines_removed:-0}${RST}"
fi

parts="${MAGENTA}${model}${RST} ${ctx}${lines_str}${time_str}${cost_str}"
if [ -n "$branch" ]; then
    parts="${BLUE}${branch}${RST} | ${parts}"
fi
parts="${GREEN}${dir_name}${RST} | ${parts}"
echo "$parts"
