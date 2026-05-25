# Personal aliases. Sourced from .zshrc AFTER oh-my-zsh.sh so these win over any
# plugin-provided aliases.
alias pip=pip3
alias tf=tofu                  # this machine uses OpenTofu; no terraform binary
alias terraform=tofu           # muscle-memory / interactive only (not seen by scripts)
alias zedit="$EDITOR $ZDOTDIR/.zshrc"
alias meld='meld_script(){ /Applications/Meld.app/Contents/MacOS/Meld $* 2>/dev/null & };meld_script'
