#!/bin/bash
set -euo pipefail

if chezmoi secret keyring get --service=slack_status --user=token >/dev/null 2>&1; then
    exit 0
fi

echo "Slack API token required for ~/.slack_status.conf"
chezmoi secret keyring set --service=slack_status --user=token
