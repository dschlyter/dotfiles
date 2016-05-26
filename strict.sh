#!/bin/bash
# Strict base for bash, copy as base of script or source ~/.dotfiles/strict.sh (if appropriate)

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Trap and print errors even in functions
set -o errtrace
trap err_exit ERR
function err_exit() {
    err=${1:-$?}
    trap - ERR
    echo "ERROR: '${BASH_COMMAND}' exited with status $err"
    for ((i=0; i<${#FUNCNAME[@]}-1; i++)); do
        echo " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}"
    done
    exit "$err"
}
