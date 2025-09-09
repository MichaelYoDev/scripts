#!/usr/bin/env bash


rm /var/folders/*/*/*/com.apple.dock.iconcache
killall Dock
osascript -e 'tell app "System Events" to sleep'
