#!/usr/bin/env bash
# Convert markdown file to PDF in ~/Downloads

input="$1"
[[ -z "$input" || ! -f "$input" ]] && { echo "Usage: $0 <file.md>"; exit 1; }

filename=$(basename "$input" .md)
output="$HOME/Downloads/$filename.pdf"

pandoc "$input" -o "$output" -V geometry:margin=1in &&
  echo "PDF saved to $output" ||
  echo "Conversion failed"
