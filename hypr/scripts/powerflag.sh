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
        NEXT="balanced"
        ;;
    balanced)
        NEXT="power-saver"
        ;;
    power-saver)
        NEXT="performance"
        ;;
esac

gdbus call \
  --system \
  --dest net.hadess.PowerProfiles \
  --object-path /net/hadess/PowerProfiles \
  --method org.freedesktop.DBus.Properties.Set \
  net.hadess.PowerProfiles \
  ActiveProfile "<'$NEXT'>"

if [ "$NEXT" = "power-saver" ]; then
    echo "source = ~/.config/hypr/powersave.conf" \
        > ~/.config/hypr/powersaveFlag.conf
else
    : > ~/.config/hypr/powersaveFlag.conf
fi

hyprctl reload
