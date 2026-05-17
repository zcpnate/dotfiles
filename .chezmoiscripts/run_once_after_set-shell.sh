#!/usr/bin/env bash

# Set zsh as the default shell using chsh if available
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" $USER
    echo "zsh set as default shell."
else
    echo "zsh is already the default shell."
fi