#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    dir="${HERDR_ACTIVE_PANE_CWD:-$PWD}"
    selected=$(find "$dir" ~/Downloads ~/Desktop/School/25-26 -mindepth 1 -maxdepth 2 -name "*.pdf" | \
        sed "s|^$HOME/||" | \
        fzf --height 50% --no-color
    )

    # Add home path back
    if [[ -n "$selected" ]]; then
        selected="$HOME/$selected"
    fi
fi

if [[ -z "$selected" ]]; then
    exit 1
fi

exec zathura "$selected"
