#!/bin/bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ln -sf "$XDG_CONFIG_HOME/tmux/omt/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
