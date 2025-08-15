#!/usr/bin/env bash

SEARCH_PATHS=(
    "$HOME/.config"
    "$HOME/Desktop/code"
    "$HOME/Desktop/Notes"
)

if [[ $# -eq 1 ]]; then
    path=$1
else
    my_find() {
        echo "home"
        for path in "${SEARCH_PATHS[@]}"; do
            find "$path" -mindepth 0 -maxdepth 2 -type d -not -path "$path/.git"
        done | sed "s|^$HOME/||"
    }
    selected=$(my_find | fzf --tmux 50%,50% --no-color)

    if [[ -n $selected ]]; then
        path="$HOME/$selected"
    fi
fi

if [[ -z $path ]]; then
    exit 0
fi

selected_name=$(basename "$path" | tr -s ".[:blank:]" "_" | tr "[:upper:]" "[:lower:]")

tmux_pid=$(pgrep tmux)

if ([[ -z $TMUX ]] && [[ -z $tmux_pid ]]) || ! tmux has-session -t "$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$path"
fi

if [[ -z $TMUX ]]; then
    tmux attach-session -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
