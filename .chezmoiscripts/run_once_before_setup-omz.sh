#!/usr/bin/env bash

export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export ZSH="$ZDOTDIR/.oh-my-zsh"

if [ ! -d "$ZSH" ]; then
    # --keep-zshrc: don't let the installer back up or abort on a .zshrc left
    # by a broken prior run (chezmoi manages .zshrc anyway).
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
    echo "ZSH directory already exists."
fi

# Stray ~/.zshrc is unused (config lives in $ZDOTDIR via ~/.zshenv). -f tolerates
# an absent file, a regular file, or a (possibly dangling) symlink.
rm -f ~/.zshrc

# Back up only a real ~/.zshenv (not a symlink we made — which may be dangling
# until chezmoi writes $ZDOTDIR/.zshenv later this apply), then force-relink.
if [ -e ~/.zshenv ] && [ ! -L ~/.zshenv ]; then
    mv -f ~/.zshenv ~/.zshenv.bak
fi
ln -sfn "$ZDOTDIR/.zshenv" ~/.zshenv