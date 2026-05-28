#!/bin/bash
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/slack_status/config"

# Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    . "$CONFIG_FILE"
else
    echo "${red}No configuration file found at $CONFIG_FILE${reset}"
    echo "Run ${green}chezmoi apply${reset} to generate it from the chezmoi source."
    exit 1
fi

PRESET="$1"
shift
ADDITIONAL_TEXT="$*"

if [[ -z $PRESET ]]; then
    echo "Usage: $0 PRESET [ADDITIONAL TEXT]"
    echo
    echo "Set your slack status based on preconfigured presets"
    echo ""
    echo "If you provide additional text, then it will be appended to the"
    echo "preset status."
    echo
    echo "Presets are defined in ${green}$CONFIG_FILE${reset}"
    echo
    echo "Run '${green}$0 setup${reset}' to create a new configuration file"
    exit 1
fi

if [[ $PRESET == "none" ]]; then
    EMOJI=""
    TEXT=""
    echo "Resetting slack status to blank"
else
    eval "EMOJI=\$PRESET_EMOJI_$PRESET"
    eval "TEXT=\$PRESET_TEXT_$PRESET"

    if [[ -z $EMOJI || -z $TEXT ]]; then
        echo "${yellow}No preset found:${reset} $PRESET"
        echo
        echo "If this wasn't a typo, then you will want to add the preset to"
        echo "the config file at ${green}$CONFIG_FILE${reset} and try again."
        exit 1
    fi

    if [[ -n "$ADDITIONAL_TEXT" ]]; then
        TEXT="$TEXT $ADDITIONAL_TEXT"
    fi

    echo "Updating status to: ${yellow}$EMOJI ${green}$TEXT${reset}"
fi

PROFILE="{\"status_emoji\":\"$EMOJI\",\"status_text\":\"$TEXT\"}"
RESPONSE=$(curl -s --data token="$TOKEN" \
    --data-urlencode profile="$PROFILE" \
    https://slack.com/api/users.profile.set)
if echo "$RESPONSE" | grep -q '"ok":true,'; then
    echo "${green}Status updated ok${reset}"
else
    echo "${red}There was a problem updating the status${reset}"
    echo "Response: $RESPONSE"
fi
