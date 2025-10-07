#!/usr/bin/env bash

WALLS="$HOME/Pictures/Wallpapers"

wallpapers=$(find "$WALLS" -type f | sort)

count=$(echo "$wallpapers" | wc -l)

selection=$(
  ls "$WALLS" | \
    sed 's/\.[^.]*$//' | \
    choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -n $count
)

# Exit if nothing was selected
[[ -z "$selection" ]] && exit 1

file_path=$(find "$WALLS" -type f -name "${selection}.*" | head -n 1)

# Exit if no matching file found
[[ -z "$file_path" ]] && { echo "File not found"; exit 1; }

osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"${file_path}\""
