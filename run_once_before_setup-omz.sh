#!/usr/bin/env bash

export ZDOTDIR=~/.config/zsh
export ZSH="$ZDOTDIR/.oh-my-zsh"

if [ ! -d "$ZSH" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "ZSH directory already exists."
fi

[ -f ~/.zshrc ] && rm ~/.zshrc

[[ -f ~/.zshenv ]] && mv -f ~/.zshenv ~/.zshenv.bak
ln -s $ZDOTDIR/.zshenv ~/.zshenv