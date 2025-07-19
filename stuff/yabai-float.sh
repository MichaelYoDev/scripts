#!/bin/bash

# Get width and height of the currently focused display
focused_display=$(yabai -m query --displays | jq 'map(select(.has-focus == true))[0]')
width=$(echo "$focused_display" | jq '.frame.w')
height=$(echo "$focused_display" | jq '.frame.h')

# Compare to known built-in display dimensions
if [ "$width" -eq 1470 ] && [ "$height" -eq 956 ]; then
  # It's the built-in display
  yabai -m window --toggle float
else
  # It's an external display
  yabai -m window --toggle float
  yabai -m window --resize left:750:0
  yabai -m window --resize right:-750:0
fi
