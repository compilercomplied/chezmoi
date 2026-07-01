#!/bin/bash

# Source colors
source "$HOME/.config/sketchybar/colors.sh"

# Fetch volume and mute state
VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [ "$MUTED" = "true" ]; then
  ICON="󰝟"
  VOLUME=0
  COLOR=$GREY
else
  COLOR=$COLOR_VOLUME
  case $VOLUME in
    [6-9][0-9]|100) ICON="󰕾" ;;
    [3-5][0-9]) ICON="󰖀" ;;
    [1-2][0-9]|[1-9]) ICON="󰕿" ;;
    *) ICON="󰝟"
  esac
fi

sketchybar --set $NAME icon="$ICON" label="$VOLUME%" icon.color=$COLOR
