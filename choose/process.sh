#!/usr/bin/env bash

choice=$(printf "kill\nsleep\nreboot\nshutdown" | choose -f "JetBrainsMono Nerd Font" -b "31748f" -c "eb6f92" -p "Select action:" -n 5)

case "$choice" in
  kill)
    ps -u "$USER" -o pid=,%cpu=,%mem=,args= | \
      sort -k2 -nr | \
      awk '{pid=$1; cpu=$2; mem=$3; $1=$2=$3=""; printf "%-8s %-6s %-6s %s\n", pid, cpu, mem, $0}' | \
      choose -f "JetBrainsMono Nerd Font" -b "31748f" -c "eb6f92" -p "Kill process:" -w 35 -n 20 | \
      awk '{print $1}' | \
      xargs -r kill
    ;;
  sleep)
    osascript -e 'tell application "System Events" to sleep'
    ;;
  reboot)
    confirm=$(printf "Cancel\nReboot" | \
      choose -f "JetBrainsMono Nerd Font" -b "31748f" -c "eb6f92" -p "Are you sure?" -n 3)
    [ "$confirm" = "Reboot" ] && osascript -e 'tell application "System Events" to restart'
    ;;
  shutdown)
    confirm=$(printf "Cancel\nShut Down" | \
      choose -f "JetBrainsMono Nerd Font" -b "31748f" -c "eb6f92" -p "Are you sure?" -n 3)
    [ "$confirm" = "Shut Down" ] && osascript -e 'tell application "System Events" to shut down'
    ;;
  *)
    exit 1
    ;;
esac
