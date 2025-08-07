#!/usr/bin/env bash

focused_display=$(yabai -m query --displays | jq '.[] | select(."has-focus" == true)')
width=$(echo "$focused_display" | jq '.frame.w' | cut -d '.' -f 1)
height=$(echo "$focused_display" | jq '.frame.h' | cut -d '.' -f 1)

window_count=$(yabai -m query --windows --space | jq 'length')

yabai -m window --toggle float

if [ "$window_count" -eq 1 ]; then
  if [ "$width" -ne 1470 ] || [ "$height" -ne 956 ]; then
    yabai -m window --resize left:790:0
    yabai -m window --resize right:-790:0
  fi
fi
