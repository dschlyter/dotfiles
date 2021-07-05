#!/bin/bash

usage() {
    echo "TODO describe script"
    echo "Usage: $0 arg1 arg2 TODO"
}

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# If running os MacOS, make sure to use GNU utils and not BSD (brew install coreutils moreutils)
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias xargs="gxargs"
    alias sed="gsed"
fi

while getopts ":hp:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        p)
            echo "Argument to -p: $OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "${1:-}" ]]; then
    usage
    exit 0
fi


