#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# If running os MacOS, make sure to use GNU utils and not BSD (brew install coreutils moreutils)
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias xargs="gxargs"
    alias sed="gsed"
fi

toc_content() {
    for file in *.md; do
        name="$(echo $file | sed 's/[.]md//')"
        echo "* [$name]($file)"
    done
}

toc_content
toc_content | between "<!--TOC START-->" "<!--TOC END-->" README.md

# TODO this could requrse in all subdirs if we add them
