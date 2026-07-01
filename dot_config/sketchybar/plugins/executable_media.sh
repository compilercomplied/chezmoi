#!/bin/bash

# Source colors
source "$HOME/.config/sketchybar/colors.sh"

# Handle hover-to-open and hover-leave-to-close events
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set $NAME popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set $NAME popup.drawing=off
  exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  exit 0
fi

STATE=""
APP=""
TITLE=""
ARTIST=""
ALBUM=""

# The media_change event passes $INFO containing JSON metadata about media
if [ -n "$INFO" ]; then
  STATE=$(echo "$INFO" | jq -r '.state')
  APP=$(echo "$INFO" | jq -r '.app')
  TITLE=$(echo "$INFO" | jq -r '.title')
  ARTIST=$(echo "$INFO" | jq -r '.artist')
  ALBUM=$(echo "$INFO" | jq -r '.album')
else
  # If loaded manually without $INFO, check running players
  SPOTIFY_STATE=""
  MUSIC_STATE=""
  if pgrep -x "Spotify" > /dev/null; then
    SPOTIFY_STATE=$(osascript -e 'tell application "Spotify" to player state' 2>/dev/null)
  fi
  if pgrep -x "Music" > /dev/null; then
    MUSIC_STATE=$(osascript -e 'tell application "Music" to player state' 2>/dev/null)
  fi

  if [ -n "$SPOTIFY_STATE" ]; then
    STATE="$SPOTIFY_STATE"
    APP="Spotify"
    TITLE=$(osascript -e 'tell application "Spotify" to name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track' 2>/dev/null)
    ALBUM=$(osascript -e 'tell application "Spotify" to album of current track' 2>/dev/null)
  elif [ -n "$MUSIC_STATE" ]; then
    STATE="$MUSIC_STATE"
    APP="Music"
    TITLE=$(osascript -e 'tell application "Music" to name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Music" to artist of current track' 2>/dev/null)
    ALBUM=$(osascript -e 'tell application "Music" to album of current track' 2>/dev/null)
  fi
fi

# Only show the widget if there is an active player state and a valid track title
if [ -n "$TITLE" ] && { [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; }; then
  # Pick a suitable icon based on the application (using classic v2 Nerd Font icons)
  case "$APP" in
    "Spotify")
      ICON=""
      # Fetch cover artwork and convert to true PNG
      ARTWORK_URL=$(osascript -e 'tell application "Spotify" to get artwork url of current track' 2>/dev/null)
      if [ -n "$ARTWORK_URL" ]; then
        curl -s "$ARTWORK_URL" -o /tmp/media_cover_raw
        sips -s format png /tmp/media_cover_raw --out /tmp/media_cover.png &>/dev/null
        rm -f /tmp/media_cover_raw
      else
        rm -f /tmp/media_cover.png
      fi
      ;;
    "Music")
      ICON=""
      # Fetch cover artwork and convert to true PNG
      rm -f /tmp/media_cover_raw /tmp/media_cover.png
      osascript -e '
      tell application "Music"
        if exists (artwork 1 of current track) then
          set rawData to raw data of artwork 1 of current track
          set fileRef to open for access (POSIX file "/tmp/media_cover_raw") with write permission
          set eof of fileRef to 0
          write rawData to fileRef
          close access fileRef
        end if
      end tell
      ' 2>/dev/null
      if [ -f /tmp/media_cover_raw ]; then
        sips -s format png /tmp/media_cover_raw --out /tmp/media_cover.png &>/dev/null
        rm -f /tmp/media_cover_raw
      fi
      ;;
    *)
      ICON=""
      rm -f /tmp/media_cover.png
      ;;
  esac

  # Calculate progress bar for the main bubble
  if [ "$APP" = "Spotify" ]; then
    DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track' 2>/dev/null)
    DURATION=$(( DURATION_MS / 1000 ))
    POSITION=$(osascript -e 'tell application "Spotify" to get player position' 2>/dev/null | cut -d. -f1 | cut -d, -f1)
  else
    DURATION=$(osascript -e 'tell application "Music" to get duration of current track' 2>/dev/null | cut -d. -f1 | cut -d, -f1)
    POSITION=$(osascript -e 'tell application "Music" to get player position' 2>/dev/null | cut -d. -f1 | cut -d, -f1)
  fi

  if [ -n "$DURATION" ] && [ "$DURATION" -gt 0 ] && [ -n "$POSITION" ]; then
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
    
    TRACK_INFO="$bar_filled$bar_empty"
  else
    TRACK_INFO="----------------"
  fi

  # Truncate details for the popup to prevent notch overlap
  TRUNC_TITLE="$TITLE"
  if [ ${#TRUNC_TITLE} -gt 20 ]; then
    TRUNC_TITLE="${TRUNC_TITLE:0:17}..."
  fi
  TRUNC_ARTIST="$ARTIST"
  if [ ${#TRUNC_ARTIST} -gt 20 ]; then
    TRUNC_ARTIST="${TRUNC_ARTIST:0:17}..."
  fi
  TRUNC_ALBUM="$ALBUM"
  if [ ${#TRUNC_ALBUM} -gt 20 ]; then
    TRUNC_ALBUM="${TRUNC_ALBUM:0:17}..."
  fi

  # Crop cover image to square if it exists to prevent aspect ratio deformation
  if [ -f /tmp/media_cover.png ]; then
    WIDTH=$(sips -g pixelWidth /tmp/media_cover.png | awk '/pixelWidth/ {print $2}')
    HEIGHT=$(sips -g pixelHeight /tmp/media_cover.png | awk '/pixelHeight/ {print $2}')
    if [ -n "$WIDTH" ] && [ -n "$HEIGHT" ]; then
      if [ $WIDTH -lt $HEIGHT ]; then
        MIN_DIM=$WIDTH
      else
        MIN_DIM=$HEIGHT
      fi
      sips -c $MIN_DIM $MIN_DIM /tmp/media_cover.png &>/dev/null
      
      # Dynamically calculate scale factor to fit exactly 70px height without deformation
      SCALE=$(awk "BEGIN {print 70 / $MIN_DIM}" 2>/dev/null)
    fi
    
    if [ -z "$SCALE" ]; then
      SCALE="0.109"
    fi
    
    sketchybar --set media_cover background.image="/tmp/media_cover.png" background.image.scale="$SCALE" background.drawing=on
  else
    sketchybar --set media_cover background.image="" background.drawing=off
  fi

  # Update all details in the popup
  sketchybar --set $NAME \
             drawing=on \
             icon="$ICON" \
             label="$TRACK_INFO" \
             --set media_title label="$TRUNC_TITLE" \
             --set media_artist label="$TRUNC_ARTIST" \
             --set media_album label="$TRUNC_ALBUM"
else
  # Hide the main widget and close the popup if nothing is playing
  sketchybar --set $NAME drawing=off popup.drawing=off
fi
