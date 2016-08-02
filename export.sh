#!/bin/bash

set -euo pipefail

export_plist() {
    echo "exporting plist $1"
    cp "$HOME/Library/Preferences/$1" "$1"
    plutil -convert xml1 "$1"
}

case "$(uname -s)" in
    Darwin)
        echo "Detected Mac OSX"
        export_plist com.googlecode.iterm2.plist
        ;;

    CYGWIN*|MINGW32*|MSYS*)
        echo Detected Windows/Cygwin
        ;;

    Linux)
        echo Detected Linux
        ;;

    *)
        echo Unable to detect OS
        ;;
esac
