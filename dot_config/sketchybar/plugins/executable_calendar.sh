#!/bin/bash

# Use absolute paths
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/plugins/vars.sh"

OPEN_EVENT_SCRIPT="$HOME/.config/sketchybar/plugins/open_calendar_event.sh"

# Fetch events from Calendar.app for today
EVENTS=$(osascript -e '
set today to (current date)
set startOfToday to today - (time of today)
set endOfToday to startOfToday + (24 * 60 * 60)
set eventList to ""
tell application "Calendar"
    repeat with theCalendar in every calendar
        try
            set theEvents to (every event of theCalendar whose (start date is greater than or equal to startOfToday) and (start date is less than or equal to endOfToday))
            repeat with anEvent in theEvents
                set theSummary to (get summary of anEvent)
                set theStartDate to (get start date of anEvent)
                set hoursStr to (hours of theStartDate) as string
                set minsStr to (minutes of theStartDate) as string
                if (length of hoursStr) is 1 then set hoursStr to "0" & hoursStr
                if (length of minsStr) is 1 then set minsStr to "0" & minsStr
                
                if (allday event of anEvent) is true then
                    set eventList to eventList & "00:00" & tab & "All Day 󰥔 " & theSummary & tab & id of anEvent & "\n"
                else
                    set durationSecs to (end date of anEvent) - theStartDate
                    set durationMins to (durationSecs div 60)
                    set durH to durationMins div 60
                    set durM to durationMins mod 60
                    set durStr to ""
                    if durH > 0 then set durStr to durStr & durH & "h"
                    if durM > 0 then set durStr to durStr & durM & "m"
                    if durStr is "" then set durStr to "0m"
                    
                    set eventList to eventList & hoursStr & ":" & minsStr & tab & durStr & " 󰥔 " & hoursStr & ":" & minsStr & " " & theSummary & tab & id of anEvent & "\n"
                end if
            end repeat
        end try
    end repeat
end tell
return eventList' 2>/dev/null)

# Clear existing dynamic items
sketchybar --remove '/calendar\.event\..*/'

# Sort chronologically, then deduplicate by label (column 2) keeping first occurrence (first UID wins)
SORTED_EVENTS=$(echo "$EVENTS" | sort)

counter=0
while IFS=$'\t' read -r sorting_key event_label event_uid; do
  if [ -n "$event_label" ] && [ -n "$event_uid" ]; then
    sketchybar --add item calendar.event.$counter popup.date \
               --set calendar.event.$counter \
                     label="$event_label" \
                     label.font="$LABEL_FONT" \
                     padding_left=15 \
                     padding_right=15 \
                     click_script="bash '$OPEN_EVENT_SCRIPT' '$event_uid'"
    counter=$((counter+1))
  fi
done <<< "$SORTED_EVENTS"

if [ $counter -eq 0 ]; then
    sketchybar --add item calendar.event.none popup.date \
               --set calendar.event.none \
                     label="No events today" \
                     label.font="$LABEL_FONT" \
                     padding_left=15 \
                     padding_right=15
fi
