#!/bin/bash
# Renumber numbered sessions (N-name) to fill gaps and zero-pad when >= 10 sessions.
# Usage: order-sessions.sh [next|prev]   - optionally swap current session with neighbour first
# Non-numbered sessions (e.g. chirp) are left untouched.

DIRECTION="$1"
CURRENT=$(tmux display-message -p '#{session_id}')

# Sorted numbered sessions as parallel arrays of ids and name suffixes
IDS=()
SUFFIXES=()
while read -r num id name; do
    IDS+=("$id")
    SUFFIXES+=("${name#"$num"}")
    [ ${#IDS[@]} -eq 1 ] && START=$((10#$num))
done < <(tmux list-sessions -F '#{session_id} #S' \
    | awk '{ id=$1; name=substr($0, length($1)+2); if (match(name, /^[0-9]+(-|$)/)) { n=name; sub(/-.*/, "", n); print n, id, name } }' \
    | sort -n -k1,1)

COUNT=${#IDS[@]}
[ "$COUNT" -eq 0 ] && exit 0

# Swap current session with its neighbour
if [ -n "$DIRECTION" ]; then
    for i in "${!IDS[@]}"; do
        [ "${IDS[$i]}" = "$CURRENT" ] && POS=$i
    done
    [ -z "$POS" ] && exit 0
    [ "$DIRECTION" = next ] && OTHER=$((POS + 1)) || OTHER=$((POS - 1))
    if [ "$OTHER" -ge 0 ] && [ "$OTHER" -lt "$COUNT" ]; then
        tmp=${IDS[$POS]};      IDS[$POS]=${IDS[$OTHER]};           IDS[$OTHER]=$tmp
        tmp=${SUFFIXES[$POS]}; SUFFIXES[$POS]=${SUFFIXES[$OTHER]}; SUFFIXES[$OTHER]=$tmp
    fi
fi

LAST=$((START + COUNT - 1))
WIDTH=${#LAST}

# Two passes via temp names to avoid collisions (e.g. swapping "0" and "1")
for i in "${!IDS[@]}"; do
    tmux rename-session -t "${IDS[$i]}" "__reorder_$i"
done
for i in "${!IDS[@]}"; do
    tmux rename-session -t "${IDS[$i]}" "$(printf "%0${WIDTH}d" $((START + i)))${SUFFIXES[$i]}"
done
