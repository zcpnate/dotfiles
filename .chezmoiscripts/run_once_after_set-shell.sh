#!/usr/bin/env bash

# Set zsh as the login shell. Compare against the recorded account shell (dscl),
# not $SHELL — $SHELL is the shell that launched this script, not the default.
# chsh only accepts shells listed in /etc/shells.
zsh_path="$(command -v zsh)"
current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"

if [ -z "$zsh_path" ]; then
    echo "zsh not found on PATH; skipping shell change."
elif [ "$current_shell" = "$zsh_path" ]; then
    echo "zsh is already the default shell."
else
    grep -qxF "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    sudo chsh -s "$zsh_path" "$USER"
    echo "zsh set as default shell."
fi