#!/bin/bash

# Source Everforest colors, variables and appearance logic
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/vars.sh"

# This script is called by sketchybar when the aerospace_workspace_change event is triggered

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    # Randomly pick between green, purple (magenta), yellow, orange, and red
    case $((RANDOM % 5)) in
        0) FONT_COLOR=$GREEN ;;
        1) FONT_COLOR=$MAGENTA ;;
        2) FONT_COLOR=$YELLOW ;;
        3) FONT_COLOR=$ORANGE ;;
        4) FONT_COLOR=$RED ;;
    esac

    sketchybar --animate sine 10 \
               --set $NAME background.color=$BG_ACTIVE_WORKSPACE \
                           label.padding_left=14 \
                           label.padding_right=14 \
                           label.font="$ACTIVE_LABEL_FONT" \
                           label.color=$FONT_COLOR
else
    sketchybar --animate sine 10 \
               --set $NAME background.color=$TRANSPARENT \
                           label.padding_left=6 \
                           label.padding_right=6 \
                           label.font="$LABEL_FONT" \
                           label.color=$GREY
fi
