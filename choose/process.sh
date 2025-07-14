#!/usr/bin/env bash

choice=$(printf "kill\nsleep\nreboot\nshutdown" | choose -f "JetBrainsMono Nerd Font" -b "31748f" -c "eb6f92" -p "Select action:")

case "$choice" in
  kill)
    ps -u "$USER" -o pid=,%cpu=,%mem=,args= | \
      sort -k2 -nr | \
      awk '{pid=$1; cpu=$2; mem=$3; $1=$2=$3=""; printf "%-8s %-6s %-6s %s\n", pid, cpu, mem, $0}' | \
      choose -f "JetBrainsMono Nerd Font" -b "31748f" -c "eb6f92" -p "Kill process:" -w 35 | \
      awk '{print $1}' | \
      xargs -r kill
    ;;
  sleep)
    osascript -e 'tell application "System Events" to sleep'
    ;;
  reboot)
    confirm=$(osascript -e 'display dialog "Are you sure you want to reboot?" buttons {"Cancel", "Reboot"} default button "Cancel"')
    if [[ "$confirm" == *"Reboot"* ]]; then
      osascript -e 'tell application "System Events" to restart'
    fi
    ;;
  shutdown)
    confirm=$(osascript -e 'display dialog "Are you sure you want to shut down?" buttons {"Cancel", "Shut Down"} default button "Cancel"')
    if [[ "$confirm" == *"Shut Down"* ]]; then
      osascript -e 'tell application "System Events" to shut down'
    fi
    ;;
  *)
    exit 1
    ;;
esac
