#!/usr/bin/env bash
# Compact power menu via rofi (replaces the oversized wlogout buttons).
# Save as ~/.config/hypr/power-menu.sh and chmod +x it.

chosen=$(printf " Lock\n Logout\n Reboot\n Shutdown" \
  | rofi -dmenu -i -p "Power" -theme-str 'window {width: 300px;} listview {lines: 4;}')

case "$chosen" in
  *Lock)     hyprlock ;;
  *Logout)   hyprctl dispatch exit ;;
  *Reboot)   systemctl reboot ;;
  *Shutdown) systemctl poweroff ;;
esac
