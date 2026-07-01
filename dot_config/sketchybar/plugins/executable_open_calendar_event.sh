#!/bin/bash
# Opens a specific event in Calendar.app by its UID
# Usage: open_calendar_event.sh <event_uid>

EVENT_UID="$1"

if [ -z "$EVENT_UID" ]; then
  open -a Calendar
  exit 0
fi

osascript -e "
tell application \"Calendar\"
    activate
    repeat with c in every calendar
        try
            set evs to (every event of c whose id is \"$EVENT_UID\")
            if (count of evs) > 0 then
                show item 1 of evs
                return
            end if
        end try
    end repeat
end tell"
