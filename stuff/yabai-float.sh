#!/usr/bin/env bash

# Get the focused display object
focused_display=$(yabai -m query --displays | jq '.[] | select(."has-focus" == true)')
width=$(echo "$focused_display" | jq '.frame.w')
height=$(echo "$focused_display" | jq '.frame.h')

# Get number of windows in the currently focused space
window_count=$(yabai -m query --windows --space | jq 'length')

# Always toggle float
yabai -m window --toggle float

# Resize if only 1 window & not built-in display
if [ "$window_count" -eq 1 ] && ! { [ "$width" -eq 1470 ] && [ "$height" -eq 956 ]; }; then
  yabai -m window --resize left:750:0
  yabai -m window --resize right:-750:0
fi
