sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nateships

## Slack token

First `chezmoi apply` on a machine prompts for the token and stores it in the OS keyring (macOS Keychain).
Rotate later with:
```
chezmoi secret keyring set --service=slack_status --user=token
```
