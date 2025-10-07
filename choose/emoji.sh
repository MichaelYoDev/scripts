#!/usr/bin/env bash

export LANG=en_US.UTF-8
emojis="$HOME/.config/scripts/stuff/emoji"

selection=$(
    cat "$emojis" | \
    choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" | \
    sed "s/ .*//"
)

[[ -z "$selection" ]] && exit 1

printf "%s" "$selection" | pbcopy

osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
