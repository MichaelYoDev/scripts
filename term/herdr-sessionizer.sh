#!/usr/bin/env bash

DIRS=(
    "$HOME/.config"
    "$HOME/personal-site"
    "$HOME/Desktop/code"
    "$HOME/Desktop/notes"
    "$HOME/Desktop/website"
)

if [[ $# -eq 1 ]]; then
    path=$1
else
    my_find() {
        echo "home"
        for path in "${DIRS[@]}"; do
            find "$path" -mindepth 0 -maxdepth 1 -type d -not -path "$path/.git"
        done | sed "s|^$HOME/||"
    }
    selected=$(my_find | fzf --height 50% --no-color)

    if [[ -n $selected ]]; then
        path="$HOME/$selected"
    fi
fi

if [[ -z $path ]]; then
    exit 0
fi

existing=$(herdr pane list 2>/dev/null | jq -r --arg cwd "$path" '.result.panes[] | select(.cwd == $cwd) | .workspace_id' | head -1)

if [[ -n $existing ]]; then
    herdr workspace focus "$existing"
else
    herdr workspace create --cwd "$path" --label "$(basename "$path")" --focus
fi
