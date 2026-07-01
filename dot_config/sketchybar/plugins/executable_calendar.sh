#!/bin/bash

# Use absolute paths
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/plugins/vars.sh"

OPEN_EVENT_SCRIPT="$HOME/.config/sketchybar/plugins/open_calendar_event.sh"

# Fetch events from Calendar database for today (resolving recurring events correctly)
EVENTS=$(swift - 2>/dev/null <<'EOF'
import EventKit
import Foundation

let eventStore = EKEventStore()

func fetchEvents() {
    let calendar = Calendar.current
    let now = Date()
    var components = calendar.dateComponents([.year, .month, .day], from: now)
    components.hour = 0
    components.minute = 0
    components.second = 0
    guard let startOfToday = calendar.date(from: components) else { return }
    guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) else { return }
    
    let predicate = eventStore.predicateForEvents(withStart: startOfToday, end: endOfToday, calendars: nil)
    let events = eventStore.events(matching: predicate)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    for event in events {
        if let attendees = event.attendees {
            let declined = attendees.contains { attendee in
                attendee.isCurrentUser && attendee.participantStatus == .declined
            }
            if declined { continue }
        }
        
        let startStr = dateFormatter.string(from: event.startDate)
        let uid = event.calendarItemIdentifier
        let title = event.title ?? "No Title"
        
        if event.isAllDay {
            print("00:00\tAll Day 󰥔 \(title)\t\(uid)")
        } else {
            let durationSecs = event.endDate.timeIntervalSince(event.startDate)
            let durationMins = Int(durationSecs) / 60
            let durH = durationMins / 60
            let durM = durationMins % 60
            
            var durStr = ""
            if durH > 0 { durStr += "\(durH)h" }
            if durM > 0 { durStr += "\(durM)m" }
            if durStr.isEmpty { durStr = "0m" }
            
            print("\(startStr)\t\(durStr) 󰥔 \(startStr) \(title)\t\(uid)")
        }
    }
    exit(0)
}

let status = EKEventStore.authorizationStatus(for: .event)
switch status {
case .authorized, .fullAccess:
    fetchEvents()
default:
    if #available(macOS 14.0, *) {
        eventStore.requestFullAccessToEvents { granted, error in
            if granted { fetchEvents() } else { exit(1) }
        }
    } else {
        eventStore.requestAccess(to: .event) { granted, error in
            if granted { fetchEvents() } else { exit(1) }
        }
    }
    dispatchMain()
}
EOF
)


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
