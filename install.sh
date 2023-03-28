#!/usr/bin/env bash

set -e

DOTROOT="${DOTROOT:-"$HOME"/.dot}"

# Check/Create LINK
function clink() {
    local path="$1"
    local hpath="$HOME"/"$path"
    local dpath="$DOTROOT"/"$path"

    if [[ -L "$hpath" ]]; then
        local linkpath="$(readlink -n "$hpath")"
        if [[ "$linkpath" = "$dpath" ]]; then
            echo "$hpath -> $dpath ✓"
        else
            echo "$hpath -> $linkpath ✗" 1>&2
            echo "should be $dpath"
            exit 1
        fi
    elif [[ -e "$hpath" ]]; then
        echo "$hpath exists in the filesystem" 1>&2
        exit 1
    else
        ln -sv "$DOTROOT"/"$path" "$HOME"/"$path"
    fi
}

clink .config/nvim
