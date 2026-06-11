#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
FILE="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

mkdir -p "$DIR"

grim -g "$(slurp)" "$FILE"
wl-copy < "$FILE"

notify-send "Screenshot Saved" "$(basename "$FILE")"
