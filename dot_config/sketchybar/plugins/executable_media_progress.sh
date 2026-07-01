#!/bin/bash

# Only query and update if the media popup is actually open!
POPUP_OPEN=$(sketchybar --query media | jq -r '.popup.drawing')

if [ "$POPUP_OPEN" = "on" ]; then
  APP=""
  if pgrep -x "Spotify" > /dev/null; then
    APP="Spotify"
  elif pgrep -x "Music" > /dev/null; then
    APP="Music"
  fi

  if [ -n "$APP" ]; then
    if [ "$APP" = "Spotify" ]; then
      DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track' 2>/dev/null)
      DURATION=$(( DURATION_MS / 1000 ))
      POSITION=$(osascript -e 'tell application "Spotify" to get player position' 2>/dev/null | cut -d. -f1 | cut -d, -f1)
    else
      DURATION=$(osascript -e 'tell application "Music" to get duration of current track' 2>/dev/null | cut -d. -f1 | cut -d, -f1)
      POSITION=$(osascript -e 'tell application "Music" to get player position' 2>/dev/null | cut -d. -f1 | cut -d, -f1)
    fi

    format_time() {
      local seconds=$1
      if [ -z "$seconds" ] || [ "$seconds" -lt 0 ]; then
        echo "0:00"
        return
      fi
      local min=$(( seconds / 60 ))
      local sec=$(( seconds % 60 ))
      printf "%d:%02d" $min $sec
    }

    if [ -n "$DURATION" ] && [ "$DURATION" -gt 0 ] && [ -n "$POSITION" ]; then
      # Prevent division by zero or negative percentages
      if [ "$POSITION" -gt "$DURATION" ]; then
        POSITION=$DURATION
      fi
      PERCENT=$(( POSITION * 100 / DURATION ))
      filled=$(( PERCENT * 16 / 100 ))
      empty=$(( 16 - filled ))
      
      bar_filled=""
      if [ $filled -gt 0 ]; then
        bar_filled=$(printf "%${filled}s" | tr " " "━")
      fi
      bar_empty=""
      if [ $empty -gt 0 ]; then
        bar_empty=$(printf "%${empty}s" | tr " " "-")
      fi
      
      PROGRESS_BAR="$bar_filled$bar_empty"
    else
      PROGRESS_BAR="----------------"
    fi
    sketchybar --set $NAME label="$PROGRESS_BAR" drawing=on
  else
    sketchybar --set $NAME drawing=off
  fi
fi
