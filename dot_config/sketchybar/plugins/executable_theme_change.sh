#!/bin/bash

# Get current system theme (everforest_hard_dark or everforest_hard_light) using AppleScript
if [ "$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')" = "true" ]; then
  CURRENT_THEME="everforest_hard_dark"
  NVIM_BACKGROUND="dark"
else
  CURRENT_THEME="everforest_hard_light"
  NVIM_BACKGROUND="light"
fi

# Get last recorded theme
LAST_THEME=$(cat "$HOME/.config/theme-repository/current.txt" 2>/dev/null | tr -d '[:space:]')

# Only reload if the theme has actually transitioned
if [ "$CURRENT_THEME" != "$LAST_THEME" ]; then
  # 1. Update current.txt
  echo "$CURRENT_THEME" > "$HOME/.config/theme-repository/current.txt"
  
  # 2. Reload sketchybar to load the new colors
  sketchybar --reload
  
  # 3. Sync Neovim theme
  echo "$NVIM_BACKGROUND" > "$HOME/.config/nvim/.appearance"
  
  # Signal all running Neovim instances via their sockets
  for socket in $(lsof -a -U -c nvim | awk '$NF ~ /^\// {print $NF}' 2>/dev/null); do
    if [ -S "$socket" ]; then
      nvim --server "$socket" --remote-send "<Cmd>set background=$NVIM_BACKGROUND<CR>" 2>/dev/null &
    fi
  done
fi
