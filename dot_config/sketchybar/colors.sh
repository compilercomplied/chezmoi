#!/bin/bash

THEME_DIR="$HOME/.config/theme-repository"
CURRENT_THEME_FILE="$THEME_DIR/current.txt"

# 1. Read active theme name
if [ -f "$CURRENT_THEME_FILE" ]; then
  THEME_NAME=$(cat "$CURRENT_THEME_FILE" | tr -d '[:space:]')
fi

# Fallback to dark if not set or file doesn't exist
if [ -z "$THEME_NAME" ]; then
  THEME_NAME="everforest_hard_dark"
fi

THEME_FILE="$THEME_DIR/${THEME_NAME}.txt"

# Default values (fallback if file loading fails)
if [[ "$THEME_NAME" =~ "dark" ]]; then
  DEFAULT_WHITE="0xffd3c6aa"
  DEFAULT_RED="0xffe67e80"
  DEFAULT_GREEN="0xffa7c080"
  DEFAULT_YELLOW="0xffdbbc7f"
  DEFAULT_ORANGE="0xffe69875"
  DEFAULT_MAGENTA="0xffd699b6"
  DEFAULT_GREY="0xff859289"
  DEFAULT_BUBBLE="0xff2d353b"
  DEFAULT_BORDER="0xff3c4841"
  DEFAULT_BLUE="0xff7fbbb3"
  DEFAULT_CYAN="0xff83c092"
else
  DEFAULT_WHITE="0xff5c6a72"
  DEFAULT_RED="0xfff85552"
  DEFAULT_GREEN="0xff8da101"
  DEFAULT_YELLOW="0xffdfa000"
  DEFAULT_ORANGE="0xfff57d26"
  DEFAULT_MAGENTA="0xffdf69ba"
  DEFAULT_GREY="0xff939f91"
  DEFAULT_BUBBLE="0xffe5dfc5"
  DEFAULT_BORDER="0xffdbd6b6"
  DEFAULT_BLUE="0xff3a94c5"
  DEFAULT_CYAN="0xff35a77c"
fi

# Function to read value from theme file and convert to ARGB (0xffxxxxxx)
get_color() {
  local key="$1"
  local default_val="$2"
  local val=""
  
  if [ -f "$THEME_FILE" ]; then
    val=$(awk -F'=' -v k="$key" '$1 == k {print $2}' "$THEME_FILE" | xargs)
  fi
  
  if [ -n "$val" ]; then
    # Convert hex (#1e2326) to ARGB (0xff1e2326)
    if [[ "$val" =~ ^# ]]; then
      echo "0xff${val#?}"
    else
      echo "$val"
    fi
  else
    echo "$default_val"
  fi
}

export WHITE=$(get_color "foreground" "$DEFAULT_WHITE")
export RED=$(get_color "red" "$DEFAULT_RED")
export GREEN=$(get_color "green" "$DEFAULT_GREEN")
export YELLOW=$(get_color "yellow" "$DEFAULT_YELLOW")
export ORANGE=$(get_color "orange" "$DEFAULT_ORANGE")
export MAGENTA=$(get_color "magenta" "$DEFAULT_MAGENTA")
export GREY=$(get_color "grey" "$DEFAULT_GREY")
export TRANSPARENT="0x00000000"

export BUBBLE_COLOR=$(get_color "bubble" "$DEFAULT_BUBBLE")
export BUBBLE_BORDER=$(get_color "border" "$DEFAULT_BORDER")
export ITEM_COLOR="$WHITE"

# Component Accent Colors
export COLOR_MEDIA=$(get_color "blue" "$DEFAULT_BLUE")
export COLOR_BLUETOOTH=$(get_color "cyan" "$DEFAULT_CYAN")
export COLOR_WIFI="$YELLOW"
export COLOR_BATTERY="$GREEN"
export COLOR_VOLUME="$ORANGE"
export COLOR_DATE_TIME="$MAGENTA"
