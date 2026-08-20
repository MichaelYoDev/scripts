#!/usr/bin/env bash
folder="$HOME/Desktop/notes"
compsci="$folder/compsci"
term="Ghostty"
session="notes"
if [ "$term" = "kitty" ]; then
    menu='click menu item "New OS Window" of menu 1 of menu bar item "Shell" of menu bar 1'
elif [ "$term" = "Ghostty" ]; then
    menu='click menu item "New Window" of menu 1 of menu bar item "File" of menu bar 1'
fi

# ---------------------------------------------------------------------------
# herdr-native notes launcher (alt-n via skhd).
# Pick/create a note and open it in nvim (nvim_md) inside the persistent
# "notes" herdr session. A new Ghostty window (marker-triggered via .zshrc)
# attaches to the "notes" session, so the normal terminal's default session is
# never switched away from. Toggle the sidebar with prefix+b (default prefix
# is ctrl+b, i.e. ctrl+b then b).
# ---------------------------------------------------------------------------

ensure_session() {
    # Server running? (herdr CLI does not auto-start a session's server.)
    herdr --session "$session" workspace list >/dev/null 2>&1 && return 0
    # First run after a reboot: boot it with a throwaway PTY client. The server
    # keeps running after the client exits, so the window later just attaches.
    ( env -u HERDR_ENV -u HERDR_SOCKET_PATH \
        script -q /dev/null herdr --session "$session" >/dev/null 2>&1 &
        client=$!
        for i in 1 2 3 4 5 6 7 8 9 10; do
            herdr --session "$session" workspace list >/dev/null 2>&1 && {
                kill "$client" 2>/dev/null
                return 0
            }
            sleep 1
        done
        kill "$client" 2>/dev/null
        return 1 )
}

ensure_workspace() {
    # The notes workspace inside the notes session; persists across detaches.
    ws=$(herdr --session "$session" workspace list 2>/dev/null | jq -r '.result.workspaces[] | select(.label == "notes") | .workspace_id' | head -1)
    if [ -z "$ws" ]; then
        ws=$(herdr --session "$session" workspace create --cwd "$folder" --label notes --no-focus | jq -r '.result.workspace.workspace_id')
        sleep 1
    fi
    # Tidy: drop any auto-created default workspace so only "notes" remains.
    for w in $(herdr --session "$session" workspace list 2>/dev/null | jq -r '.result.workspaces[].workspace_id'); do
        [ "$w" != "$ws" ] && herdr --session "$session" workspace close "$w" >/dev/null 2>&1
    done
}

opennote() {
    local file="$1"
    [ -z "$ws" ] && ensure_workspace
    [ -z "$ws" ] && return 1

    local note_name
    if [[ "$file" == compsci/* ]]; then
        # compsci: abbreviate course name (first 3 chars per camelCase word) + section
        local course section
        course=$(echo "$file" | sed 's|compsci/||; s|/[^/]*$||')
        section=$(basename "$file" .md)
        note_name="$(echo "$course" | sed 's/\([A-Z]\)/_\1/g' | tr '_' '\n' | cut -c1-3 | tr -d '\n')/$section"
    else
        note_name=$(basename "$file" .md)
    fi

    # Check if a tab with this note name already exists
    local existing_tab
    existing_tab=$(herdr --session "$session" tab list 2>/dev/null | jq -r --arg label "$note_name" '.result.tabs[] | select(.label == $label) | .tab_id' | head -1)

    if [ -n "$existing_tab" ]; then
        herdr --session "$session" tab focus "$existing_tab" 2>/dev/null
        return 0
    fi

    # Not found — create a new tab, label it with the note name
    local new_tab new_pane
    new_tab=$(herdr --session "$session" tab create --workspace "$ws" --cwd "$folder" --label "$note_name" --no-focus 2>/dev/null | jq -r '.result.tab.tab_id')
    [ -z "$new_tab" ] && return 1

    # Find the root pane inside the new tab
    new_pane=$(herdr --session "$session" pane list --workspace "$ws" 2>/dev/null | jq -r --arg tab "$new_tab" '.result.panes[] | select(.tab_id == $tab) | .pane_id' | head -1)
    [ -z "$new_pane" ] && return 1

    # Launch nvim in the new pane
    for i in 1 2 3; do
        herdr --session "$session" pane run "$new_pane" "NVIM_APPNAME=nvim_md nvim '$file'" && break
        sleep 1
    done

    # Switch to the new tab
    herdr --session "$session" tab focus "$new_tab" 2>/dev/null
}

show_window() {
    # Marker: the new window's .zshrc uses it to attach to the notes session.
    local marker=/tmp/herdr_notes_attach
    : > "$marker"
    ( sleep 3; rm -f "$marker" ) & # cleanup if the shell hook missed it

    # New Ghostty window.
    osascript >/dev/null 2>&1 <<EOF
on is_running(appName)
    tell application "System Events" to (name of processes) contains appName
end is_running
if not is_running("$term") then
    tell application "$term" to activate
else
    tell application "System Events" to tell process "$term"
        $menu
    end tell
end if
EOF
}

newnote() {
    target=$(printf "notes\ncompsci" | choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -p 'Create note in:') || exit 0

    if [ "$target" = "compsci" ]; then
        courses=$(find "$compsci" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null)
        course=$(printf "%s\nnew course" "$courses" | choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -p 'Course:') || exit 0
        if [ "$course" = "new course" ]; then
            course="$(echo "" | choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -p 'Course name: ' -m)" || exit 0
            [ -z "$course" ] && exit 0
        fi
    fi

    name="$(echo "-" | choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -p 'Enter a name: ' -m)" || exit 0
    if [ "$name" = "-" ]; then
        name="$(date +%F_%T | tr ':' '-')"
    fi
    name="${name}.md"

    if [ "$target" = "compsci" ]; then
        mkdir -p "$compsci/$course"
        opennote "compsci/$course/$name"
    else
        opennote "$name"
    fi
}

selected() {
    options="new"$'\n'"$(ls -1t "$folder" 2>/dev/null)"$'\n'"$(find "$compsci" -name "*.md" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | cut -d' ' -f2- | sed "s|^$folder/||")"
    choice=$(printf "%s" "$options" | choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -p 'Choose note or create new: ')
    case "$choice" in
        new)
            newnote ;;
        *.md)
            opennote "$choice";;
        *)
            exit ;;
    esac
}

ensure_session || exit 1
ensure_workspace
selected
show_window
