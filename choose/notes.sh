#!/usr/bin/env bash

folder="$HOME/Desktop/Notes"
term="Ghostty"

if ([[ -z $TMUX ]] && [[ -z $tmux_pid ]]) || ! tmux has-session -t notes 2>/dev/null; then
    tmux new-session -ds notes -c $folder
fi

if [[ -z $TMUX ]]; then
    tmuxStatus="tmux switch-client -t notes"
else
    tmuxStatus="tmux attach-session -t notes"
fi

# yabai -m window --resize right:$((275 - $(yabai -m query --windows --window | jq '.frame.w'))):0

opennote() {
osascript <<EOF
    delay 1

    on is_running(appName)
    	tell application "System Events" to (name of processes) contains appName
    end is_running

    if not is_running("$term") then
    	tell application "$term" to activate
    else
    	tell application "System Events" to tell process "$term"
    		click menu item "New Window" of menu 1 of menu bar item "File" of menu bar 1
    	end tell
    end if

    delay 0.2

    tell application "System Events"
        keystroke "yabai -m window --warp west"
        key code 36 -- press return
    end tell

    delay 0.2

    tell application "System Events"
        keystroke "$tmuxStatus"
        key code 36 -- press return
    end tell

    delay 0.2

    tell application "System Events"
        keystroke "NVIM_APPNAME=nvim_md nvim $folder/$1"
        key code 36 -- press return
    end tell
EOF
}

    # tell application "System Events"
    #     keystroke "vim $folder/$1"
    #     key code 36 -- press return
    # end tell

newnote() {
    name="$(echo "-" | choose -f 'JetBrainsMono Nerd Font' -b '31748f' -c 'eb6f92' -p 'Enter a name: ' -m)" || exit 0

    if [ "$name" = "-" ]; then
        name="$(date +%F_%T | tr ':' '-')"
    fi

    name="${name}.md"
    opennote "$name"
}

selected() {
    options="New"$'\n'"$(ls -1t "$folder")"
    choice=$(printf "%s" "$options" | choose -f 'JetBrainsMono Nerd Font' -b '31748f' -c 'eb6f92' -p 'Choose note or create new: ')
    case "$choice" in
        New)
            newnote ;;
        *.md)
            opennote "$choice";;
        *)
            exit ;;
    esac
}

selected
