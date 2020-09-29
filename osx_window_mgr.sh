#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Crude but minimal improvements to OSX Window management - Note applications must be restarted for hotkeys to apply.


# Remove slooooow anomations for changing window position and size
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# TODO this is vaskd, install rectangle instead
# GKEYS="$HOME/Library/Preferences/.GlobalPreferences.plist"
# Init custom key dictionary if not exists
# plutil -insert NSUserKeyEquivalents -json "{}" "$GKEYS" &> /dev/null || true

# Create a hotkey for window zoom (aka maximize window without the fullscreen spaces bullshit)
# plutil -replace NSUserKeyEquivalents.Zoom -string "@^k" "$GKEYS"

# Create hotkeys for moving to window to a different monitor.
# NOTE: These need to be modified per computer. Check out Window menu to get your Monitor names.
# plutil -replace "NSUserKeyEquivalents.Move to Built-in Retina Display" -string "@^7" "$GKEYS"
# plutil -replace "NSUserKeyEquivalents.Move to DELL U2412M" -string "@^8" "$GKEYS"
# plutil -replace "NSUserKeyEquivalents.Move to ROG PG279Q" -string "@^9" "$GKEYS"

# Install Spotify automator services
cp -r osx/Services/* "$HOME/Library/Services/"
# TODO you need to add keyboard shortcuts for these yourself in system preferences - may be possible to automate against /Library/Preferences/pbs.plist
