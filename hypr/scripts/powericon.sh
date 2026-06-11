#!/bin/bash

PROFILE=$(gdbus call \
  --system \
  --dest net.hadess.PowerProfiles \
  --object-path /net/hadess/PowerProfiles \
  --method org.freedesktop.DBus.Properties.Get \
  net.hadess.PowerProfiles ActiveProfile |
  grep -oE "'[^']+'" | tr -d "'")

case "$PROFILE" in
    performance)
        ICON=""
        ;;
    balanced)
        ICON="󰶘"
        ;;
    power-saver)
        ICON=""
        ;;
esac

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$ICON" "$PROFILE" "$PROFILE"
