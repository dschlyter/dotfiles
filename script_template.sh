#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

usage() {
    echo "Usage: TODO"
}

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
