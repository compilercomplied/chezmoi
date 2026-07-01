#!/bin/bash

source "$HOME/.config/sketchybar/plugins/vars.sh"
OPEN_EVENT_SCRIPT="$HOME/.config/sketchybar/plugins/open_calendar_event.sh"

# --- HOVER: instant toggle, no AppleScript ---
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set $NAME popup.drawing=on
  exit 0
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set $NAME popup.drawing=off
  exit 0
elif [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set $NAME popup.drawing=off
  exit 0
fi

# --- PERIODIC REFRESH (routine / forced / update_freq) ---
# 1. Check for a next-hour event and update bar label
EVENT_DATA=$(osascript -e '
set today to (current date)
set nextHour to today + (60 * 60)
tell application "Calendar"
    repeat with theCalendar in every calendar
        try
            set theEvents to (every event of theCalendar whose (start date is greater than or equal to today) and (start date is less than or equal to nextHour) and (allday event is false))
            repeat with anEvent in theEvents
                set theStartDate to (get start date of anEvent)
                set hoursStr to (hours of theStartDate) as string
                set minsStr to (minutes of theStartDate) as string
                if (length of hoursStr) is 1 then set hoursStr to "0" & hoursStr
                if (length of minsStr) is 1 then set minsStr to "0" & minsStr
                set theSummary to (get summary of anEvent)
                return hoursStr & ":" & minsStr & " " & theSummary & tab & id of anEvent
            end repeat
        end try
    end repeat
end tell
return ""' 2>/dev/null)

if [ -n "$EVENT_DATA" ]; then
  IFS=$'\t' read -r NEXT_EVENT NEXT_EVENT_UID <<< "$EVENT_DATA"
  DISPLAY_TEXT="$NEXT_EVENT"
  if [ ${#DISPLAY_TEXT} -gt 20 ]; then
    DISPLAY_TEXT="${DISPLAY_TEXT:0:17}..."
  fi
  CLICK_CMD="bash '$OPEN_EVENT_SCRIPT' '$NEXT_EVENT_UID'"
else
  DISPLAY_TEXT="$(date '+%a %d, %b')"
  CLICK_CMD="open -a Calendar"
fi

sketchybar --set $NAME label="$DISPLAY_TEXT" click_script="$CLICK_CMD"

# 2. Refresh today's events in the popup (so hover is instant)
source "$HOME/.config/sketchybar/plugins/calendar.sh"
