#!/bin/bash

# Source colors
source "$HOME/.config/sketchybar/colors.sh"

# Check Wi-Fi power and SSID
POWER=$(networksetup -getairportpower en0 2>/dev/null | awk '{print $NF}')
SSID=$(/usr/sbin/ipconfig getsummary en0 | awk -F' : ' '/ SSID/ { print $2 }')

if [ "$POWER" = "Off" ]; then
  ICON="󰖪"
  LABEL="Off"
  COLOR=$GREY
elif [ -z "$SSID" ]; then
  ICON="󰖪"
  LABEL="Disconnected"
  COLOR=$GREY
else
  ICON="󰖩"
  LABEL="$SSID"
  COLOR=$COLOR_WIFI
fi
sketchybar --set $NAME icon="$ICON" icon.color=$COLOR

