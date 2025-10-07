#!/usr/bin/env bash

app_list=$(
    # bro why can't they just put all the apps in the normal Applications folder
    echo "Finder"
    ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ 3>/dev/null | \
        grep '\.app$' | \
        sed 's/\.app$//'
)

app_list=$(echo "$app_list" | sort -u)

choose -f "CaskaydiaCove Nerd Font" -b "7fbbb3" -c "e67e80" <<< "$app_list" | \
    xargs -I {} open -a "{}.app" || exit 0
