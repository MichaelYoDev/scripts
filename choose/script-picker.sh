#!/usr/bin/env bash

selection=$(
  ls "$HOME/.config/scripts/choose" |
    sed 's/\.[^.]*$//' |
    choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80"
)

if [[ -n "$selection" ]]; then
  "$HOME/.config/scripts/choose/${selection}.sh"
fi
