#!/usr/bin/env bash

# Get width and height of the currently focused display
focused_display=$(yabai -m query --displays | jq 'map(select(.has-focus == true))[0]')
width=$(echo "$focused_display" | jq '.frame.w')
height=$(echo "$focused_display" | jq '.frame.h')

# Get number of windows in the currently focused space
window_count=$(yabai -m query --windows --space | jq 'length')

# Always toggle float
yabai -m window --toggle float

# If only 1 window is in the space and it's an external display, resize
if [ "$window_count" -eq 1 ] && ! { [ "$width" -eq 1470 ] && [ "$height" -eq 956 ]; }; then
  yabai -m window --resize left:750:0
  yabai -m window --resize right:-750:0
fi
