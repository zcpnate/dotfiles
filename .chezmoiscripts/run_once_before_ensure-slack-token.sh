#!/bin/bash
set -euo pipefail

# During `chezmoi init --apply` on a fresh machine, chezmoi runs from a temp
# bootstrap dir that is not on PATH (and the brew formula isn't installed yet),
# so a bare `chezmoi` fails with "command not found". chezmoi exports its own
# path as $CHEZMOI_EXECUTABLE for scripts; fall back to PATH lookup otherwise.
chezmoi="${CHEZMOI_EXECUTABLE:-chezmoi}"

if "$chezmoi" secret keyring get --service=slack_status --user=token >/dev/null 2>&1; then
    exit 0
fi

echo "Slack API token for ~/.config/slack_status/config"
echo "Leave blank to skip (e.g. no token from admin yet). Set it later with:"
echo "  chezmoi secret keyring set --service=slack_status --user=token"
printf 'Token: '
read -rs token
echo

if [ -z "$token" ]; then
    echo "Skipped — Slack status stays inert until a token is set."
    exit 0
fi

"$chezmoi" secret keyring set --service=slack_status --user=token --value "$token"
