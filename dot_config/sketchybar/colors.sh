#!/bin/bash

# Detect dark/light mode of macOS using AppleScript (works with Auto appearance)
if [ "$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')" = "true" ]; then
  # --- EVERFOREST DARK (HARD CONTRAST) ---
  export WHITE=0xffd3c6aa
  export RED=0xffe67e80
  export GREEN=0xffa7c080
  export YELLOW=0xffdbbc7f
  export ORANGE=0xffe69875
  export MAGENTA=0xffd699b6
  export GREY=0xff859289
  export TRANSPARENT=0x00000000

  # Sketchybar Specifics
  export BUBBLE_COLOR=0xff2d353b    # Medium background for the pills/bubbles
  export BUBBLE_BORDER=0xff3c4841   # Clean, visible border for separation
  export ITEM_COLOR=0xffd3c6aa      # Warm white foreground

  # Component Accent Colors
  export COLOR_MEDIA=0xff7fbbb3      # Blue
  export COLOR_BLUETOOTH=0xff83c092  # Cyan/Aqua
  export COLOR_WIFI=0xffdbbc7f       # Yellow
  export COLOR_BATTERY=0xffa7c080    # Green
  export COLOR_VOLUME=0xffe69875     # Orange
  export COLOR_DATE_TIME=0xffd699b6  # Magenta/Purple
else
  # --- EVERFOREST LIGHT (MEDIUM CONTRAST) ---
  export WHITE=0xff5c6a72            # Dark grey/charcoal
  export RED=0xfff85552
  export GREEN=0xff8da101
  export YELLOW=0xffdfa000
  export ORANGE=0xfff57d26
  export MAGENTA=0xffdf69ba
  export GREY=0xff939f91
  export TRANSPARENT=0x00000000

  # Sketchybar Specifics
  export BUBBLE_COLOR=0xffefebd4    # Medium background (EFEBD4)
  export BUBBLE_BORDER=0xffe5dfc5   # Soft contrast border (E5DFC5)
  export ITEM_COLOR=0xff5c6a72      # Dark grey foreground

  # Component Accent Colors
  export COLOR_MEDIA=0xff3a94c5      # Blue
  export COLOR_BLUETOOTH=0xff35a77c  # Aqua/Cyan
  export COLOR_WIFI=0xffdfa000       # Yellow
  export COLOR_BATTERY=0xff8da101    # Green
  export COLOR_VOLUME=0xfff57d26     # Orange
  export COLOR_DATE_TIME=0xffdf69ba  # Magenta/Purple
fi
