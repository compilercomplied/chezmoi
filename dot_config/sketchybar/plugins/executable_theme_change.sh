#!/bin/bash

# Get current system theme (Dark or Light) using AppleScript
if [ "$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')" = "true" ]; then
  CURRENT_THEME="Dark"
else
  CURRENT_THEME="Light"
fi

# Get last recorded theme
LAST_THEME=$(cat /tmp/sketchybar_theme 2>/dev/null)

# Only reload if the theme has actually transitioned
if [ "$CURRENT_THEME" != "$LAST_THEME" ]; then
  echo "$CURRENT_THEME" > /tmp/sketchybar_theme
  sketchybar --reload
fi
