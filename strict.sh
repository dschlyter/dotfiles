#!/bin/bash
# Strict base for bash, copy as base of script or source ~/.dotfiles/strict.sh (if appropriate)

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Trap and print errors even in functions
set -o errtrace
trap 'err_handler $?' ERR
err_handler() {
  trap - ERR
  let i=0 exit_status=$1
  echo "Aborting on error $exit_status:"
  while caller $i; do ((i++)); done
  exit $exit_status
}
