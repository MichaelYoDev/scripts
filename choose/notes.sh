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
        sleep 1 # let the root shell reach its prompt
    fi
    # Tidy: drop any auto-created default workspace so only "notes" remains.
    for w in $(herdr --session "$session" workspace list 2>/dev/null | jq -r '.result.workspaces[].workspace_id'); do
        [ "$w" != "$ws" ] && herdr --session "$session" workspace close "$w" >/dev/null 2>&1
    done
    # The workspace's dedicated nvim pane (first pane). A fresh server restore can
    # lag behind the workspace listing, so retry until the pane actually shows up.
    pane=""
    for i in 1 2 3; do
        pane=$(herdr --session "$session" pane list --workspace "$ws" 2>/dev/null | jq -r '.result.panes[0].pane_id // empty')
        [ -n "$pane" ] && break
        sleep 1
    done
    if [ -z "$pane" ]; then
        # workspace exists but has no pane yet: force a root pane via a new tab
        herdr --session "$session" tab create --workspace "$ws" --cwd "$folder" >/dev/null 2>&1
        sleep 1
        pane=$(herdr --session "$session" pane list --workspace "$ws" 2>/dev/null | jq -r '.result.panes[0].pane_id // empty')
    fi
}

opennote() {
    local file="$1"
    [ -z "$pane" ] && ensure_workspace
    [ -z "$pane" ] && return 1
    local nvim_running
    nvim_running=$(herdr --session "$session" pane process-info --pane "$pane" 2>/dev/null | jq -r '.result.process_info.foreground_processes[0].name // empty')
    if [ "$nvim_running" = "nvim" ]; then
        # nvim already running: load the file as a buffer (:e keeps old buffers reachable)
        herdr --session "$session" pane send-keys "$pane" esc
        herdr --session "$session" pane send-text "$pane" ":e $file"
        herdr --session "$session" pane send-keys "$pane" enter
    else
        # first open: launch nvim in the pane
        for i in 1 2 3; do
            herdr --session "$session" pane run "$pane" "NVIM_APPNAME=nvim_md nvim '$file'" && break
            sleep 1
        done
    fi
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
    # Ask which folder to create the note in
    target=$(printf "notes\ncompsci" | choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -p 'Create note in:') || exit 0

    name="$(echo "-" | choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" -p 'Enter a name: ' -m)" || exit 0
    if [ "$name" = "-" ]; then
        name="$(date +%F_%T | tr ':' '-')"
    fi
    name="${name}.md"

    if [ "$target" = "compsci" ]; then
        # Ensure the compsci directory exists
        mkdir -p "$compsci"
        opennote "compsci/$name"
    else
        opennote "$name"
    fi
}

selected() {
    options="new"$'\n'"$(ls -1t "$folder" 2>/dev/null)"$'\n'"$(ls -1t "$compsci" 2>/dev/null | sed 's|^|compsci/|')"
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
