# Source colors for dynamic styling
source "$HOME/.config/sketchybar/colors.sh"

# Check bluetooth status via system_profiler
BT_INFO=$(system_profiler -detailLevel mini SPBluetoothDataType 2>/dev/null)
STATE=$(echo "$BT_INFO" | grep -m 1 "State:" | awk '{print $2}')

if [ "$STATE" != "On" ]; then
  ICON="󰂲"
  COLOR=$GREY
else
  # Check if any device is connected
  if echo "$BT_INFO" | grep -q "Connected: Yes"; then
    ICON="󰂱"
    COLOR=$COLOR_BLUETOOTH
  else
    ICON="󰂯"
    COLOR=$COLOR_BLUETOOTH
  fi
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
