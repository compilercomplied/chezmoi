#!/bin/bash
echo "Sender: $SENDER, Name: $NAME" >> /tmp/sketchybar_hover.log
if [ "$SENDER" = "mouse.entered" ]; then
    case "$NAME" in
        "Control Center,WiFi")
            osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item "WiFi" of menu bar 1'
            ;;
        "Control Center,Battery")
            osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item "Battery" of menu bar 1'
            ;;
        "Control Center,Sound")
            osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item "Sound" of menu bar 1'
            ;;
        "Control Center,Bluetooth")
            osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item "Bluetooth" of menu bar 1'
            ;;
    esac
fi
