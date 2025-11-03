#!/bin/bash

CONTAINER_CMD="docker"
if command -v podman; then
    CONTAINER_CMD="podman"
fi

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

"$CONTAINER_CMD" build -t devplay .
