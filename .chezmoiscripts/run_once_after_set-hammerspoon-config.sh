#!/bin/bash
set -euo pipefail

# Point Hammerspoon at the XDG-style config location.
# See: https://github.com/Hammerspoon/hammerspoon/issues/2175
target="$HOME/.config/hammerspoon/init.lua"

current=$(defaults read org.hammerspoon.Hammerspoon MJConfigFile 2>/dev/null || true)
if [ "$current" = "$target" ]; then
    exit 0
fi

defaults write org.hammerspoon.Hammerspoon MJConfigFile "$target"
echo "Set Hammerspoon MJConfigFile -> $target"
echo "Quit and relaunch Hammerspoon for the new config path to take effect."
