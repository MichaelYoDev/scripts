#!/usr/bin/env bash

app_list=$(
    # bro why can't they just put all the apps in the normal Applications folder
    echo "Finder"
    ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ 3>/dev/null | \
        grep '\.app$' | \
        sed 's/\.app$//'
)

app_list=$(echo "$app_list" | sort -u)

choose -f "JetBrainsMono Nerd Font" -b "31748f" -c "eb6f92" <<< "$app_list" | \
    xargs -I {} open -a "{}.app" || exit 0
